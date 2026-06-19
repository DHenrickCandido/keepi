//
//  SwiftUIView.swift
//  Keepi
//
//  Created by Kauane Santana on 29/08/23.
//

import Combine
import Firebase

class TradeListManager {
    var lista: [TradeModel] = []

    private let subject = PassthroughSubject<[TradeModel], Error>()
    var publisher: AnyPublisher<[TradeModel], Error> {
        self.subject.eraseToAnyPublisher()
    }

    func removeTrade(indexItem: Int) {
        guard lista.indices.contains(indexItem) else {
            print("Invalid trade index: \(indexItem)")
            return
        }

        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot remove trade without an authenticated user.")
            return
        }

        let trade = lista[indexItem]
        let tradeRef = db.collection("Users").document(userID).collection("Trades").document(trade.id)

        db.runTransaction({ transaction, errorPointer in
            if !trade.envelopeId.isEmpty {
                let envelopeRef = db.collection("Users").document(userID).collection("Envelopes").document(trade.envelopeId)
                let envelopeSnapshot: DocumentSnapshot

                do {
                    envelopeSnapshot = try transaction.getDocument(envelopeRef)
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }

                let envelopeBudget = FirestoreValueParser.floatValue(from: envelopeSnapshot.data()?["budget"])
                transaction.updateData(["budget": envelopeBudget + trade.value], forDocument: envelopeRef)
            }

            transaction.deleteDocument(tradeRef)
            return nil
        }, completion: { _, error in
            if let error {
                print("Error removing trade: \(error.localizedDescription)")
                return
            }

            if self.lista.indices.contains(indexItem), self.lista[indexItem].id == trade.id {
                self.lista.remove(at: indexItem)
            } else if let index = self.lista.firstIndex(where: { $0.id == trade.id }) {
                self.lista.remove(at: index)
            }
            self.subject.send(self.lista)
        })
    }

    static func date2string(date: Date, dateFormat: String = "yyyyMMddHHmmss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

    func fetchTrades() {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot fetch trades without an authenticated user.")
            return
        }

        let ref = db.collection("Users").document(userID).collection("Trades").order(by: "date", descending: true)

        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            guard let snapshot else { return }

            self.lista = snapshot.documents.compactMap { document in
                Self.makeTrade(from: document)
            }
            self.subject.send(self.lista)
        }
    }

    func addTrade(trade: TradeModel) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot add trade without an authenticated user.")
            return
        }

        let tradeRef = db.collection("Users").document(userID).collection("Trades").document(trade.id)
        let tradeData = Self.makeTradeData(from: trade)

        db.runTransaction({ transaction, errorPointer in
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
                    errorPointer?.pointee = NSError(domain: "Keepi", code: 404, userInfo: [NSLocalizedDescriptionKey: "Selected envelope does not exist."])
                    return nil
                }

                let envelopeBudget = FirestoreValueParser.floatValue(from: envelopeSnapshot.data()?["budget"])
                transaction.updateData(["budget": envelopeBudget - trade.value], forDocument: envelopeRef)
            }

            transaction.setData(tradeData, forDocument: tradeRef)
            return nil
        }, completion: { _, error in
            if let error {
                print("Error adding trade: \(error.localizedDescription)")
                return
            }

            self.lista.removeAll { $0.id == trade.id }
            self.lista.insert(trade, at: 0)
            self.subject.send(self.lista)
        })
    }

    func updateTrade(trade: TradeModel) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot update trade without an authenticated user.")
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
                errorPointer?.pointee = NSError(domain: "Keepi", code: 404, userInfo: [NSLocalizedDescriptionKey: "Trade does not exist."])
                return nil
            }

            let oldEnvelopeId = tradeSnapshot.data()?["envelopeId"] as? String ?? ""
            let newEnvelopeId = trade.envelopeId
            let oldValue = FirestoreValueParser.floatValue(from: tradeSnapshot.data()?["value"])

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
                errorPointer?.pointee = NSError(domain: "Keepi", code: 404, userInfo: [NSLocalizedDescriptionKey: "Selected envelope does not exist."])
                return nil
            }

            if oldEnvelopeId == newEnvelopeId {
                if let envelopeRef = newEnvelopeRef, let envelopeSnapshot = newEnvelopeSnapshot {
                    let budget = FirestoreValueParser.floatValue(from: envelopeSnapshot.data()?["budget"])
                    transaction.updateData(["budget": budget + oldValue - trade.value], forDocument: envelopeRef)
                }
            } else {
                if let envelopeRef = oldEnvelopeRef, let envelopeSnapshot = oldEnvelopeSnapshot {
                    let budget = FirestoreValueParser.floatValue(from: envelopeSnapshot.data()?["budget"])
                    transaction.updateData(["budget": budget + oldValue], forDocument: envelopeRef)
                }

                if let envelopeRef = newEnvelopeRef, let envelopeSnapshot = newEnvelopeSnapshot {
                    let budget = FirestoreValueParser.floatValue(from: envelopeSnapshot.data()?["budget"])
                    transaction.updateData(["budget": budget - trade.value], forDocument: envelopeRef)
                }
            }

            transaction.updateData(tradeData, forDocument: tradeRef)
            return nil
        }, completion: { _, error in
            if let error {
                print("Error updating trade: \(error.localizedDescription)")
                return
            }

            if let index = self.lista.firstIndex(where: { $0.id == trade.id }) {
                self.lista[index] = trade
            }
            self.subject.send(self.lista)
        })
    }

    private static func makeTrade(from document: QueryDocumentSnapshot) -> TradeModel? {
        let data = document.data()
        let id = data["id"] as? String ?? document.documentID
        let name = data["name"] as? String ?? ""
        let value = FirestoreValueParser.floatValue(from: data["value"])
        let envelopeId = data["envelopeId"] as? String ?? ""
        let feeling = data["feeling"] as? Int ?? 0
        let listTagNames = data["tags"] as? [String] ?? []
        let tags = Tags.getTags(listNames: listTagNames)
        let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
        let reflectionCompleted = data["reflectionCompleted"] as? Bool ?? true
        let worthIt = data["worthIt"] as? Bool
        let note = data["note"] as? String ?? ""

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
            note: note
        )
    }

    static func makeTradeData(from trade: TradeModel) -> [String: Any] {
        let listTagNames = trade.tag.map { $0.name }
        var data: [String: Any] = [
            "name": trade.name,
            "value": trade.value,
            "id": trade.id,
            "tags": listTagNames,
            "envelopeId": trade.envelopeId,
            "date": trade.date,
            "feeling": trade.feeling,
            "reflectionCompleted": trade.reflectionCompleted,
            "note": trade.note
        ]

        if let worthIt = trade.worthIt {
            data["worthIt"] = worthIt
        } else {
            data["worthIt"] = NSNull()
        }

        return data
    }
}

enum FirestoreValueParser {
    static func floatValue(from value: Any?) -> Float {
        switch value {
        case let value as Float:
            return value
        case let value as Double:
            return Float(value)
        case let value as Int:
            return Float(value)
        case let value as NSNumber:
            return value.floatValue
        case let value as String:
            return Float(value.replacingOccurrences(of: ",", with: ".")) ?? 0
        default:
            return 0
        }
    }
}
