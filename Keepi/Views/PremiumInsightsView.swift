import SwiftUI

struct PremiumInsightsView: View {
    @EnvironmentObject var interactor: HomeInteractor
    @ObservedObject var draftManager = DraftManager.shared
    
    @EnvironmentObject var premiumManager: StoreKitPremiumManager
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi")
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Header & Month Selector
                        HStack {
                            Text("Insights")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("blackKeepi"))
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("This Month")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                        }
                        
                        if interactor.listTransactions.isEmpty {
                            emptyState
                        } else {
                            // Your Spending
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Spending")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text(KeepiFormat.currency(thisMonthSpending()))
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color("darkGreenKeepi"))
                            }
                            
                            Divider()
                            
                            // Planned vs Impulsive
                            let intentAnalytics = IntentAnalyticsEngine.generateAnalytics(from: interactor.listTransactions, envelopes: interactor.listEnvelopes)
                            if premiumManager.canUse(.spendingIntentAnalytics) {
                                NavigationLink(destination: IntentAnalyticsView(analytics: intentAnalytics)) {
                                    insightCard(
                                        title: "Planned vs Impulsive",
                                        subtitle: intentAnalytics.hasEnoughData ? "See your intent breakdown" : "Need more data",
                                        icon: "brain.head.profile"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                Button(action: { showPaywall = true }) {
                                    insightCard(
                                        title: "Planned vs Impulsive",
                                        subtitle: "Premium feature",
                                        icon: "lock.fill"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Divider()
                            
                            // How Spending Felt
                            let emotionalAnalytics = EmotionalAnalyticsEngine.generateAnalytics(from: interactor.listTransactions, envelopes: interactor.listEnvelopes)
                            if premiumManager.canUse(.emotionalAnalytics) {
                                NavigationLink(destination: EmotionalAnalyticsView(analytics: emotionalAnalytics)) {
                                    insightCard(
                                        title: "How Spending Felt",
                                        subtitle: emotionalAnalytics.hasEnoughData ? "See your emotional breakdown" : "Need more data",
                                        icon: "face.smiling"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                Button(action: { showPaywall = true }) {
                                    insightCard(
                                        title: "How Spending Felt",
                                        subtitle: "Premium feature",
                                        icon: "lock.fill"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Divider()
                            
                            // Envelope Patterns
                            VStack(alignment: .leading, spacing: 12) {
                                MeaningfulPatternsView()
                            }
                            
                            Divider()
                            
                            // Weekly Reflection
                            if let reflection = WeeklyReflectionEngine.generateReflection(
                                for: interactor.listTransactions,
                                unreviewedDraftsCount: draftManager.drafts.count,
                                envelopes: interactor.listEnvelopes
                            ) {
                                if premiumManager.canUse(.weeklyReflection) {
                                    NavigationLink(destination: WeeklyReflectionView(reflection: reflection)) {
                                        insightCard(
                                            title: "Weekly Reflection",
                                            subtitle: "Open latest",
                                            icon: "calendar"
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    Button(action: { showPaywall = true }) {
                                        insightCard(
                                            title: "Weekly Reflection",
                                            subtitle: "Premium feature",
                                            icon: "lock.fill"
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80) // Padding for tab bar
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No insights yet")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("blackKeepi"))
            
            Text("Add a few entries and reflections to see spending, feeling, and motivation patterns.")
                .font(.subheadline)
                .foregroundColor(Color(.systemGray))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }
    
    private func insightCard(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("darkGreenKeepi"))
                .frame(width: 44, height: 44)
                .background(Color("lightGreenKeepi").opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color("blackKeepi"))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
    }
    
    private func thisMonthSpending() -> Decimal {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        let expenses = interactor.listTransactions.filter {
            $0.type == .expense &&
            calendar.component(.month, from: $0.date) == currentMonth &&
            calendar.component(.year, from: $0.date) == currentYear
        }
        
        return expenses.reduce(Decimal(0)) { $0 + $1.value }
    }
}
