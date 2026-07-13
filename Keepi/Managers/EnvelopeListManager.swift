//
//  EnvelopeListManager.swift
//  Keepi
//
//  Created by Kauane Santana on 05/09/23.
//

import Combine
import Firebase

class EnvelopeListManager {
    var listaEnvelope: [EnvelopeModel] = []

    private let subject = PassthroughSubject<[EnvelopeModel], Error>()
    var publisher: AnyPublisher<[EnvelopeModel], Error> {
        self.subject.eraseToAnyPublisher()
    }

    func removeEnvelope(indexItem: Int) {
        guard listaEnvelope.indices.contains(indexItem) else {
            print("Invalid envelope index: \(indexItem)")
            return
        }

        removeEnvelope(envelopeId: listaEnvelope[indexItem].id)
    }

    func removeEnvelope(envelopeId: String) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot remove envelope without an authenticated user.")
            return
        }

        db.collection("Users").document(userID).collection("Envelopes").document(envelopeId).delete { error in
            if let error {
                print("Error removing envelope: \(error.localizedDescription)")
                return
            }

            self.listaEnvelope.removeAll { $0.id == envelopeId }
            self.subject.send(self.listaEnvelope)
        }
    }

    static func date2string(date: Date, dateFormat: String = "yyyyMMddHHmmss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

    func fetchEnvelopes() {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot fetch envelopes without an authenticated user.")
            return
        }

        let ref = db.collection("Users").document(userID).collection("Envelopes")

        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            guard let snapshot else { return }

            self.listaEnvelope = snapshot.documents.compactMap { document in
                Self.makeEnvelope(from: document)
            }
            self.subject.send(self.listaEnvelope)
        }
    }

    func addEnvelope(envelope: EnvelopeModel, completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "Keepi", code: 401, userInfo: [NSLocalizedDescriptionKey: "Cannot add envelope without an authenticated user."])
            print(error.localizedDescription)
            completion?(error)
            return
        }

        let ref = db.collection("Users").document(userID).collection("Envelopes").document(envelope.id)
        db.runTransaction({ transaction, errorPointer in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(ref)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            guard !snapshot.exists else {
                errorPointer?.pointee = NSError(domain: "Keepi", code: 409, userInfo: [NSLocalizedDescriptionKey: "An envelope with this name already exists."])
                return nil
            }

            transaction.setData(Self.makeEnvelopeData(from: envelope), forDocument: ref)
            return nil
        }, completion: { _, error in
            if let error {
                print("Error adding envelope: \(error.localizedDescription)")
                completion?(error)
                return
            }

            self.listaEnvelope.insert(envelope, at: 0)
            self.subject.send(self.listaEnvelope)
            completion?(nil)
        })
    }

    func getEnvelopeNameById(id: String) -> String {
        guard !id.isEmpty else { return "No envelope" }

        for envelope in listaEnvelope where envelope.id == id {
            return envelope.name
        }

        return "Deleted envelope"
    }

    func updateEnvelope(envelope: EnvelopeModel) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot update envelope without an authenticated user.")
            return
        }

        let ref = db.collection("Users").document(userID).collection("Envelopes").document(envelope.id)
        ref.updateData(Self.makeEnvelopeData(from: envelope)) { error in
            if let error {
                print("Error updating envelope: \(error.localizedDescription)")
                return
            }

            if let index = self.listaEnvelope.firstIndex(where: { $0.id == envelope.id }) {
                self.listaEnvelope[index] = envelope
            } else {
                self.listaEnvelope.insert(envelope, at: 0)
            }
            self.subject.send(self.listaEnvelope)
        }
    }

    private static func makeEnvelope(from document: QueryDocumentSnapshot) -> EnvelopeModel? {
        let data = document.data()
        let id = data["id"] as? String ?? document.documentID
        let name = data["name"] as? String ?? ""
        let budget = FirestoreValueParser.floatValue(from: data["budget"])
        let icon = data["icon"] as? String ?? ""

        guard !id.isEmpty else { return nil }
        return EnvelopeModel(id: id, name: name, budget: budget, icon: icon)
    }

    static func makeEnvelopeData(from envelope: EnvelopeModel) -> [String: Any] {
        [
            "name": envelope.name,
            "budget": envelope.budget,
            "id": envelope.id,
            "icon": envelope.icon
        ]
    }
}
