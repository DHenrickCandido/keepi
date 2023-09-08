//
//  SwiftUIView.swift
//  Keepi
//
//  Created by Kauane Santana on 29/08/23.
//

import SwiftUI
import Firebase
class TradeListManager: ObservableObject {
    @Published var lista: [TradeModel] = []
//    func addTrade(item: TradeModel) {
//        lista.insert(item, at: 0)
//        print(lista)
//    }
//
    func removeTrade(indexItem: Int){
//        lista.remove(at: indexItem)
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        print(lista[indexItem].name)
        db.collection("Users").document(userID).collection("Trades").document(lista[indexItem].id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        fetchTrades()
    }

    init() {
        fetchTrades()
    }
    
    static func date2string(date: Date, dateFormat: String = "yyyyMMddHHmmss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func fetchTrades() {
        lista.removeAll()
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let ref = db.collection("Users").document(userID).collection("Trades")

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
                    let value = data["value"] as? Float ?? 0.0
                    let envelopeId = data["envelopeId"] as? String ?? ""
                    let date = data["date"] as? Timestamp
                    let feeling = data["feeling"] as? Int ?? 0
                    let listTagNames = data["tags"] as? [String] ?? []
                    var tags = [Tag]()
                    print("TESTE")
                    print(envelopeId)
//                    for tagName in listTagNames {
//                        tags.append(Tag(id: tagName))
//                    }
                    tags = Tags.getTags(listNames: listTagNames)
                    print(tags)
                    let trade = TradeModel(id: id, name: name, value: value,tag: tags, envelopeId: envelopeId, feeling: feeling, date: Date(timeIntervalSince1970: TimeInterval(date!.seconds)))
                    self.lista.append(trade)
                }
            }
        }
    }
    

    
    func addTrade(trade: TradeModel){
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        

        

        let ref = db.collection("Users").document(userID).collection("Trades").document(trade.id)
        var listTagNames = [String]()
        for tag in trade.tag{
            listTagNames.append(tag.name)
        }
        
        
        ref.setData(["name": trade.name, "value": trade.value, "id": trade.id, "tags": listTagNames, "envelopeId": trade.envelopeId, "date": trade.date, "feeling": trade.feeling]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func updateTrade(trade: TradeModel){
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        

        

        let ref = db.collection("Users").document(userID).collection("Trades").document(trade.id)
        var listTagNames = [String]()
        for tag in trade.tag{
            listTagNames.append(tag.name)
        }
        
        
        ref.updateData(["name": trade.name, "value": trade.value, "id": trade.id, "tags": listTagNames, "envelopeId": trade.envelopeId, "date": trade.date, "feeling": trade.feeling]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            
        }
    }
    
    
}
