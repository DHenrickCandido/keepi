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

struct NewTradeView: View {
    
    @Binding var showNewTrade: Bool // toggle for Modal
    @ObservedObject var tradeListManager: TradeListManager
    @ObservedObject var envelopeListManager: EnvelopeListManager
    
    var tagManager: Tags = Tags()
    @State var selectedEnvelope = ""
    var envelopes: [Keepi.EnvelopeModel] = []
    var envelopeNames: [String] = []
    
    
    // Elements of the trade
    @State var tradeTitle: String = ""
    @State var value: String = ""
    @State var selectedFeeling: Int = 2
    @State var selectedTags: [Tag] = []
    var todayDate = Date()
    
    init(showNewTrade: Binding<Bool>, tradeListManager: TradeListManager, envelopeListManager: EnvelopeListManager, tagManager: Tags = Tags(), selectedEnvelope: String = "", tradeTitle: String = "", value: String = "", selectedFeeling: Int = 2, selectedTags: [Tag] = [], todayDate: Date = Date()) {
        self._showNewTrade = showNewTrade
        self.tradeListManager = tradeListManager
        self.envelopeListManager = envelopeListManager
        self.tagManager = tagManager
        self.selectedEnvelope = selectedEnvelope
        self.tradeTitle = tradeTitle
        self.value = value
        self.selectedFeeling = selectedFeeling
        self.selectedTags = selectedTags
        self.todayDate = todayDate
        
        self.envelopes = envelopeListManager.listaEnvelope
        for envelope in self.envelopes {
            self.envelopeNames.append(envelope.name) // Assuming "name" is the property holding the envelope name
        }
        
        if self.envelopes.isEmpty {
            envelopeNames = ["Any envelope"]
        }
        
        print("aaaaaaaaa--------olhaq")
        print(self.selectedEnvelope)
        self.selectedEnvelope = self.envelopeNames[0]
        
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing:10){
                
                ZStack(){
                    
                    VStack(alignment: .center, spacing: 0) {
                        Text("New Trade")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .onTapGesture {
                        showNewTrade.toggle()
                    }
                    
                }
                
                
                
                VStack(spacing: 32){
                    
                    
                    // Qual sua Troca + TextField
                    VStack (alignment: .leading) {
                        Text("What's your new trade?")
                            .font(.headline)
                            .bold()
                        
                        TradeField(textPlacer: "Ex. Food, Clothes, Transport", item: $tradeTitle, keyboardType: .default)
                        
                    }
                    
                    // Envelope + Qual valor
                    HStack(){
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Envelope")
                                .font(.headline)
                                .bold()
                            HStack(alignment: .center){
                                Picker("Select", selection: $selectedEnvelope) {
                                    ForEach(envelopeNames, id: \.self) {
                                        Text("\($0)                      ")
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(.black)
                
                                
                                
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .cornerRadius(54)
                            .overlay(
                                RoundedRectangle(cornerRadius: 54)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
                            )
                        }
                        .padding(0)
                        .frame(width: 171, alignment: .topLeading)
                        
                        Spacer()
                        VStack(alignment: .leading, spacing:16){
                            QuestionText(text: "What's the value?")
                            
                            TradeField(textPlacer: "Ex.25,00", item: $value, keyboardType: .default)
                                
                            
                        }
                    }
                    
                    // Divider
                    Divider()
                    
                    // Feelings section
                    VStack(alignment: .leading, spacing:24){
                        QuestionText(text: "How you felt with the trade?")
                        HStack{
                            ForEach(FeelingList.getFeelings(), id:\.self) { feeling in

                                let isActiveFeeling = (feeling.index == selectedFeeling)
                                EmotionOption(active: isActiveFeeling, feeling: feeling)
                                    .onTapGesture {
                                        print(selectedTags)
                                        selectedFeeling = feeling.index
                                        print(selectedTags)
                                    }

                                if feeling.index != 4 {
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 24){
                        QuestionText(text: "What was your main motivation?")
                        TagCloudView(selectedTags: $selectedTags)
            
                    }
                }
                .padding(10)
                
                AddTradeButton()
                    .onTapGesture {
                        showNewTrade.toggle()
                        print(tradeTitle)
                        print(value)
                        print(selectedFeeling)
                        print(selectedTags)
                        print(getEnvelopeId())
                    }
                
            }
            .padding(10)
            .onAppear{
                
            }
        }
    }

    
    func QuestionText(text: String) -> some View {
        Text(text)
            .font(.headline)
            .bold()
    }
    
    func getEnvelopeId() -> String {

        for envelope in envelopes {
            print("OLHA AQUI ANDI E DIEGO")
            print(selectedEnvelope)
            print(envelope.name)
            if  selectedEnvelope == envelope.name{
                
                return envelope.id
            }
        }
        
        return self.envelopeNames[0]
    }

    
    func saveTrade() {
        let valueFloat = Float(value)
        let id = tradeTitle.replacingOccurrences(of: " ", with: "") + TradeListManager.date2string(date: todayDate)
        let envelopeId: String = getEnvelopeId()
        
        let compra = TradeModel(id: id, name: tradeTitle, value: valueFloat ?? 0, tag: selectedTags, envelopeId: envelopeId, feeling: selectedFeeling, date: todayDate)
        tradeListManager.addTrade(trade: compra)
        tradeListManager.fetchTrades()
        
        // Fechar a modal
        showNewTrade.toggle()
    }
    
    func AddTradeButton() -> some View {
        HStack(alignment: .top, spacing: 10) {
            QuestionText(text: "Add Trade")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(red: 0.9, green: 0.9, blue: 0.92))
        .cornerRadius(100)
        .onTapGesture {

            saveTrade()
        }
    }
    
    func EmotionOption(active: Bool, feeling: Feeling) -> some View {
        
        Image(feeling.icon)
            .resizable()
            .foregroundColor(.clear)
            .frame(width: 40, height: 40)
            .opacity(active ? 1 : 0.5)
            .cornerRadius(100)
            
    }
    
    func Divider() -> some View {
        VStack(){}
        .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
        .background(Color(red: 0.56, green: 0.56, blue: 0.58))
    }
    
    func TradeField(textPlacer: String, item: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        HStack(alignment: .top, spacing: 10) {
            TextField(textPlacer, text: item)
                .keyboardType(keyboardType)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .cornerRadius(54)
        .overlay(
            RoundedRectangle(cornerRadius: 54)
                .inset(by: 0.5)
                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
        )
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
            .font(Font.custom("SF Pro Text", size: 14))
            .foregroundColor(isSelectedTag(tag: tag) ? .white : Color(red: 0.01, green: 0.01, blue: 0.01))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(isSelectedTag(tag: tag) ? .black : .white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
            )
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


