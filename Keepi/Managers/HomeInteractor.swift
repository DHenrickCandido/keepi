//
//  HomeInteractor.swift
//  Keepi
//
//  Created by Diego Henrick on 13/09/23.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class HomeInteractor: ObservableObject {
    private let transactionListManager: TransactionListManager
    let envelopeListManager: EnvelopeListManager
    private let aggregationService: EntryAggregationService

    @Published var listTransactions: [TransactionModel] = []
    @Published var listEnvelopes: [Envelope] = []
    @Published var errorMessage: String?

    private var cancellables: [AnyCancellable] = []

    init(transactionListManager: TransactionListManager, envelopeListManager: EnvelopeListManager, aggregationService: EntryAggregationService = DefaultEntryAggregationService()) {
        self.transactionListManager = transactionListManager
        self.envelopeListManager = envelopeListManager
        self.aggregationService = aggregationService

        cancellables.append(contentsOf: [
            transactionListManager.publisher.sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { list in
                self.listTransactions = list
            }),

            envelopeListManager.publisher.sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { list in
                self.listEnvelopes = list
            })
        ])
    }

    func loadData() {
        transactionListManager.fetchTransactions { error in
            if let error {
                self.errorMessage = error.localizedDescription
            }
        }
        envelopeListManager.fetchEnvelopes { error in
            if let error {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func removeTransaction(indexItem: Int, completion: ((Error?) -> Void)? = nil) {
        guard listTransactions.indices.contains(indexItem) else {
            errorMessage = "Selected entry no longer exists."
            completion?(NSError(domain: "Keepi", code: 404, userInfo: [NSLocalizedDescriptionKey: errorMessage!]))
            return
        }

        transactionListManager.removeTransaction(indexItem: indexItem) { error in
            if let error {
                self.errorMessage = error.localizedDescription
            }
            completion?(error)
        }
    }

    func removeEnvelope(indexItem: Int, completion: ((Error?) -> Void)? = nil) {
        guard listEnvelopes.indices.contains(indexItem) else {
            errorMessage = "Selected envelope no longer exists."
            completion?(NSError(domain: "Keepi", code: 404, userInfo: [NSLocalizedDescriptionKey: errorMessage!]))
            return
        }

        removeEnvelope(envelopeId: listEnvelopes[indexItem].id, completion: completion)
    }

    func removeEnvelope(envelopeId: String, completion: ((Error?) -> Void)? = nil) {
        guard listEnvelopes.contains(where: { $0.id == envelopeId }) else {
            errorMessage = "Selected envelope no longer exists."
            completion?(NSError(domain: "Keepi", code: 404, userInfo: [NSLocalizedDescriptionKey: errorMessage!]))
            return
        }

        guard CRUDValidation.canDeleteEnvelope(envelopeId: envelopeId, trades: listTransactions) else {
            errorMessage = "Move or delete entries before removing this envelope."
            completion?(NSError(domain: "Keepi", code: 409, userInfo: [NSLocalizedDescriptionKey: errorMessage!]))
            return
        }

        envelopeListManager.removeEnvelope(envelopeId: envelopeId) { error in
            if let error {
                self.errorMessage = error.localizedDescription
            }
            completion?(error)
        }
    }

    func updateTransaction(transaction: TransactionModel, completion: ((Error?) -> Void)? = nil) {
        transactionListManager.updateTransaction(transaction: transaction) { error in
            if let error {
                self.errorMessage = error.localizedDescription
            }
            completion?(error)
        }
    }

    func updateEnvelope(envelope: Envelope, completion: ((Error?) -> Void)? = nil) {
        envelopeListManager.updateEnvelope(envelope: envelope) { error in
            if let error {
                self.errorMessage = error.localizedDescription
            }
            completion?(error)
        }
    }

    func addTransaction(transaction: TransactionModel, completion: ((Error?) -> Void)? = nil) {
        transactionListManager.addTransaction(transaction: transaction) { error in
            if let error {
                self.errorMessage = error.localizedDescription
            }
            completion?(error)
        }
    }

    func addEnvelope(envelope: Envelope, completion: ((Error?) -> Void)? = nil) {
        envelopeListManager.addEnvelope(envelope: envelope) { error in
            if let error {
                self.errorMessage = error.localizedDescription
            }
            completion?(error)
        }
    }

    func getEnvelopeNameById(id: String) -> String {
        envelopeListManager.getEnvelopeNameById(id: id)
    }

    func spent(forEnvelopeId id: String, period: EntryPeriod = .month(Date())) -> Decimal {
        aggregationService.total(entries: listTransactions, envelopeID: id, period: period)
    }

    func entryCount(forEnvelopeId id: String, period: EntryPeriod = .month(Date())) -> Int {
        aggregationService.entries(from: listTransactions, envelopeID: id, period: period).count
    }

    func entries(forEnvelopeId id: String, period: EntryPeriod = .month(Date())) -> [TransactionModel] {
        aggregationService.entries(from: listTransactions, envelopeID: id, period: period).sorted { $0.date > $1.date }
    }

    func deleteAccountData(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "Keepi", code: 401, userInfo: [NSLocalizedDescriptionKey: "No signed-in account was found."]))
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(user.uid)

        deleteDocuments(in: userRef.collection("Trades")) { error in
            if let error {
                completion(error)
                return
            }

            self.deleteDocuments(in: userRef.collection("Envelopes")) { error in
                if let error {
                    completion(error)
                    return
                }

                userRef.delete { error in
                    if let error {
                        completion(error)
                        return
                    }

                    user.delete { error in
                        if error == nil {
                            self.listTransactions = []
                            self.listEnvelopes = []
                        }
                        completion(error)
                    }
                }
            }
        }
    }

    private func deleteDocuments(in collection: CollectionReference, completion: @escaping (Error?) -> Void) {
        collection.limit(to: 400).getDocuments { snapshot, error in
            if let error {
                completion(error)
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                completion(nil)
                return
            }

            let batch = Firestore.firestore().batch()
            documents.forEach { batch.deleteDocument($0.reference) }
            batch.commit { error in
                if let error {
                    completion(error)
                    return
                }

                self.deleteDocuments(in: collection, completion: completion)
            }
        }
    }
}
