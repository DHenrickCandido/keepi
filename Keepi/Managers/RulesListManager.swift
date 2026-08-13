import FirebaseFirestore
import FirebaseAuth
import Combine

class RulesListManager: ObservableObject {
    @Published var merchantRules: [MerchantEnvelopeRule] = []
    @Published var categoryMappings: [ExternalCategoryMapping] = []
    
    private var db = Firestore.firestore()
    private var rulesListener: ListenerRegistration?
    private var mappingsListener: ListenerRegistration?
    
    private(set) var userId: String
    
    init() {
        if let uid = Auth.auth().currentUser?.uid {
            self.userId = uid
            fetchRules()
            fetchMappings()
        } else {
            self.userId = ""
        }
    }
    
    func refreshUserIdIfNeeded() {
        guard userId.isEmpty, let uid = Auth.auth().currentUser?.uid else { return }
        userId = uid
        fetchRules()
        fetchMappings()
    }
    
    deinit {
        rulesListener?.remove()
        mappingsListener?.remove()
    }
    
    func fetchRules() {
        guard !userId.isEmpty else { return }
        rulesListener = db.collection("users").document(userId).collection("merchantRules")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                
                self?.merchantRules = documents.compactMap { doc -> MerchantEnvelopeRule? in
                    let data = doc.data()
                    guard let pattern = data["pattern"] as? String,
                          let matchTypeRaw = data["matchType"] as? String,
                          let matchType = MerchantMatchType(rawValue: matchTypeRaw),
                          let envelopeID = data["envelopeID"] as? String else {
                        return nil
                    }
                    let useCount = data["useCount"] as? Int ?? 1
                    let lastUsedAt = (data["lastUsedAt"] as? Timestamp)?.dateValue() ?? Date()
                    
                    return MerchantEnvelopeRule(
                        id: doc.documentID,
                        pattern: pattern,
                        matchType: matchType,
                        envelopeID: envelopeID,
                        useCount: useCount,
                        lastUsedAt: lastUsedAt
                    )
                }
            }
    }
    
    func fetchMappings() {
        guard !userId.isEmpty else { return }
        mappingsListener = db.collection("users").document(userId).collection("categoryMappings")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                
                self?.categoryMappings = documents.compactMap { doc -> ExternalCategoryMapping? in
                    let data = doc.data()
                    guard let sourceCategory = data["sourceCategory"] as? String,
                          let envelopeID = data["envelopeID"] as? String else {
                        return nil
                    }
                    return ExternalCategoryMapping(sourceCategory: sourceCategory, envelopeID: envelopeID)
                }
            }
    }
    
    func saveRule(_ rule: MerchantEnvelopeRule) {
        refreshUserIdIfNeeded()
        guard !userId.isEmpty else {
            print("[RulesListManager] Cannot save rule — no authenticated user.")
            return
        }
        guard !rule.id.isEmpty else {
            print("[RulesListManager] Cannot save rule — empty rule ID.")
            return
        }
        let data: [String: Any] = [
            "pattern": rule.pattern,
            "matchType": rule.matchType.rawValue,
            "envelopeID": rule.envelopeID,
            "useCount": rule.useCount,
            "lastUsedAt": rule.lastUsedAt
        ]
        db.collection("users").document(userId).collection("merchantRules").document(rule.id).setData(data)
    }
    
    func saveMapping(_ mapping: ExternalCategoryMapping) {
        refreshUserIdIfNeeded()
        guard !userId.isEmpty else {
            print("[RulesListManager] Cannot save mapping — no authenticated user.")
            return
        }
        guard !mapping.id.isEmpty else {
            print("[RulesListManager] Cannot save mapping — empty mapping ID (sourceCategory is empty).")
            return
        }
        let data: [String: Any] = [
            "sourceCategory": mapping.sourceCategory,
            "envelopeID": mapping.envelopeID
        ]
        db.collection("users").document(userId).collection("categoryMappings").document(mapping.id).setData(data)
    }
}
