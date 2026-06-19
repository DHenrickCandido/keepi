import SwiftUI

struct AddEntryView: View {
    @EnvironmentObject var interactor: HomeInteractor

    @State private var amount = ""
    @State private var title = ""
    @State private var selectedEnvelope: EnvelopeModel?
    @State private var selectedFeeling = 2
    @State private var step: AddEntryStep = .details
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi")
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    header

                    if step == .details {
                        detailsStep
                    } else {
                        contextStep
                    }
                }
                .padding(16)
            }
            .navigationBarHidden(true)
            .alert("Entry incomplete", isPresented: $showAlert) {
                Button("Got it", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var header: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color("darkGreenKeepi"))
                .roundedCorner(16, corners: [.bottomLeft, .bottomRight])

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    Image("keepi")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)

                    Spacer()

                    Image("keepiMascote")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 84)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Add")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(step == .details ? "Step 1 of 2" : "Step 2 of 2")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
        }
        .frame(height: 180)
    }

    private var detailsStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.headline)
                    .fontWeight(.bold)

                TextField("Ex. 20.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("blackKeepi"))
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.headline)
                    .fontWeight(.bold)

                TextField("Ex. Tea, new shoes...", text: $title)
                    .font(.body)
                    .foregroundColor(Color("blackKeepi"))
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
            }

            Spacer()

            primaryButton(title: "Continue") {
                continueToContext()
            }
        }
    }

    private var contextStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Envelope")
                    .font(.headline)
                    .fontWeight(.bold)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        noEnvelopeCard

                        ForEach(interactor.listEnvelopes) { envelope in
                            envelopeCard(envelope)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Feeling")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    ForEach(FeelingList.getFeelings(), id: \.self) { feeling in
                        feelingOption(feeling)

                        if feeling.index != FeelingList.getFeelings().last?.index {
                            Spacer()
                        }
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
            }

            Spacer()

            VStack(spacing: 12) {
                secondaryButton(title: "Save and reflect later") {
                    saveEntry(reflectionCompleted: false)
                }

                HStack(spacing: 12) {
                    secondaryButton(title: "Back") {
                        step = .details
                    }

                    primaryButton(title: "Save") {
                        saveEntry(reflectionCompleted: true)
                    }
                }
            }
        }
    }

    private var noEnvelopeCard: some View {
        Button {
            selectedEnvelope = nil
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(12)
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color("darkGreenKeepi"))
                    .background(.white)
                    .cornerRadius(8)

                VStack(spacing: 2) {
                    Text("No envelope")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackKeepi"))

                    Text("Attach later")
                        .font(.subheadline)
                        .foregroundColor(Color(.darkGray))
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
        }
        .buttonStyle(.plain)
    }

    private func envelopeCard(_ envelope: EnvelopeModel) -> some View {
        Button {
            selectedEnvelope = envelope
        } label: {
            VStack(spacing: 8) {
                Image(envelope.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
                    .frame(width: 48, height: 48)
                    .background(.white)
                    .cornerRadius(8)

                VStack(spacing: 2) {
                    Text(envelope.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackKeepi"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("$ \(envelope.budget.formatted(.number.precision(.fractionLength(2))))")
                        .font(.subheadline)
                        .foregroundColor(Color(.darkGray))
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
        }
        .buttonStyle(.plain)
    }

    private func feelingOption(_ feeling: Feeling) -> some View {
        Button {
            selectedFeeling = feeling.index
        } label: {
            Image(feeling.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .saturation(selectedFeeling == feeling.index ? 1 : 0)
                .opacity(selectedFeeling == feeling.index ? 1 : 0.5)
        }
        .buttonStyle(.plain)
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(Color("darkGreenKeepi"))
                .cornerRadius(16)
        }
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(Color("darkGreenKeepi"))
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        }
    }

    private func continueToContext() {
        guard CRUDValidation.normalizedDecimal(amount) != nil else {
            alertMessage = "Enter a valid amount greater than zero."
            showAlert = true
            return
        }

        guard CRUDValidation.envelopeId(from: title) != nil else {
            alertMessage = "Add a title for this entry."
            showAlert = true
            return
        }

        step = .context
    }

    private func saveEntry(reflectionCompleted: Bool) {
        guard let value = CRUDValidation.normalizedDecimal(amount),
              let baseId = CRUDValidation.envelopeId(from: title) else {
            alertMessage = "Enter an amount and title before saving."
            showAlert = true
            return
        }

        let date = Date()
        let entry = TradeModel(
            id: baseId + TradeListManager.date2string(date: date),
            name: title.trimmingCharacters(in: .whitespacesAndNewlines),
            value: value,
            tag: [],
            envelopeId: selectedEnvelope?.id ?? "",
            feeling: selectedFeeling,
            date: date,
            reflectionCompleted: reflectionCompleted
        )

        interactor.addTrade(trade: entry)
        resetForm()
    }

    private func resetForm() {
        amount = ""
        title = ""
        selectedEnvelope = nil
        selectedFeeling = 2
        step = .details
    }
}

private enum AddEntryStep {
    case details
    case context
}

struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryView()
            .environmentObject(HomeInteractor(tradeListManager: TradeListManager(), envelopeListManager: EnvelopeListManager()))
    }
}
