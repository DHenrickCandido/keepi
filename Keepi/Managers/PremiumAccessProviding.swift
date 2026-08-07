import Foundation

protocol PremiumAccessProviding {
    var hasPremium: Bool { get }
    func canUse(_ feature: PremiumFeature) -> Bool
}
