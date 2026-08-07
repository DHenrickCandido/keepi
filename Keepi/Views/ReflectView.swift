import SwiftUI

struct ReflectView: View {
    @EnvironmentObject var interactor: HomeInteractor

    @State private var selectedPendingIndex = 0
    @State private var selectedFeeling = 2
    @State private var worthIt = true
    @State private var isPlanned = false
    @State private var journalEntry = ""
    @State private var isSaving = false
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""

    private var pendingEntries: [TransactionModel] {
        interactor.listTransactions
            .filter { !$0.reflectionCompleted }
            .sorted { $0.date > $1.date }
    }

    private var currentEntry: TransactionModel? {
        guard pendingEntries.indices.contains(selectedPendingIndex) else {
            return pendingEntries.first
        }

        return pendingEntries[selectedPendingIndex]
    }

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

                VStack(spacing: 24) {


                    if let entry = currentEntry {
                        reflectionForm(for: entry)
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 12)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadCurrentEntry()
            }
            .onChange(of: selectedPendingIndex) { _ in
                loadCurrentEntry()
            }
            .onChange(of: pendingEntries.count) { _ in
                if selectedPendingIndex >= pendingEntries.count {
                    selectedPendingIndex = max(pendingEntries.count - 1, 0)
                }
                loadCurrentEntry()
            }
            .alert("Couldn't save reflection", isPresented: $showSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveErrorMessage)
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
                    Text("Reflect")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("\(pendingEntries.count) pending")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
        }
        .frame(height: 180)
    }

    private func reflectionForm(for entry: TransactionModel) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            entrySummary(entry)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    feelingSection
                    plannedSection
                    worthItSection
                    journalSection
                }
                .padding(.bottom, 12)
            }

            HStack(spacing: 12) {
                secondaryButton(title: "Skip for now") {
                    moveToNextEntry()
                }

                primaryButton(title: "Save") {
                    saveReflection(for: entry)
                }
            }
        }
    }

    private func entrySummary(_ entry: TransactionModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackKeepi"))

                    Text(interactor.getEnvelopeNameById(id: entry.envelopeId))
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }

                Spacer()

                Text(KeepiFormat.currency(entry.value))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("darkGreenKeepi"))
            }

            Text(TransactionListManager.date2string(date: entry.date, dateFormat: "dd MMM"))
                .font(.footnote)
                .foregroundColor(Color(.systemGray))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }

    private var feelingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How do you feel about it now?")
                .font(.headline)
                .fontWeight(.bold)

            HStack {
                ForEach(FeelingList.getFeelings(), id: \.self) { feeling in
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
    }

    private var plannedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Was it planned?")
                .font(.headline)
                .fontWeight(.bold)

            HStack(spacing: 12) {
                choiceButton(title: "Yes", isSelected: isPlanned) {
                    isPlanned = true
                }

                choiceButton(title: "No", isSelected: !isPlanned) {
                    isPlanned = false
                }
            }
        }
    }

    private var worthItSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Would you make this purchase again?")
                .font(.headline)
                .fontWeight(.bold)

            HStack(spacing: 12) {
                choiceButton(title: "Yes", isSelected: worthIt) {
                    worthIt = true
            isPlanned = false
                }

                choiceButton(title: "No", isSelected: !worthIt) {
                    worthIt = false
                }
            }
        }
    }

    private var journalSection: some View {
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
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Image("keepiTrocas")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)

            Text("No pending reflections")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("blackKeepi"))

            Text("Entries you save for later will appear here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.systemGray))

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func choiceButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : Color("darkGreenKeepi"))
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(isSelected ? Color("darkGreenKeepi") : .white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                }
                Text(isSaving ? "Saving..." : title)
                    .font(.body)
                    .fontWeight(.bold)
            }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(Color("darkGreenKeepi"))
                .cornerRadius(16)
        }
        .disabled(isSaving)
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

    private func loadCurrentEntry() {
        guard let entry = currentEntry else {
            selectedFeeling = 2
                        worthIt = true
            isPlanned = false
            journalEntry = ""
            return
        }

        selectedFeeling = entry.feeling
                worthIt = entry.worthIt ?? true
        isPlanned = entry.isPlanned ?? false
        journalEntry = entry.journalEntry.isEmpty ? entry.note : entry.journalEntry
    }

    private func saveReflection(for entry: TransactionModel) {
        guard !isSaving else { return }
        let updatedEntry = TransactionModel(
            id: entry.id,
            name: entry.name,
            value: entry.value,
                        envelopeId: entry.envelopeId,
            feeling: selectedFeeling,
            date: entry.date,
            reflectionCompleted: true,
            worthIt: worthIt,
            isPlanned: isPlanned,
            note: entry.note,
            journalEntry: journalEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        isSaving = true
        interactor.updateTransaction(transaction: updatedEntry) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error {
                    saveErrorMessage = error.localizedDescription
                    showSaveError = true
                    return
                }
                moveToNextEntry()
            }
        }
    }

    private func moveToNextEntry() {
        guard !pendingEntries.isEmpty else { return }
        selectedPendingIndex = min(selectedPendingIndex + 1, max(pendingEntries.count - 1, 0))
    }
}

struct ReflectView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectView()
            .environmentObject(HomeInteractor(transactionListManager: TransactionListManager(), envelopeListManager: EnvelopeListManager()))
    }
}
