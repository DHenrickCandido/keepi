import Foundation
import StoreKit
import Combine

@MainActor
class StoreKitPremiumManager: ObservableObject, PremiumAccessProviding {
    @Published var hasPremium: Bool = false
    @Published var subscriptions: [Product] = []
    @Published var productLoadError: String?
    
    private var updateListenerTask: Task<Void, Never>?
    private let productId = "premiumMonthly"
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await fetchProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func canUse(_ feature: PremiumFeature) -> Bool {
        return hasPremium
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    func fetchProducts() async {
        productLoadError = nil
        do {
            let storeProducts = try await Product.products(for: [productId])
            self.subscriptions = storeProducts
            if storeProducts.isEmpty {
                productLoadError = "The subscription is currently unavailable."
            }
        } catch {
            productLoadError = "Keepi couldn't load subscription options."
        }
    }
    
    func updateCustomerProductStatus() async {
        var isPremium = false
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productType == .autoRenewable || transaction.productType == .nonConsumable {
                    if transaction.productID == productId {
                        isPremium = true
                    }
                }
            } catch {
                print("Unverified entitlement.")
            }
        }
        self.hasPremium = isPremium
    }
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            await updateCustomerProductStatus()
            await transaction.finish()
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async throws -> Bool {
        try await AppStore.sync()
        await updateCustomerProductStatus()
        return hasPremium
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
