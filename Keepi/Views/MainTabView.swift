import SwiftUI
import Firebase

struct MainTabView: View {
    @StateObject private var interactor = HomeInteractor(
        tradeListManager: TradeListManager(),
        envelopeListManager: EnvelopeListManager()
    )

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            PlaceholderTabView(
                title: "Entries",
                subtitle: "Entry history",
                detail: "Browse, search, filter, and review past spending.",
                systemImage: "list.bullet.rectangle"
            )
            .tabItem {
                Label("Entries", systemImage: "list.bullet.rectangle")
            }

            AddEntryView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }

            ReflectView()
                .tabItem {
                    Label("Reflect", systemImage: "sparkles")
                }

            PlaceholderTabView(
                title: "Insights",
                subtitle: "Soft patterns",
                detail: "Mood patterns, envelope summaries, and gentle visualizations.",
                systemImage: "chart.bar.xaxis"
            )
            .tabItem {
                Label("Insights", systemImage: "chart.bar.xaxis")
            }
        }
        .environmentObject(interactor)
        .accentColor(Color("darkGreenKeepi"))
        .onAppear {
            signInAnonymouslyIfNeeded()
        }
    }

    private func signInAnonymouslyIfNeeded() {
        if Auth.auth().currentUser != nil {
            interactor.loadData()
            return
        }

        Auth.auth().signInAnonymously { _, error in
            if let error {
                interactor.errorMessage = error.localizedDescription
                return
            }

            interactor.loadData()
        }
    }
}

private struct PlaceholderTabView: View {
    let title: String
    let subtitle: String
    let detail: String
    let systemImage: String

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: systemImage)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(Color("darkGreenKeepi"))
                    .frame(width: 96, height: 96)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)

                VStack(spacing: 8) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackKeepi"))

                    Text(subtitle)
                        .font(.headline)
                        .foregroundColor(Color("darkGreenKeepi"))

                    Text(detail)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(.systemGray))
                        .padding(.horizontal, 24)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("lightGrayKeepi"))
            .navigationBarHidden(true)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
