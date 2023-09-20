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
    
    func removeTrade(indexItem: Int){
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let valor = self.lista[indexItem].value

        let refEnvelope = db.collection("Users").document(userID).collection("Envelopes").document(lista[indexItem].envelopeId)
        var envelopeBudget: Float = 0

        refEnvelope.getDocument { (document, error) in

            guard error == nil else {
                print("error", error ?? "")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    print("data", data)
                    envelopeBudget = data["budget"] as? Float ?? 0
                    refEnvelope.updateData(["budget": (envelopeBudget + valor)]) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
            }
            self.lista.remove(at: indexItem)
            self.subject.send(self.lista)
        }
            

        
        
        db.collection("Users").document(userID).collection("Trades").document(lista[indexItem].id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        
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

        let ref = db.collection("Users").document(userID).collection("Trades").order(by: "date", descending: true)

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
                self.subject.send(self.lista)
            }
        }
    }
    

    
    func addTrade(trade: TradeModel){
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
            
        let ref = db.collection("Users").document(userID).collection("Trades").document(trade.id)
        
        let refEnvelope = db.collection("Users").document(userID).collection("Envelopes").document(trade.envelopeId)
        var envelopeBudget: Float = 0
        refEnvelope.getDocument { (document, error) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    print("data", data)

                    envelopeBudget = data["budget"] as? Float ?? 0
                    refEnvelope.updateData(["budget": (envelopeBudget - trade.value)]) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        
                    }

                }
            }
            self.lista.insert(trade, at: 0)
            self.subject.send(self.lista)
        }

        
        

            
        
        
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
        print("BBB TRADE PURIN \(trade)")

        

        let ref = db.collection("Users").document(userID).collection("Trades").document(trade.id)
        var listTagNames = [String]()
        for tag in trade.tag{
            listTagNames.append(tag.name)
        }
        
        let refEnvelope = db.collection("Users").document(userID).collection("Envelopes").document(trade.envelopeId)
        var envelopeBudget: Float = 0
        refEnvelope.getDocument { (document, error) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    print("data", data)
                    envelopeBudget = data["budget"] as? Float ?? 0
                    
                    var tradeOldValue: Float = 0
                    var tradeNewValue: Float = 0
                    print("CUUU ENVELOPE BUDGET\(envelopeBudget)")
                    ref.getDocument { (document, error) in
                        guard error == nil else {
                            print("error", error ?? "")
                            return
                        }
                        if let document = document, document.exists {
                            let data = document.data()
                            if let data = data {
                                print("data", data)
                                tradeOldValue = data["value"] as? Float ?? 0
                                print("CUUU ENVELOPE BUDGET\(tradeOldValue)")
                                print("CUUU ENVELOPE TRADE VALUE\(trade.value)")

                                tradeNewValue = trade.value - tradeOldValue
                                print("CUUU ENVELOPE BUDGET\(tradeNewValue)")
                                print("CUUU ENVELOPE BUDGET\(envelopeBudget)")

                                refEnvelope.updateData(["budget": (envelopeBudget - tradeNewValue)]) { error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    }
                                    
                                }
                                 
                                ref.updateData(["name": trade.name, "value": trade.value, "id": trade.id, "tags": listTagNames, "envelopeId": trade.envelopeId, "date": trade.date, "feeling": trade.feeling]) { error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    }
                                }

                                print("BBB \(self.lista)")
//                                guard let i = self.lista.firstIndex( where: { t in
//                                    t.id == trade.id
//                                }) else { return }
                                for (index, element) in self.lista.enumerated() {
                                    if element.id == trade.id {
                                        self.lista[index] = trade
                                        print("BBB INDEX \(element)")
                                        print("BBB INDEX \(trade)")
                                        print("BBB INDEX \(index)")

                                        break // Para após encontrar o elemento
                                    }
                                }
//                                self.lista[i] = trade
                                print("BBB \(self.lista)")
                                self.subject.send(self.lista)

                            }
                        }
                    }
                    
                    

                }
            }
        }
        
        

    }
    
    
    
}
