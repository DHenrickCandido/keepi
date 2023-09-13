//
//  EnvelopeListManager.swift
//  Keepi
//
//  Created by Kauane Santana on 05/09/23.
//

import SwiftUI
import Firebase

class EnvelopeListManager: ObservableObject {
    @Published var listaEnvelope: [EnvelopeModel] = []
    
//    func addEnvelope(item: EnvelopeModel) {
//            listaEnvelope.insert(item, at: 0)
//            print(listaEnvelope)
//        }
    
    func removeTrade(indexItem: Int){
//        lista.remove(at: indexItem)
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        print(listaEnvelope[indexItem].name)
        db.collection("Users").document(userID).collection("Envelopes").document(listaEnvelope[indexItem].id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        fetchEnvelopes()
    }

    init() {
        fetchEnvelopes()
    }
    
    static func date2string(date: Date, dateFormat: String = "yyyyMMddHHmmss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func fetchEnvelopes() {
        listaEnvelope.removeAll()
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let ref = db.collection("Users").document(userID).collection("Envelopes")

        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let id = data["id"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let budget = data["budget"] as? Float ?? 0.0
                    let icon = data["icon"] as? String ?? ""
                    
                    let envelope = EnvelopeModel(id: id, name: name, budget: budget,icon: icon)
                    self.listaEnvelope.append(envelope)
                }
            }
        }
    }
    
    func addEnvelope(envelope: EnvelopeModel){
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        

        

        let ref = db.collection("Users").document(userID).collection("Envelopes").document(envelope.id)

        
        
        ref.setData(["name": envelope.name, "budget": envelope.budget, "id": envelope.id, "icon": envelope.icon]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func getEnvelopeNameById(id: String) -> String{
        for envelope in listaEnvelope {
            if envelope.id == id {
                return envelope.name
            }
        }
        
        return "Nulo"
    }
}
