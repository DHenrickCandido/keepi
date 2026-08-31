import SwiftUI
import UniformTypeIdentifiers

struct CSVImportLauncherButton<Label: View>: View {
    @EnvironmentObject private var interactor: HomeInteractor
    @EnvironmentObject private var premiumManager: StoreKitPremiumManager

    @State private var showFileImporter = false
    @State private var selectedCSV: URL?
    @State private var showPaywall = false
    @State private var importError = ""
    @State private var showImportError = false

    private let label: () -> Label

    init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label
    }

    var body: some View {
        Button {
            if premiumManager.canUse(.csvImport) {
                showFileImporter = true
            } else {
                showPaywall = true
            }
        } label: {
            label()
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText]
        ) { result in
            switch result {
            case .success(let url):
                selectedCSV = url
            case .failure(let error):
                importError = error.localizedDescription
                showImportError = true
            }
        }
        .sheet(isPresented: Binding(
            get: { selectedCSV != nil },
            set: { if !$0 { selectedCSV = nil } }
        )) {
            if let selectedCSV {
                CSVImportFlow(fileURL: selectedCSV)
                    .environmentObject(interactor)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .alert("Couldn't import statement", isPresented: $showImportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importError)
        }
    }
}

struct CSVImportFlow: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var interactor: HomeInteractor

    let fileURL: URL

    @State private var parsedData: [[String: String]] = []
    @State private var parsedHeaders: [String] = []
    @State private var step: ImportStep = .parsing
    @State private var errorMessage: String?

    enum ImportStep {
        case parsing
        case mapping
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi").ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("Import statement")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("blackKeepi"))
                        Spacer()
                    }
                    .overlay(
                        HStack {
                            Button("Cancel") { dismiss() }
                                .font(.headline)
                                .foregroundColor(Color("darkGreenKeepi"))
                            Spacer()
                        }
                    )
                    .padding()

                    if let errorMessage = errorMessage {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.red)
                            Button("Try again") {
                                self.errorMessage = nil
                                self.step = .parsing
                            }
                            .font(.headline)
                            .foregroundColor(Color("darkGreenKeepi"))
                            Spacer()
                        }
                        .padding()
                    } else {
                        switch step {
                        case .parsing:
                            VStack {
                                Spacer()
                                ProgressView("Reading statement...")
                                Spacer()
                            }
                            .onAppear(perform: parseFile)
                        case .mapping:
                            CSVColumnMappingView(
                                parsedData: parsedData,
                                headers: parsedHeaders,
                                interactor: interactor,
                                onImport: importDrafts,
                                onCancel: { dismiss() }
                            )
                        }
                    }
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func parseFile() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let didAccess = fileURL.startAccessingSecurityScopedResource()
                defer {
                    if didAccess { fileURL.stopAccessingSecurityScopedResource() }
                }
                let content = try String(contentsOf: fileURL, encoding: .utf8)
                let rows = CSVParser.parse(content: content)
                guard let headers = rows.first, !headers.isEmpty else {
                    throw CSVImportError.missingHeaders
                }
                guard Set(headers).count == headers.count else {
                    throw CSVImportError.duplicateHeaders
                }
                let data = CSVParser.parseToDictionaries(content: content)

                DispatchQueue.main.async {
                    if data.isEmpty {
                        self.errorMessage = "No valid data found in CSV."
                    } else {
                        self.parsedHeaders = headers
                        self.parsedData = data
                        self.step = .mapping
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to read file: \(error.localizedDescription)"
                }
            }
        }
    }



    private func importDrafts(drafts: [ImportedEntryDraft]) {
        do {
            try DraftManager.shared.addDrafts(drafts)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private enum CSVImportError: LocalizedError {
    case missingHeaders
    case duplicateHeaders

    var errorDescription: String? {
        switch self {
        case .missingHeaders:
            return "The CSV doesn't contain a header row."
        case .duplicateHeaders:
            return "The CSV contains duplicate column names. Rename them and try again."
        }
    }
}

struct CSVColumnMappingView: View {
    let parsedData: [[String: String]]
    let headers: [String]
    let interactor: HomeInteractor
    let onImport: ([ImportedEntryDraft]) -> Void
    let onCancel: () -> Void

    @State private var selectedDate = ""
    @State private var selectedTitle = ""
    @State private var selectedAmount = ""
    @State private var selectedCategory = ""
    @State private var selectedDescription = ""
    @State private var negativeIsExpense = true
    @State private var dateAmbiguity: DateFormatAmbiguity = .invalid
    @State private var resolvedDateFormat: String = ""

    private func updateDateAmbiguity() {
        guard !selectedDate.isEmpty else {
            dateAmbiguity = .invalid
            resolvedDateFormat = ""
            return
        }
        let dateStrings = parsedData.compactMap { $0[selectedDate] }
        let result = DateParserService.detectFormat(from: dateStrings)
        dateAmbiguity = result

        switch result {
        case .unambiguous(let format):
            resolvedDateFormat = format
        case .ambiguous(let options, _):
            resolvedDateFormat = options.first ?? ""
        case .invalid:
            resolvedDateFormat = ""
        }
    }

    var mappedRows: [ProcessedImportRow] {
        guard !selectedDate.isEmpty, !selectedTitle.isEmpty, !selectedAmount.isEmpty, !resolvedDateFormat.isEmpty else { return [] }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.isLenient = false
        formatter.dateFormat = resolvedDateFormat

        var generatedDrafts: [ImportedEntryDraft] = []
        for row in parsedData {
            guard let dateString = row[selectedDate],
                  let date = formatter.date(from: dateString),
                  let title = row[selectedTitle], !title.isEmpty,
                  let amountString = row[selectedAmount] else { continue }

            guard let amountValue = AmountParserService.parseAmount(amountString) else { continue }

            let isExpense = negativeIsExpense ? (amountValue < 0) : (amountValue > 0)
            let magnitude = amountValue < 0 ? -amountValue : amountValue
            let decimalAmount = isExpense ? -magnitude : magnitude

            let category = selectedCategory.isEmpty ? "" : (row[selectedCategory] ?? "")
            let desc = selectedDescription.isEmpty ? "" : (row[selectedDescription] ?? "")

            let fingerprint = ImportDuplicateDetector.generateFingerprint(date: date, amount: decimalAmount, title: title)

            let draft = ImportedEntryDraft(
                id: UUID(),
                originalTitle: title,
                normalizedMerchant: MerchantNormalizer.normalize(title),
                amount: decimalAmount,
                date: date,
                originalCategory: category,
                description: desc,
                suggestedEnvelopeID: nil,
                feeling: nil,
                spendingIntent: nil,
                reviewStatus: .pending,
                sourceFingerprint: fingerprint
            )
            generatedDrafts.append(draft)
        }

        return ImportDuplicateDetector.filterDuplicates(
            drafts: generatedDrafts,
            existingTransactions: interactor.listTransactions,
            existingDrafts: DraftManager.shared.drafts
        )
    }

    var body: some View {
        let processedRows = mappedRows
        let newDrafts = processedRows.filter { !$0.isDuplicate }.map { $0.draft }
        let duplicatesCount = processedRows.filter { $0.isDuplicate }.count
        let totalFound = processedRows.count
        let invalidCount = parsedData.count - totalFound

        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Map your columns")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("blackKeepi"))

                        VStack(spacing: 12) {
                            mappingPicker(title: "Transaction title", selection: $selectedTitle)
                            mappingPicker(title: "Date", selection: $selectedDate)
                            mappingPicker(title: "Amount", selection: $selectedAmount)
                            mappingPicker(title: "Category", selection: $selectedCategory, optional: true)
                            mappingPicker(title: "Description", selection: $selectedDescription, optional: true)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("How does this file represent expenses?")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("blackKeepi"))

                        Picker("Expense Direction", selection: $negativeIsExpense) {
                            Text("Negative values are expenses").tag(true)
                            Text("Positive values are expenses").tag(false)
                        }
                        .pickerStyle(.menu)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)

                    if case let .ambiguous(options, sample) = dateAmbiguity {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Is \(sample) ...")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("blackKeepi"))

                            Picker("Resolve Ambiguity", selection: $resolvedDateFormat) {
                                ForEach(options, id: \.self) { format in
                                    Text(formattedSample(format: format, sample: sample)).tag(format)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                    }

                    if totalFound > 0 {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Preview")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("blackKeepi"))

                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(totalFound) rows found")
                                    .font(.headline)
                                    .foregroundColor(Color("blackKeepi"))

                                HStack {
                                    Text("\(newDrafts.count) new")
                                        .foregroundColor(Color("darkGreenKeepi"))
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("\(duplicatesCount) possible duplicates")
                                        .foregroundColor(.orange)
                                    Spacer()
                                    Text("\(invalidCount) invalid")
                                        .foregroundColor(.red)
                                }
                                .font(.caption)
                            }

                            Divider()
                                .padding(.vertical, 8)

                            VStack(spacing: 12) {
                                ForEach(newDrafts.prefix(5)) { t in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(t.originalTitle)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("blackKeepi"))
                                            Text(t.date, style: .date)
                                                .font(.caption)
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        Spacer()
                                        Text(KeepiFormat.currency(t.amount < 0 ? -t.amount : t.amount))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("darkGreenKeepi"))
                                    }
                                }
                                if newDrafts.count > 5 {
                                    Text("... and \(newDrafts.count - 5) more")
                                        .foregroundColor(Color(.systemGray))
                                        .font(.caption)
                                        .padding(.top, 4)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                    } else if !selectedDate.isEmpty, !selectedTitle.isEmpty, !selectedAmount.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No importable rows")
                                .font(.headline)
                                .foregroundColor(Color("blackKeepi"))
                            Text(resolvedDateFormat.isEmpty
                                 ? "Keepi couldn't recognize the dates in the selected column."
                                 : "Check the selected columns and expense direction.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                }
                .padding(16)
            }

            Button("Import \(newDrafts.count) Entries") {
                onImport(newDrafts)
            }
            .disabled(newDrafts.isEmpty)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(newDrafts.isEmpty ? Color.gray : Color("darkGreenKeepi"))
            .cornerRadius(16)
            .padding(16)
            .padding(.bottom, 8)
        }
        .onAppear {
            selectedDate = preferredHeader(matching: ["date", "posted", "transaction date"]) ?? ""
            selectedTitle = preferredHeader(matching: ["title", "merchant", "name", "transaction", "payee"], excluding: [selectedDate]) ?? ""
            selectedAmount = preferredHeader(matching: ["amount", "value", "total"], excluding: [selectedDate, selectedTitle]) ?? ""
            selectedCategory = preferredHeader(matching: ["category", "type"], excluding: [selectedDate, selectedTitle, selectedAmount]) ?? ""
            selectedDescription = preferredHeader(matching: ["description", "memo", "note"], excluding: [selectedDate, selectedTitle, selectedAmount, selectedCategory]) ?? ""
            updateDateAmbiguity()
        }
        .onChange(of: selectedDate) { _ in
            updateDateAmbiguity()
        }
    }

    @ViewBuilder
    private func mappingPicker(title: String, selection: Binding<String>, optional: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.gray)
            Picker(title, selection: selection) {
                if optional {
                    Text("None").tag("")
                } else {
                    Text("Select...").tag("")
                }
                ForEach(headers.filter { header in
                    // Prevent same column mapped to multiple required fields
                    let isUsedElsewhere = (!optional && header != selection.wrappedValue) &&
                        (header == selectedDate || header == selectedTitle || header == selectedAmount)
                    return !isUsedElsewhere
                }, id: \.self) {
                    Text($0).tag($0)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }

    private func formattedSample(format: String, sample: String) -> String {
        let sampleFormatter = DateFormatter()
        sampleFormatter.locale = Locale(identifier: "en_US_POSIX")
        sampleFormatter.dateFormat = format
        if let date = sampleFormatter.date(from: sample) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            return displayFormatter.string(from: date)
        }
        return format
    }

    private func preferredHeader(matching candidates: [String], excluding excluded: Set<String> = []) -> String? {
        let normalized = headers
            .filter { !excluded.contains($0) }
            .map { ($0, $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) }
        for candidate in candidates {
            if let exact = normalized.first(where: { $0.1 == candidate }) { return exact.0 }
        }
        for candidate in candidates {
            if let partial = normalized.first(where: { $0.1.contains(candidate) }) { return partial.0 }
        }
        return nil
    }
}
