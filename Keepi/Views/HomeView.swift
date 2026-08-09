//
//  HomeView.swift
//  Keepi
//
//  Created by Diego Henrick on 30/08/23.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject var transactionModel: TransactionModel
    @EnvironmentObject var interactor: HomeInteractor
    @EnvironmentObject var premiumManager: StoreKitPremiumManager
    
    @State private var showNewTransaction: Bool = false
    @State private var showEditTransaction: Bool = false
    @State private var showReviewInbox: Bool = false
    @State private var showPaywall: Bool = false
    @State var selectedTransaction: Int = 0
    
    @ObservedObject var draftManager = DraftManager.shared
    
    @State private var showNewEnvelope: Bool = false
    @State private var selectedEnvelope: Int = 0
    
    @State var compra = TransactionModel(id: "34", name: "Hey", value: 23)
    
//    @Binding var listTitleEnvelopeName: String
    
    var userName: String = "Jujuba"
    var body: some View {
        NavigationView{
            ZStack {
                
                //Header (logo + mascote)
                VStack {
                    ZStack (alignment: .leading) {
                        Rectangle()
                            .frame(height: 240)
                            .foregroundColor(Color("darkGreenKeepi"))
                            .onChange(of: showEditTransaction, perform: { _ in
                                
                            }) // NAO TIRA ISSO
                            .roundedCorner(16, corners: [.bottomLeft, .bottomRight])
                        
                        
                        
                        HStack (alignment: .top) {
                            Image("keepi")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)
                            
                            Spacer()
                            
//                            NavigationLink{
//                                ReportView()
//                            } label: {
                            Image("keepiMascote")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 120)

//                            }

                        }
                        .padding(.horizontal, 16)
                    }
                    
                    
                    Spacer()
                }.ignoresSafeArea()
                //Fim do Header
                
                
                
                VStack (spacing: 24) {
                    
                    Spacer()
                        .frame(height: 46)
                    
                    //Início Box Envelope
                    VStack (alignment: .leading, spacing: 8) {
                        HStack {
                            Text("My envelopes")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.gray))
                            
                            Spacer()
                        }
                        
                        ScrollView (.horizontal, showsIndicators: false) {
                            HStack {
                                //Inicio Envelope
                                ListaEnvelope(selectedEnvelope: $selectedEnvelope)
                                
                                Button {
                                    showNewEnvelope.toggle()
                                } label: {
                                    NewEnvelopeButtonView()
                                }
                                //Fim envelope
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                    .background(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                    //Fim box envelope
                    
                    if draftManager.drafts.count > 0 {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(draftManager.drafts.count) purchases")
                                    .font(.headline)
                                Text("need reflection")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Review") {
                                if premiumManager.canUse(.reviewInbox) {
                                    showReviewInbox = true
                                } else {
                                    showPaywall = true
                                }
                            }
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("darkGreenKeepi"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                    }
                    
                    if let reflection = WeeklyReflectionEngine.generateReflection(
                        for: interactor.listTransactions,
                        unreviewedDraftsCount: draftManager.drafts.count,
                        envelopes: interactor.listEnvelopes
                    ) {
                        if premiumManager.canUse(.weeklyReflection) {
                            NavigationLink(destination: WeeklyReflectionView(reflection: reflection)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Your weekly reflection is ready")
                                            .font(.headline)
                                            .foregroundColor(Color("blackKeepi"))
                                        Text("See your week")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button {
                                showPaywall = true
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Your weekly reflection is ready")
                                            .font(.headline)
                                            .foregroundColor(Color("blackKeepi"))
                                        HStack(spacing: 4) {
                                            Image(systemName: "lock.fill")
                                                .font(.caption)
                                            Text("Premium")
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(Color("darkGreenKeepi"))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    VStack {
                        //Inicio cabecalho trocas
                        HStack {
                            Text("Last transactions")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            //Inicio botao novas trocas
                            Button {
                                showNewTransaction.toggle()
                            } label: {
                                HStack (spacing: 8) {
                                    Image(systemName: "plus.app.fill")
                                        .font(.title)
                                        .foregroundColor(Color("lightGreenKeepi"))
                                    
                                    Text("New transaction")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color("darkGreenKeepi"))
                                .cornerRadius(16)
                            }
                            
                            
                            //Fim botao novas trocas
                            
                        }
                        //Fim cabeçalho trocas
                        
                        Spacer()
                        
                        VStack (alignment: .center) {
                            if(interactor.listTransactions.count == 0) {
                                Spacer()
                                
                                Image("keepiTrocas")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 186)
                                
                                
                                Spacer()
                            }
                            
                            Spacer()
                            
                            ScrollView (showsIndicators: false){
                                VStack {
                                    
                                    ListaCompra(showEditView: $showEditTransaction, selectedTrade: $selectedTransaction)
                                }
                            }
                            

                        }
                        
                        
                        
                    }
                    
                    
                }
                .padding(16)
                
                
                
            }

            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("lightGrayKeepi"))
//            .onChange(of: transactionListManager.lista.count, perform: { _ in
//                envelopeListManager.fetchEnvelopes()
//            })

            .sheet(isPresented: $showNewTransaction){
                NewTransactionView(showNewTrade: $showNewTransaction, interactor: interactor)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
            }
            .fullScreenCover(isPresented: $showReviewInbox) {
                ReviewInboxView()
            }
            .sheet(isPresented: $showEditTransaction){
                if interactor.listTransactions.indices.contains(selectedTransaction) {
                    EditTransactionView(
                        showEditTransaction: $showEditTransaction,
                        index: selectedTransaction,
                        trade: $interactor.listTransactions[selectedTransaction],
                        selectedIndex: $selectedTransaction)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
                }
            }
            .sheet(isPresented: $showNewEnvelope){
                NewEnvelopeView(showNewEnvelope: $showNewEnvelope)
                    .presentationDetents([.fraction(0.9)])
            }
            .sheet(isPresented: $showPaywall){
                PaywallView()
            }
            .onAppear(){
                anonymous()
            }

        }}
        
//    }
    func anonymous() {

        if Auth.auth().currentUser != nil {
            interactor.loadData()
            return
        }

        Auth.auth().signInAnonymously { authResult, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }

            interactor.loadData()
        }
    }
}

//Estrutura e função para fazer o retangulo ter arredondamento só embaixo
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )

    }
}
//Fim da estrutura e função

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(transactionModel: TransactionModel(id: "3", name: "iFood", value: 25))
                    
    }
}
