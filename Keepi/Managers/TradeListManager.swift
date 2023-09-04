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
        lista.remove(at: indexItem)
    }

    init() {
        fetchTrades()
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
//                    let category = data["category"] as? String ?? ""
                    
                    let trade = TradeModel(name: name, value: value,tag: [Tag(name: "Estava querendo")])
                    self.lista.append(trade)
                }
            }
        }
    }
    
    func date2string(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func addTrade(name: String, value: Float){
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }


        let id = name.replacingOccurrences(of: " ", with: "") + date2string(date: Date())

        let ref = db.collection("Users").document(userID).collection("Trades").document(id)
        
        
        
        ref.setData(["name": name, "value": value, "id": id]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            
        }
    }
    
    
}
