//
//  SwiftUIView.swift
//  Keepi
//
//  Created by Kauane Santana on 29/08/23.
//

import Combine
import FirebaseAuth
import FirebaseFirestore

class TradeListManager {
    var lista: [TradeModel] = []

    private let subject = PassthroughSubject<[TradeModel], Error>()
    var publisher: AnyPublisher<[TradeModel], Error> {
        self.subject.eraseToAnyPublisher()
    }

    func removeTrade(indexItem: Int, completion: ((Error?) -> Void)? = nil) {
        guard lista.indices.contains(indexItem) else {
            completion?(Self.error(code: 404, message: "Selected entry no longer exists."))
            return
        }

        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            completion?(Self.error(code: 401, message: "Cannot delete an entry without an authenticated user."))
            return
        }

        let trade = lista[indexItem]
        let tradeRef = db.collection("Users").document(userID).collection("Trades").document(trade.id)

        db.runTransaction({ transaction, errorPointer in
            let tradeSnapshot: DocumentSnapshot
            do {
                tradeSnapshot = try transaction.getDocument(tradeRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            guard tradeSnapshot.exists else {
                errorPointer?.pointee = Self.error(code: 404, message: "Selected entry no longer exists.")
                return nil
            }

            let storedEnvelopeId = tradeSnapshot.data()?["envelopeId"] as? String ?? ""
            let storedValue = FirestoreValueParser.decimalValue(from: tradeSnapshot.data()?["value"])

            if !storedEnvelopeId.isEmpty {
                let envelopeRef = db.collection("Users").document(userID).collection("Envelopes").document(storedEnvelopeId)
                let envelopeSnapshot: DocumentSnapshot

                do {
                    envelopeSnapshot = try transaction.getDocument(envelopeRef)
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }

                if envelopeSnapshot.exists {
                    let envelopeBudget = FirestoreValueParser.decimalValue(from: envelopeSnapshot.data()?["budget"])
                    transaction.updateData(["budget": Money.firestoreNumber(envelopeBudget + storedValue)], forDocument: envelopeRef)
                }
            }

            transaction.deleteDocument(tradeRef)
            return nil
        }, completion: { _, error in
            if let error {
                print("Error removing trade: \(error.localizedDescription)")
                completion?(error)
                return
            }

            if self.lista.indices.contains(indexItem), self.lista[indexItem].id == trade.id {
                self.lista.remove(at: indexItem)
            } else if let index = self.lista.firstIndex(where: { $0.id == trade.id }) {
                self.lista.remove(at: index)
            }
            self.sortTradesNewestFirst()
            self.subject.send(self.lista)
            completion?(nil)
        })
    }

    static func date2string(date: Date, dateFormat: String = "yyyyMMddHHmmss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

    func fetchTrades(completion: ((Error?) -> Void)? = nil) {
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
                Self.makeTrade(from: document)
            }
            self.sortTradesNewestFirst()
            self.subject.send(self.lista)
            completion?(nil)
        }
    }

