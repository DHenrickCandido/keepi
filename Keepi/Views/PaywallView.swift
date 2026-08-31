import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var premiumManager: StoreKitPremiumManager
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?

    private let privacyURL = URL(string: "https://github.com/mashiruwu/keepi/blob/main/PRIVACY.md")!
    private let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    var body: some View {
        ZStack {
            Color("mainGreen").ignoresSafeArea()
            decorations

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    closeButton
                    hero
                    benefitsCard
                    purchaseSection
                    legalSection
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }
        }
        .preferredColorScheme(.light)
        .onChange(of: premiumManager.hasPremium) { hasPremium in
            if hasPremium { dismiss() }
        }
    }

    private var decorations: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(Color("secondGreen").opacity(0.48))
                    .frame(width: 240, height: 240)
                    .position(x: proxy.size.width + 28, y: 75)

                Circle()
                    .stroke(Color("yellow").opacity(0.55), lineWidth: 5)
                    .frame(width: 125, height: 125)
                    .position(x: 8, y: proxy.size.height * 0.56)

                Circle()
                    .fill(Color("red").opacity(0.48))
                    .frame(width: 54, height: 54)
                    .position(x: proxy.size.width - 38, y: proxy.size.height * 0.72)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var closeButton: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.15), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.16), lineWidth: 1))
            }
            .accessibilityLabel("Continue without Premium")
        }
        .padding(.top, 8)
    }

    private var hero: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color("secondGreen"))
                    .frame(width: 116, height: 116)

                Image("keepiMascote")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 112, height: 112)

                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundColor(Color("mainGreen"))
                    .frame(width: 36, height: 36)
                    .background(.white, in: Circle())
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
            }

            Text("KEEPI PREMIUM")
                .font(.caption.bold())
                .tracking(1.8)
                .foregroundColor(Color("secondGreen"))

            Text("See the story behind\nyour spending")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.82)

            Text("Import your history, notice meaningful patterns, and make every reflection easier.")
                .font(.body.weight(.medium))
                .foregroundColor(.white.opacity(0.76))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
        }
    }

    private var benefitsCard: some View {
        VStack(spacing: 0) {
            benefitRow(icon: "arrow.down.doc.fill", title: "Import statements", subtitle: "Bring in a CSV and review entries at your pace.")
            benefitDivider
            benefitRow(icon: "wand.and.stars", title: "Learn your categories", subtitle: "Keepi remembers how you organize recurring purchases.")
            benefitDivider
            benefitRow(icon: "chart.bar.xaxis", title: "Reveal your patterns", subtitle: "Connect spending with intention, feelings, and regret.")
            benefitDivider
            benefitRow(icon: "calendar.badge.clock", title: "Reflect on your week", subtitle: "Receive a thoughtful summary when each week closes.")
        }
        .padding(.horizontal, 18)
        .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 22, y: 10)
    }

    private func benefitRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(Color("mainGreen"))
                .frame(width: 42, height: 42)
                .background(Color("secondGreen").opacity(0.45), in: RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color("blackKeepi"))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 15)
    }

    private var benefitDivider: some View {
        Divider().padding(.leading, 56)
    }

    private var purchaseSection: some View {
        VStack(spacing: 13) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }

            if let product = premiumManager.subscriptions.first {
                Button { purchase(product) } label: {
                    HStack(spacing: 10) {
                        if isPurchasing {
                            ProgressView().tint(Color("mainGreen"))
                        } else {
                            Text("Start Premium")
                            Spacer()
                            Text("\(product.displayPrice) / month")
                                .foregroundColor(Color("mainGreen").opacity(0.68))
                        }
                    }
                    .font(.headline)
                    .foregroundColor(Color("mainGreen"))
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .disabled(isPurchasing || isRestoring)
            } else if let loadError = premiumManager.productLoadError {
                VStack(spacing: 10) {
                    Text(loadError)
                        .font(.footnote)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Button("Try again") {
                        Task { await premiumManager.fetchProducts() }
                    }
                    .font(.headline)
                    .foregroundColor(Color("mainGreen"))
                    .padding(.horizontal, 24)
                    .frame(minHeight: 46)
                    .background(.white, in: Capsule())
                }
            } else {
                ProgressView("Loading subscription…")
                    .tint(.white)
                    .foregroundColor(.white)
                    .task { await premiumManager.fetchProducts() }
            }

            Button(isRestoring ? "Restoring…" : "Restore purchases") {
                restorePurchases()
            }
            .disabled(isPurchasing || isRestoring)
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .frame(minHeight: 40)
        }
    }

    private var legalSection: some View {
        VStack(spacing: 12) {
            Text("Renews automatically unless cancelled at least 24 hours before the current period ends. Manage or cancel in your App Store account settings.")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.62))
                .multilineTextAlignment(.center)

            HStack(spacing: 18) {
                Link("Privacy", destination: privacyURL)
                Link("Terms", destination: termsURL)
            }
            .font(.caption.bold())
            .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
    }

    private func purchase(_ product: Product) {
        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                let success = try await premiumManager.purchase(product)
                isPurchasing = false
                if success { dismiss() }
            } catch {
                isPurchasing = false
                errorMessage = "The purchase couldn't be completed. Please try again."
            }
        }
    }

    private func restorePurchases() {
        isRestoring = true
        errorMessage = nil

        Task {
            do {
                let restored = try await premiumManager.restorePurchases()
                isRestoring = false
                if restored {
                    dismiss()
                } else {
                    errorMessage = "No active Keepi Premium purchase was found."
                }
            } catch {
                isRestoring = false
                errorMessage = "Keepi couldn't restore purchases. Please try again."
            }
        }
    }
}
