import SwiftUI

struct AddEntryView: View {
    @EnvironmentObject var interactor: HomeInteractor

    @State private var amount = ""
    @State private var title = ""
    @State private var selectedEnvelope: EnvelopeModel?
    @State private var selectedFeeling = 2
    @State private var transactionType: TransactionType = .expense
    @State private var isPlanned: Bool = false
    @State private var journalEntry = ""
    @State private var selectedPresetTitle: String?
    @State private var step: AddEntryStep = .details
    @State private var showAlert = false
    @State private var showNewEnvelope = false
    @State private var alertMessage = ""
    @State private var isSaving = false

    var body: some View {
        NavigationView {
            ZStack {

                Color("lightGrayKeepi")
                    .ignoresSafeArea()
              VStack {
                  ZStack(alignment: .leading) {
                      Rectangle()
                          .frame(height: 240)
                          .foregroundColor(Color("darkGreenKeepi"))
                          .roundedCorner(16, corners: [.bottomLeft, .bottomRight])

                      HStack(alignment: .top) {
                          Image("keepi")
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                              .frame(height: 40)

                          Spacer()

                          Image("keepiMascote")
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                              .frame(height: 120)
                      }
                      .padding(.horizontal, 16)
                  }

                  Spacer()
              }
              .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 46)
                        if step == .details {
                            detailsStep
                        } else {
                            contextStep
                        }
                    }
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .padding(.horizontal, 12)
            }
            .navigationBarHidden(true)
            .alert("Entry incomplete", isPresented: $showAlert) {
                Button("Got it", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showNewEnvelope) {
                NewEnvelopeView(showNewEnvelope: $showNewEnvelope)
                    .environmentObject(interactor)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
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
        .ignoresSafeArea()
    }

    private var detailsStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            presetSection

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

            VStack(spacing: 12) {
                secondaryButton(title: "Save now, reflect later") {
                    saveFromDetails()
                }

                primaryButton(title: "Continue") {
                    continueToContext()
                }
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

                        addEnvelopeCard
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

            VStack(alignment: .leading, spacing: 8) {
                Text("Was it planned?")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 12) {
                    Button(action: { isPlanned = true }) {
                        Text("Yes")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(isPlanned ? .white : Color("darkGreenKeepi"))
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(isPlanned ? Color("darkGreenKeepi") : .white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                    }

                    Button(action: { isPlanned = false }) {
                        Text("No")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(!isPlanned ? .white : Color("darkGreenKeepi"))
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(!isPlanned ? Color("darkGreenKeepi") : .white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Journal")
                    .font(.headline)
                    .fontWeight(.bold)

                TextField("What do you want to remember about this purchase?", text: $journalEntry, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
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

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Presets")
                .font(.headline)
                .fontWeight(.bold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(EntryPreset.defaults) { preset in
                        presetCard(preset)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func presetCard(_ preset: EntryPreset) -> some View {
        Button {
            applyPreset(preset)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: preset.systemImage)
                    .font(.title2)
                    .foregroundColor(Color("darkGreenKeepi"))
                    .frame(width: 44, height: 44)
                    .background(.white)
                    .clipShape(Circle())

                Text(preset.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(12)
            .frame(width: 118, height: 104)
            .background(Color("lightGrayKeepi"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 1)
                    .stroke(selectedPresetTitle == preset.title ? Color("lightGreenKeepi") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
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

                    Text(KeepiFormat.currency(envelope.budget))
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

    private var addEnvelopeCard: some View {
        Button {
            showNewEnvelope = true
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "plus.app.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color("darkGreenKeepi"))

                Text("Add\nenvelope")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("darkGreenKeepi"))
            }
            .padding(8)
            .frame(width: 142, height: 119)
            .background(Color("lightGrayKeepi"))
            .cornerRadius(16)
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
            buttonLabel(title: title, foregroundColor: .white, backgroundColor: Color("darkGreenKeepi"))
        }
        .disabled(isSaving)
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            buttonLabel(title: title, foregroundColor: Color("darkGreenKeepi"), backgroundColor: .white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        }
        .disabled(isSaving)
    }

    private func buttonLabel(title: String, foregroundColor: Color, backgroundColor: Color) -> some View {
        HStack(spacing: 8) {
            if isSaving {
                ProgressView()
                    .tint(foregroundColor)
            }
            Text(isSaving ? "Saving..." : title)
                .font(.body)
                .fontWeight(.bold)
        }
        .foregroundColor(foregroundColor)
        .frame(maxWidth: .infinity, minHeight: 54)
        .background(backgroundColor)
        .cornerRadius(16)
        .opacity(isSaving ? 0.75 : 1)
    }

    private func applyPreset(_ preset: EntryPreset) {
        title = preset.title
        selectedPresetTitle = preset.title
        selectedEnvelope = matchingEnvelope(for: preset)
        isPlanned = preset.isPlanned
    }

    private func matchingEnvelope(for preset: EntryPreset) -> EnvelopeModel? {
        interactor.listEnvelopes.first { envelope in
            let searchableText = "\(envelope.name) \(envelope.id)".lowercased()
            return preset.envelopeKeywords.contains { searchableText.contains($0.lowercased()) }
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

    private func saveFromDetails() {
        saveEntry(reflectionCompleted: false)
    }

    private func saveEntry(reflectionCompleted: Bool) {
        guard !isSaving else { return }
        guard let value = CRUDValidation.normalizedDecimal(amount),
              CRUDValidation.envelopeId(from: title) != nil else {
            alertMessage = "Enter an amount and title before saving."
            showAlert = true
            return
        }

        let date = Date()
        let entry = TransactionModel(
            id: UUID().uuidString,
            name: title.trimmingCharacters(in: .whitespacesAndNewlines),
            value: value,
            envelopeId: selectedEnvelope?.id ?? "",
            feeling: selectedFeeling,
            date: date,
            reflectionCompleted: reflectionCompleted,
            isPlanned: isPlanned,
            type: transactionType,
            journalEntry: journalEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        isSaving = true
        interactor.addTransaction(transaction: entry) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }

                // Firestore writes are asynchronous, so keep the form intact until the save really succeeds.
                resetForm()
            }
        }
    }

    private func resetForm() {
        amount = ""
        title = ""
        selectedEnvelope = nil
        selectedFeeling = 2
        isPlanned = false
        transactionType = .expense
        journalEntry = ""
        selectedPresetTitle = nil
        step = .details
    }
}

private enum AddEntryStep {
    case details
    case context
}

private struct EntryPreset: Identifiable {
    let title: String
    let systemImage: String
    let envelopeKeywords: [String]
    let isPlanned: Bool

    var id: String { title }

    static let defaults: [EntryPreset] = [
        EntryPreset(title: "Coffee", systemImage: "cup.and.saucer.fill", envelopeKeywords: ["coffee", "food", "cafe", "meal"], isPlanned: false),
        EntryPreset(title: "Lunch", systemImage: "fork.knife", envelopeKeywords: ["lunch", "food", "meal", "restaurant"], isPlanned: true),
        EntryPreset(title: "Groceries", systemImage: "cart.fill", envelopeKeywords: ["groceries", "grocery", "market", "food"], isPlanned: true),
        EntryPreset(title: "Delivery", systemImage: "takeoutbag.and.cup.and.straw.fill", envelopeKeywords: ["delivery", "ifood", "food", "restaurant"], isPlanned: false),
        EntryPreset(title: "Transport", systemImage: "bus.fill", envelopeKeywords: ["transport", "transportation", "uber", "bus", "car"], isPlanned: true),
        EntryPreset(title: "Bill", systemImage: "doc.text.fill", envelopeKeywords: ["bill", "bills", "home", "utilities"], isPlanned: true),
        EntryPreset(title: "Gift", systemImage: "gift.fill", envelopeKeywords: ["gift", "gifts", "friends"], isPlanned: true),
        EntryPreset(title: "Fun", systemImage: "sparkles", envelopeKeywords: ["fun", "entertainment", "leisure", "hobby"], isPlanned: false)
    ]
}

struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryView()
            .environmentObject(HomeInteractor(transactionListManager: TransactionListManager(), envelopeListManager: EnvelopeListManager()))
    }
}
