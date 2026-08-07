import SwiftUI
import Combine

struct EditEnvelopeView: View {
    
    var envelopeListManager: EnvelopeListManager
    
    var selectedEnvelopeIndex: Int
    @Binding var showNewEnvelope: Bool
    
    @State var iconSelected: String = Icons.getIcons()[0]
    @State var envelopeName: String = ""
    @State var envelopeBudget: String = ""
    @State private var originalEnvelopeId: String = ""
    @State private var selectedTheme = "Dark"
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                
                Text("Edit envelope")
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
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color("lightGrayKeepi"))
                    .cornerRadius(16)
                
                
            }
            //fim Qual o nome do envelope?
            
            //inicio Quanto quer gastar?
            VStack (alignment: .leading){
                Text("Monthly budget (optional)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                TextField("Ex. 200.00", text: $envelopeBudget)
                    .font(.callout)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color("lightGrayKeepi"))
                    .cornerRadius(16)
                    .keyboardType(.decimalPad)
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
                
                Text(isSaving ? "Saving..." : "Save envelope")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 150, height: 54)
                    .background(Color("darkGreenKeepi"))
                    .cornerRadius(16)
                    .onTapGesture {
                        saveEnvelope()
                    }
                
            }
        }
        .padding(16)
        .onAppear{
            guard envelopeListManager.listaEnvelope.indices.contains(selectedEnvelopeIndex) else { return }
            let envelope = envelopeListManager.listaEnvelope[selectedEnvelopeIndex]
            originalEnvelopeId = envelope.id
            iconSelected = envelope.icon
            envelopeName = envelope.name
            envelopeBudget = envelope.monthlyBudget != nil ? KeepiFormat.editableAmount(envelope.monthlyBudget!) : ""
        }
        .alert("Couldn't save envelope", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    func saveEnvelope() {
        guard !isSaving else { return }
        
        let valueFloat: Decimal?
        if envelopeBudget.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            valueFloat = nil
        } else if let parsed = CRUDValidation.normalizedDecimal(envelopeBudget) {
            valueFloat = parsed
        } else {
            alertMessage = "Add a valid budget or leave it blank."
            showAlert = true
            return
        }
        
        guard !envelopeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !originalEnvelopeId.isEmpty else { return }

        // We preserve createdAt if it existed, otherwise use now.
        let originalEnvelope = envelopeListManager.listaEnvelope.first { $0.id == originalEnvelopeId }
        let createdAt = originalEnvelope?.createdAt ?? Date()
        
        let envelope = Envelope(id: originalEnvelopeId, name: envelopeName, icon: iconSelected, monthlyBudget: valueFloat, createdAt: createdAt, updatedAt: Date())
        isSaving = true
        envelopeListManager.updateEnvelope(envelope: envelope) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                showNewEnvelope = false
            }
        }
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
