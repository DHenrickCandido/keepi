import SwiftUI
import Combine

/*
    TO-DO: Add envelo
*/

struct Example: View {
    
    @State private var showNewTrade: Bool = false
    
    
    var body: some View {
        Button("click me") {
            showNewTrade.toggle()
        }
        .sheet(isPresented: $showNewTrade){
//            NewTradeView(showNewTrade: $showNewTrade)
//                .presentationDetents([.fraction(0.9)])
//                .interactiveDismissDisabled()
                
        }
        .onAppear{
            showNewTrade = true
        }
    }
}

struct Example_Previews: PreviewProvider {
    static var previews: some View {
        Example()
    }
}

enum steps {
    case firstStep
    case secondStep
}

struct NewTradeView: View {
    
    @Binding var showNewTrade: Bool // toggle for Modal
    
    var interactor: HomeInteractor
    var tagManager: Tags = Tags()
    @State var selectedEnvelope: EnvelopeModel!
    
    
    // Elements of the trade
    @State var tradeTitle: String = ""
    @State var value: String = ""
    @State var selectedFeeling: Int = 2
    @State var selectedTags: [Tag] = []
    var todayDate = Date()
    
    @State var stepsIndicator: steps = .firstStep
    @State var showAlert = false
    @State private var alertMessage = "Enter a valid title and amount before continuing."
    
