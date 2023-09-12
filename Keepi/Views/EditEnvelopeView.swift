import SwiftUI
import Combine

struct ExampleEditEnvelope_test: View {
    
    @State private var showNewEnvelope: Bool = false
    
    var body: some View {
        Button("click me") {
            showNewEnvelope.toggle()
        }
        .sheet(isPresented: $showNewEnvelope){
//            NewEnvelopeView(envelopeListManager: envelopeListManager, showNewEnvelope: $showNewEnvelope)
//                .presentationDetents([.fraction(0.9)])
//                .interactiveDismissDisabled()
        }
        .onAppear{
            showNewEnvelope = true
        }
    }
}

struct ExampleEditEnvelope_test_Previews: PreviewProvider {
    static var previews: some View {
        ExampleEditEnvelope_test()
    }
}

struct EditEnvelopeView: View {
    
    @ObservedObject var envelopeListManager: EnvelopeListManager
    
    var selectedEnvelopeIndex: Int
    @Binding var showNewEnvelope: Bool
    
    @State var iconSelected: String = Icons.getIcons()[0]
    @State var envelopeName: String = ""
    @State var envelopeBudget: String = ""
    @State private var selectedTheme = "Dark"
    
    let columns = [GridItem(), GridItem(), GridItem(), GridItem()]
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 40) {
            //Cabeçalho
            ZStack {
                
                HStack {
                    Image(systemName: "xmark")
                        .fontWeight(.bold)
                        .onTapGesture {
                            showNewEnvelope.toggle()
                        }
                    
                    Spacer()
                    
                }
                
                Text("New envelope")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                
            }
            //Fim cabeçalho
            
            //inicio Qual o icone?
            VStack (alignment: .leading, spacing: 24) {
                
                Text("What appearance?")
                    .font(.headline)
                    .fontWeight(.bold)
                
                
                LazyVGrid(columns:columns) {
                    ForEach(Icons.getIcons(), id: \.self) { img in
                        let isActive = ( img == iconSelected )
                        IconEnvelopeOption(img:img, active: isActive)
                            .onTapGesture {
                                iconSelected = img
                                print(iconSelected)
                            }
                        
                    }
                    
                }
//                .padding(.horizontal, 32)
                
            }
            //fim Qual o icone?
            
            //inicio Qual o nome do envelope?
            VStack (alignment: .leading){
                Text("What's the envelope name?")
                    .font(.headline)
                    .fontWeight(.bold)
                
                TextField("Ex. Food, Clothes, Transportation", text: $envelopeName)
                    .font(.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color("lightGrayKeepi"))
                    .cornerRadius(16)
                
                
            }
            //fim Qual o nome do envelope?
            
            //inicio Quanto quer gastar?
            VStack (alignment: .leading){
                Text("How much do you want to spend?")
                    .font(.headline)
                    .fontWeight(.bold)
                
                TextField("Ex. 200.00", text: $envelopeBudget)
                    .font(.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color("lightGrayKeepi"))
                    .cornerRadius(16)
                    .keyboardType(.default)
                    .onReceive(Just(envelopeBudget)) { newValue in
                        let filtered = newValue.filter { "0123456789,.".contains($0) }
                        if filtered != newValue {
                            self.envelopeBudget = filtered
                        }
                    
                        
                        
                    }
                //fim Quanto quer gastar?
                
                
                
                //fim botao continuar
                
            }
            
            Spacer()
            
            //inicio botao continuar
            
            HStack {
                
                Spacer()
                
                Text("Save envelope")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 150, height: 54)
                    .background(Color("darkGreenKeepi"))
                    .cornerRadius(16)
                
            }
        }
        .padding(16)
        .onAppear{
            iconSelected = envelopeListManager.listaEnvelope[selectedEnvelopeIndex].icon
            envelopeName = envelopeListManager.listaEnvelope[selectedEnvelopeIndex].name
            envelopeBudget = String(format: "%.2f", envelopeListManager.listaEnvelope[selectedEnvelopeIndex].budget)
        }
    }
    
    func saveEnvelope() {
        let valueFloat = Float(envelopeBudget)
        let id = envelopeName.replacingOccurrences(of: " ", with: "")

        let envelope = EnvelopeModel(id: id, name: envelopeName, budget: valueFloat ?? 0, icon: iconSelected)
        print(envelope)
//        envelopeListManager.addEnvelope(envelope: envelope) TO-DO: Update envelope
        envelopeListManager.fetchEnvelopes()

        // Fechar a modal
        showNewEnvelope.toggle()
    }


    func AddEnvelopeButton() -> some View {
        HStack(alignment: .top, spacing: 10) {
            QuestionText(text: "Add Envelope")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(red: 0.9, green: 0.9, blue: 0.92))
        .cornerRadius(100)
        .onTapGesture {
            saveEnvelope()
        }
    }
    
    func IconEnvelopeOption(img: String, active: Bool) -> some View {
        Image(img)
            .background(Color("lightGrayKeepi"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: active ? 2 : 0)
                    .foregroundColor(active ? Color("lightGreenKeepi") : Color.clear)
            )
            
    }
}