    func addTrade(trade: TradeModel, completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "Keepi", code: 401, userInfo: [NSLocalizedDescriptionKey: "Cannot add entry without an authenticated user."])
            print(error.localizedDescription)
            completion?(error)
            return
        }

        let tradeRef = db.collection("Users").document(userID).collection("Trades").document(trade.id)
        let tradeData = Self.makeTradeData(from: trade)

        db.runTransaction({ transaction, errorPointer in
            let existingTrade: DocumentSnapshot
            do {
                existingTrade = try transaction.getDocument(tradeRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            guard !existingTrade.exists else {
                errorPointer?.pointee = Self.error(code: 409, message: "This entry was already saved.")
                return nil
            }

            if !trade.envelopeId.isEmpty {
                let envelopeRef = db.collection("Users").document(userID).collection("Envelopes").document(trade.envelopeId)
                let envelopeSnapshot: DocumentSnapshot

                do {
                    envelopeSnapshot = try transaction.getDocument(envelopeRef)
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }

                guard envelopeSnapshot.exists else {
                    errorPointer?.pointee = Self.error(code: 404, message: "Selected envelope does not exist.")
                    return nil
                }

                let envelopeBudget = FirestoreValueParser.decimalValue(from: envelopeSnapshot.data()?["budget"])
                transaction.updateData(["budget": Money.firestoreNumber(envelopeBudget - trade.value)], forDocument: envelopeRef)
            }

            transaction.setData(tradeData, forDocument: tradeRef)
            return nil
        }, completion: { _, error in
            if let error {
                print("Error adding trade: \(error.localizedDescription)")
                completion?(error)
                return
            }

            self.lista.removeAll { $0.id == trade.id }
            self.lista.append(trade)
            self.sortTradesNewestFirst()
            self.subject.send(self.lista)
            completion?(nil)
        })
    }

    func updateTrade(trade: TradeModel, completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            completion?(Self.error(code: 401, message: "Cannot update an entry without an authenticated user."))
            return
        }

        let envelopesCollection = db.collection("Users").document(userID).collection("Envelopes")
        let tradeRef = db.collection("Users").document(userID).collection("Trades").document(trade.id)
        let tradeData = Self.makeTradeData(from: trade)

        db.runTransaction({ transaction, errorPointer in
            let tradeSnapshot: DocumentSnapshot

            do {
                tradeSnapshot = try transaction.getDocument(tradeRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            guard tradeSnapshot.exists else {
                errorPointer?.pointee = Self.error(code: 404, message: "Entry does not exist.")
                return nil
            }

            let oldEnvelopeId = tradeSnapshot.data()?["envelopeId"] as? String ?? ""
            let newEnvelopeId = trade.envelopeId
            let oldValue = FirestoreValueParser.decimalValue(from: tradeSnapshot.data()?["value"])

            let oldEnvelopeRef = oldEnvelopeId.isEmpty ? nil : envelopesCollection.document(oldEnvelopeId)
            let newEnvelopeRef = newEnvelopeId.isEmpty ? nil : envelopesCollection.document(newEnvelopeId)
            var oldEnvelopeSnapshot: DocumentSnapshot?
            var newEnvelopeSnapshot: DocumentSnapshot?

            do {
                if let oldEnvelopeRef {
                    oldEnvelopeSnapshot = try transaction.getDocument(oldEnvelopeRef)
                }
                if let newEnvelopeRef, newEnvelopeId != oldEnvelopeId {
                    newEnvelopeSnapshot = try transaction.getDocument(newEnvelopeRef)
                } else if newEnvelopeId == oldEnvelopeId {
                    newEnvelopeSnapshot = oldEnvelopeSnapshot
                }
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            if newEnvelopeRef != nil, newEnvelopeSnapshot?.exists != true {
                errorPointer?.pointee = Self.error(code: 404, message: "Selected envelope does not exist.")
                return nil
            }

            if oldEnvelopeId == newEnvelopeId {
                if let envelopeRef = newEnvelopeRef, let envelopeSnapshot = newEnvelopeSnapshot {
                    let budget = FirestoreValueParser.decimalValue(from: envelopeSnapshot.data()?["budget"])
                    transaction.updateData(["budget": Money.firestoreNumber(budget + oldValue - trade.value)], forDocument: envelopeRef)
                }
            } else {
                if let envelopeRef = oldEnvelopeRef, let envelopeSnapshot = oldEnvelopeSnapshot {
                    let budget = FirestoreValueParser.decimalValue(from: envelopeSnapshot.data()?["budget"])
                    transaction.updateData(["budget": Money.firestoreNumber(budget + oldValue)], forDocument: envelopeRef)
                }

                if let envelopeRef = newEnvelopeRef, let envelopeSnapshot = newEnvelopeSnapshot {
                    let budget = FirestoreValueParser.decimalValue(from: envelopeSnapshot.data()?["budget"])
                    transaction.updateData(["budget": Money.firestoreNumber(budget - trade.value)], forDocument: envelopeRef)
                }
            }

            transaction.updateData(tradeData, forDocument: tradeRef)
            return nil
        }, completion: { _, error in
            if let error {
                print("Error updating trade: \(error.localizedDescription)")
                completion?(error)
                return
            }

            if let index = self.lista.firstIndex(where: { $0.id == trade.id }) {
                self.lista[index] = trade
            }
            self.sortTradesNewestFirst()
            self.subject.send(self.lista)
            completion?(nil)
        })
    }

    private func sortTradesNewestFirst() {
        lista.sort { lhs, rhs in
            lhs.date > rhs.date
        }
    }

    private static func makeTrade(from document: QueryDocumentSnapshot) -> TradeModel? {
        let data = document.data()
        let id = data["id"] as? String ?? document.documentID
        let name = data["name"] as? String ?? ""
        let value = FirestoreValueParser.decimalValue(from: data["value"])
        let envelopeId = data["envelopeId"] as? String ?? ""
        let feeling = data["feeling"] as? Int ?? 0
        let listTagNames = data["tags"] as? [String] ?? []
        let tags = Tags.getTags(listNames: listTagNames)
        let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
        let reflectionCompleted = data["reflectionCompleted"] as? Bool ?? true
        let worthIt = data["worthIt"] as? Bool
        let note = data["note"] as? String ?? ""
        let journalEntry = data["journalEntry"] as? String ?? ""

        guard !id.isEmpty else { return nil }
        return TradeModel(
            id: id,
            name: name,
            value: value,
            tag: tags,
            envelopeId: envelopeId,
            feeling: feeling,
            date: date,
            reflectionCompleted: reflectionCompleted,
            worthIt: worthIt,
            note: note,
            journalEntry: journalEntry
        )
    }

    static func makeTradeData(from trade: TradeModel) -> [String: Any] {
        let listTagNames = trade.tag.map { $0.name }
        var data: [String: Any] = [
            "name": trade.name,
            "value": Money.firestoreNumber(trade.value),
            "id": trade.id,
            "tags": listTagNames,
            "envelopeId": trade.envelopeId,
            "date": trade.date,
            "feeling": trade.feeling,
            "reflectionCompleted": trade.reflectionCompleted,
            "note": trade.note,
            "journalEntry": trade.journalEntry
        ]

        if let worthIt = trade.worthIt {
            data["worthIt"] = worthIt
        } else {
            data["worthIt"] = NSNull()
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
