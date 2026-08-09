//
//  SwiftUIView.swift
//  Keepi
//
//  Created by Kauane Santana on 29/08/23.
//

import Combine
import FirebaseAuth
import FirebaseFirestore

class TransactionListManager {
    var lista: [TransactionModel] = []

    private let subject = PassthroughSubject<[TransactionModel], Error>()
    var publisher: AnyPublisher<[TransactionModel], Error> {
        self.subject.eraseToAnyPublisher()
    }

    func removeTransaction(indexItem: Int, completion: ((Error?) -> Void)? = nil) {
        guard lista.indices.contains(indexItem) else {
            completion?(Self.error(code: 404, message: "Selected entry no longer exists."))
            return
        }

        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            completion?(Self.error(code: 401, message: "Cannot delete an entry without an authenticated user."))
            return
        }

        let transaction = lista[indexItem]
        let transactionRef = db.collection("Users").document(userID).collection("Trades").document(transaction.id)

        transactionRef.delete { error in
            if let error {
                print("Error removing trade: \(error.localizedDescription)")
                completion?(error)
                return
            }

            if self.lista.indices.contains(indexItem), self.lista[indexItem].id == transaction.id {
                self.lista.remove(at: indexItem)
            } else if let index = self.lista.firstIndex(where: { $0.id == transaction.id }) {
                self.lista.remove(at: index)
            }
            self.sortTradesNewestFirst()
            self.subject.send(self.lista)
            completion?(nil)
        }
    }

    static func date2string(date: Date, dateFormat: String = "yyyyMMddHHmmss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

    func fetchTransactions(completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            completion?(Self.error(code: 401, message: "Cannot load entries without an authenticated user."))
            return
        }

        let ref = db.collection("Users").document(userID).collection("Trades").order(by: "date", descending: true)

        ref.getDocuments { snapshot, error in
            if let error {
                completion?(error)
                return
            }

            guard let snapshot else { return }

            self.lista = snapshot.documents.compactMap { document in
                Self.makeTransaction(from: document)
            }
            self.sortTradesNewestFirst()
            self.subject.send(self.lista)
            completion?(nil)
        }
    }

    func addTransaction(transaction: TransactionModel, completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "Keepi", code: 401, userInfo: [NSLocalizedDescriptionKey: "Cannot add entry without an authenticated user."])
            print(error.localizedDescription)
            completion?(error)
            return
        }

        let transactionRef = db.collection("Users").document(userID).collection("Trades").document(transaction.id)
        let transactionData = Self.makeTransactionData(from: transaction)

        transactionRef.getDocument { snapshot, error in
            if let error {
                completion?(error)
                return
            }
            if let snapshot, snapshot.exists {
                completion?(Self.error(code: 409, message: "This entry was already saved."))
                return
            }
            
            transactionRef.setData(transactionData) { error in
                if let error {
                    print("Error adding trade: \(error.localizedDescription)")
                    completion?(error)
                    return
                }

                self.lista.removeAll { $0.id == transaction.id }
                self.lista.append(transaction)
                self.sortTradesNewestFirst()
                self.subject.send(self.lista)
                completion?(nil)
            }
        }
    }

    func updateTransaction(transaction: TransactionModel, completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            completion?(Self.error(code: 401, message: "Cannot update an entry without an authenticated user."))
            return
        }
        
        let transactionRef = db.collection("Users").document(userID).collection("Trades").document(transaction.id)
        let transactionData = Self.makeTransactionData(from: transaction)

        transactionRef.updateData(transactionData) { error in
            if let error {
                print("Error updating trade: \(error.localizedDescription)")
                completion?(error)
                return
            }

            if let index = self.lista.firstIndex(where: { $0.id == transaction.id }) {
                self.lista[index] = transaction
            }
            self.sortTradesNewestFirst()
            self.subject.send(self.lista)
            completion?(nil)
        }
    }

    private func sortTradesNewestFirst() {
        lista.sort { lhs, rhs in
            lhs.date > rhs.date
        }
    }

    private static func makeTransaction(from document: QueryDocumentSnapshot) -> TransactionModel? {
        let data = document.data()
        let id = data["id"] as? String ?? document.documentID
        let name = data["name"] as? String ?? ""
        let value = FirestoreValueParser.decimalValue(from: data["value"])
        let envelopeId = data["envelopeId"] as? String ?? ""
        let feeling = data["feeling"] as? Int ?? 0
        
        // Migration: Default to expense if missing
        let typeString = data["type"] as? String ?? TransactionType.expense.rawValue
        let type = TransactionType(rawValue: typeString) ?? .expense
        
        let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
        let reflectionCompleted = data["reflectionCompleted"] as? Bool ?? true
        let worthIt = data["worthIt"] as? Bool
        let isPlanned = data["isPlanned"] as? Bool
        let note = data["note"] as? String ?? ""
        let journalEntry = data["journalEntry"] as? String ?? ""
        let sourceFingerprint = data["sourceFingerprint"] as? String

        guard !id.isEmpty else { return nil }
        return TransactionModel(
            id: id,
            name: name,
            value: value,
            envelopeId: envelopeId,
            feeling: feeling,
            date: date,
            reflectionCompleted: reflectionCompleted,
            worthIt: worthIt,
            isPlanned: isPlanned,
            type: type,
            note: note,
            journalEntry: journalEntry,
            sourceFingerprint: sourceFingerprint
        )
    }

    static func makeTransactionData(from transaction: TransactionModel) -> [String: Any] {
        var data: [String: Any] = [
            "name": transaction.name,
            "value": Money.firestoreNumber(transaction.value),
            "id": transaction.id,
            "envelopeId": transaction.envelopeId,
            "date": transaction.date,
            "feeling": transaction.feeling,
            "reflectionCompleted": transaction.reflectionCompleted,
            "type": transaction.type.rawValue,
            "note": transaction.note,
            "journalEntry": transaction.journalEntry
        ]
        
        if let sourceFingerprint = transaction.sourceFingerprint {
            data["sourceFingerprint"] = sourceFingerprint
        }

        if let worthIt = transaction.worthIt {
            data["worthIt"] = worthIt
        } else {
            data["worthIt"] = NSNull()
        }
        
        if let isPlanned = transaction.isPlanned {
            data["isPlanned"] = isPlanned
        } else {
            data["isPlanned"] = NSNull()
        }

        return data
    }

    private static func error(code: Int, message: String) -> NSError {
        NSError(domain: "Keepi", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

enum FirestoreValueParser {
    static func decimalValue(from value: Any?) -> Decimal {
        switch value {
        case let value as Decimal:
            return Money.rounded(value)
        case let value as Int:
            return Decimal(value)
        case let value as NSNumber:
            return Money.rounded(value.decimalValue)
        case let value as Double:
            return Money.rounded(Decimal(value))
        case let value as Float:
            return Money.rounded(Decimal(Double(value)))
        case let value as String:
            let normalized = value.replacingOccurrences(of: ",", with: ".")
            return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")).map(Money.rounded) ?? 0
        default:
            return 0
        }
    }
}