    init(showNewTrade: Binding<Bool>, interactor: HomeInteractor, tagManager: Tags = Tags(), tradeTitle: String = "", value: String = "", selectedFeeling: Int = 2, selectedTags: [Tag] = [], todayDate: Date = Date()) {
        self._showNewTrade = showNewTrade
        self.interactor = interactor
        self.tagManager = tagManager
        
        self.tradeTitle = tradeTitle
        self.value = value
        self.selectedFeeling = selectedFeeling
        self.selectedTags = selectedTags
        self.todayDate = todayDate
        
        self.selectedEnvelope = interactor.listEnvelopes.first
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40){
            
            if(stepsIndicator == .firstStep){
                FirstStep()
                    
            } else if (stepsIndicator == .secondStep ) {
                SecondStep()
            }
        
        }
        .padding(16)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Entry incomplete"), message: Text(alertMessage), dismissButton: .default(Text("Got it!")))
        }
    }
    
    func FirstStep() -> some View {
        Group{
            // Cabeçalho
            ZStack {
                
                HStack {
                    Image(systemName: "xmark")
                        .fontWeight(.bold)
                        .onTapGesture {
                            showNewTrade.toggle()
                        }
                    
                    Spacer()
                    
                    Text("Step 1 of 2")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
                
                Text("New trade")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                
            }
            
            //inicio Qual envelope?
            VStack (alignment: .leading) {
                QuestionText(text: "Which envelope?")
                ScrollView (.horizontal) {
                    HStack {
                        NoEnvelopeCard()

                        ForEach(Array(interactor.listEnvelopes.enumerated()), id: \.element.id) { index, item in
                            EnvelopeCard(envelope: item)
                        }
                        
                        AddEnvelopeButton()
                        
                    }
                    
                }.scrollIndicators(.hidden)
                
                
            }
            //Fim qual envelope?
        
            TradeField(
                question: "What's your new trade?",
                textPlacer: "Ex. Tea, new shoes...",
                item: $tradeTitle,
                keyboardType: .default
            )
            
            TradeField(
                question: "What's the value?",
                textPlacer: "Ex.20,00",
                item: $value,
                keyboardType: .decimalPad
            )
            
            Spacer()
            
            NextButton()
        }
        .onAppear{
            if selectedEnvelope == nil && !interactor.listEnvelopes.isEmpty {
                selectedEnvelope = interactor.listEnvelopes.first
            }
        }
    }
    
    func SecondStep() -> some View {
        Group{
            // Cabeçalho
            ZStack {
                
                HStack {
                    Image(systemName: "xmark")
                        .fontWeight(.bold)
                        .onTapGesture {
                            showNewTrade.toggle()
                        }
                    
                    Spacer()
                    
                    Text("Step 2 of 2")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
                
                Text("New trade")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                
            }
            
            //Inicio como voce se sentiu?
            VStack (alignment: .leading) {
                Text("How did you feel?")
                    .font(.headline)
                .fontWeight(.bold)
                
                HStack {
                    ForEach(FeelingList.getFeelings(), id:\.self) { feeling in

                        EmotionOption(active: (feeling.index == selectedFeeling) , feeling: feeling)
                            .onTapGesture {
                                selectedFeeling = feeling.index
                            }

                        if feeling.index != 4 {
                            Spacer()
                        }
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color("lightGrayKeepi"))
                .cornerRadius(16)
            }
            //Fim como voce se sentiu?
            VStack(alignment: .leading){
                QuestionText(text: "What's your main motivation?")
                TagCloudView(selectedTags: $selectedTags)
            }
            
            Spacer()
            
            AddTradeButton()
        }
    }
    
    func NoEnvelopeCard() -> some View {
        VStack {
            Image(systemName: "tray")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(12)
                .frame(width: 48, height: 48)
                .foregroundColor(Color("darkGreenKeepi"))
                .background(.white)
                .cornerRadius(8)
            
            VStack {
                Text("No envelope")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                
                Text("Attach later")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.darkGray))
            }
        }
        .padding(8)
        .frame(width: 142, height: 119)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
            .inset(by: 1)
            .stroke(selectedEnvelope == nil ? Color("lightGreenKeepi") : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            selectedEnvelope = nil
        }
    }

    func EnvelopeCard(envelope: EnvelopeModel) -> some View {
        VStack {
            Image(envelope.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: 48, height: 48)
                .background(.white)
                .cornerRadius(8)
            
            VStack {
                Text(envelope.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                
                Text("$ \(envelope.budget.formatted(.number.precision(.fractionLength(2))))")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.darkGray))
            }
        }
        .padding(8)
        .frame(width: 142, height: 119)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
            .inset(by: 1)
            .stroke(selectedEnvelope == envelope ? Color("lightGreenKeepi") : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            selectedEnvelope = envelope
        }
    }

    func AddEnvelopeButton() -> some View {
        VStack {
            Image(systemName: "plus.app.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: 48, height: 48)
                .foregroundColor(Color("darkGreenKeepi"))
                .cornerRadius(8)
            
            VStack {
                Text("Add\nenvelope")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("darkGreenKeepi"))
                
            }
        }
        .padding(8)
        .frame(width: 142, height: 119)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
        .onTapGesture {
            alertMessage = "Create envelopes from the Today or Entries envelope list before attaching one here."
            showAlert = true
        }
    }
    
    func NextButton() -> some View {
        HStack {
            
            Spacer()
            
            Text("Continue")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 150, height: 54)
                .background(Color("darkGreenKeepi"))
                .cornerRadius(16)
                .onTapGesture {
                    guard CRUDValidation.normalizedDecimal(value) != nil,
                          CRUDValidation.envelopeId(from: tradeTitle) != nil else {
                        alertMessage = "Enter a valid title and amount before continuing."
                        showAlert = true
                        return
                    }

                    stepsIndicator = .secondStep
                }
            
        }
    }
    
    func QuestionText(text: String) -> some View {
        Text(text)
            .font(.headline)
            .bold()
    }
    
    func saveTrade() {
        guard let valueFloat = CRUDValidation.normalizedDecimal(value),
              let baseId = CRUDValidation.envelopeId(from: tradeTitle) else {
            showAlert = true
            return
        }
        let id = baseId + TradeListManager.date2string(date: todayDate)
        let envelopeId = selectedEnvelope?.id ?? ""
        
        let compra = TradeModel(id: id, name: tradeTitle, value: valueFloat, tag: selectedTags, envelopeId: envelopeId, feeling: selectedFeeling, date: todayDate)
        interactor.addTrade(trade: compra) { error in
            DispatchQueue.main.async {
                if let error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }

                showNewTrade.toggle()
            }
        }
    }
    
    func AddTradeButton() -> some View {
        HStack {
            Spacer()
            
            Text("Save trade")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 150, height: 54)
                .background(Color("darkGreenKeepi"))
                .cornerRadius(16)
                .onTapGesture {
                    saveTrade()
                }
            
        }
        
    }
    
    func EmotionOption(active: Bool, feeling: Feeling) -> some View {
            
        Image(feeling.icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .saturation(active ? 1 : 0)
            .opacity(active ? 1 : 0.5)
    }
    
    func TradeField(question: String, textPlacer: String, item: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        
        VStack (alignment: .leading) {
            Text(question)
                .font(.headline)
                .bold()
            
            HStack(alignment: .top, spacing: 10) {
                TextField(textPlacer, text: item)
                    .keyboardType(keyboardType)
                    .font(.callout)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color("lightGrayKeepi"))
                    .cornerRadius(16)
            }
            
            
        }
        
        
        
    }
    
}

struct TagCloudView: View {
    let tags = Tags.getTags()
    @Binding var selectedTags: [Tag]

    @State private var totalHeight = CGFloat.zero       // << variant for ScrollView/List
    //    = CGFloat.infinity   // << variant for VStack

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                TagOption(tag: tag)
                    .padding([.trailing, .bottom], 9)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }
    
    func isSelectedTag(tag: Tag) -> Bool{
        if selectedTags.firstIndex(of: tag) != nil {
            if self.selectedTags.contains(tag){
                return true
            }
        }
        return false
    }

    func TagOption(tag: Tag) -> some View {
        
        Text(tag.name)
            .font(.body)
            .fontWeight(isSelectedTag(tag: tag) ? .bold : .regular)
            .foregroundColor(isSelectedTag(tag: tag) ? .white : Color("darkGreenKeepi"))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(isSelectedTag(tag: tag) ? Color("darkGreenKeepi") : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(isSelectedTag(tag: tag) ? Color.clear : Color("darkGreenKeepi") )
                
            )
            .cornerRadius(16)
            .onTapGesture {
                if isSelectedTag(tag: tag){
                    if let index = selectedTags.firstIndex(of: tag){
                        selectedTags.remove(at: index)
                    }
                } else {
                    selectedTags.append(tag)
                }
                
            }
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}


