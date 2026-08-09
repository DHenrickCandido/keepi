import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var premiumManager: StoreKitPremiumManager
    @Environment(\.dismiss) var dismiss
    
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // Header Image/Icon
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 64))
                            .foregroundColor(Color("darkGreenKeepi"))
                            .padding()
                            .background(Color("lightGreenKeepi").opacity(0.3))
                            .clipShape(Circle())
                        
                        Text("Keepi Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("blackKeepi"))
                        
                        Text("Unlock intelligent insights and automated workflows to deeply understand your money.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 32)
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 20) {
                        featureRow(icon: "doc.text.viewfinder", title: "Smart CSV Import", subtitle: "Import thousands of transactions in seconds.")
                        featureRow(icon: "brain.head.profile", title: "Intelligent Matching", subtitle: "Automatically categorize based on your history.")
                        featureRow(icon: "chart.xyaxis.line", title: "Premium Analytics", subtitle: "Emotional and Intent insights on your spending.")
                        featureRow(icon: "calendar.badge.clock", title: "Weekly Reflections", subtitle: "Get an automatic summary of your week.")
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 32)
                    
                    // Subscription Button
                    VStack(spacing: 16) {
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        if let product = premiumManager.subscriptions.first {
                            Button(action: {
                                purchase(product: product)
                            }) {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Subscribe for \(product.displayPrice) / month")
                                            .font(.headline)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("darkGreenKeepi"))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                            }
                            .disabled(isPurchasing)
                        } else {
                            ProgressView("Loading products...")
                                .onAppear {
                                    Task {
                                        await premiumManager.fetchProducts()
                                    }
                                }
                        }
                        
                        Button("Restore Purchases") {
                            Task {
                                await premiumManager.updateCustomerProductStatus()
                                if premiumManager.hasPremium {
                                    dismiss()
                                }
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarItems(trailing: Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            })
            .onChange(of: premiumManager.hasPremium) { hasPremium in
                if hasPremium {
                    dismiss()
                }
            }
        }
    }
    
    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("darkGreenKeepi"))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color("blackKeepi"))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func purchase(product: Product) {
        isPurchasing = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await premiumManager.purchase(product)
                isPurchasing = false
                if success {
                    dismiss()
                }
            } catch {
                isPurchasing = false
                errorMessage = "Purchase failed. Please try again."
            }
        }
    }
}
