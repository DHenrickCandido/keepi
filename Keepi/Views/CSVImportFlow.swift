import SwiftUI

struct CSVImportFlow: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var interactor: HomeInteractor
    
    let fileURL: URL
    
    @State private var parsedData: [[String: String]] = []
    @State private var mappedDrafts: [ImportedEntryDraft] = []
    @State private var step: ImportStep = .parsing
    @State private var errorMessage: String?
    
    enum ImportStep {
        case parsing
        case mapping
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    switch step {
                    case .parsing:
                        ProgressView("Parsing CSV...")
                            .onAppear(perform: parseFile)
                    case .mapping:
                        CSVColumnMappingView(
                            parsedData: parsedData,
                            interactor: interactor,
                            onImport: importDrafts,
                            onCancel: { dismiss() }
                        )
                    }
                }
            }
            .navigationTitle("Import CSV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func parseFile() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                _ = fileURL.startAccessingSecurityScopedResource()
                let content = try String(contentsOf: fileURL, encoding: .utf8)
                fileURL.stopAccessingSecurityScopedResource()
                
                let data = CSVParser.parseToDictionaries(content: content)
                
                DispatchQueue.main.async {
                    if data.isEmpty {
                        self.errorMessage = "No valid data found in CSV."
                    } else {
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
        DraftManager.shared.addDrafts(drafts)
        dismiss()
    }
}

struct CSVColumnMappingView: View {
    let parsedData: [[String: String]]
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
    
    var headers: [String] {
        if let keys = parsedData.first?.keys {
            return Array(keys)
        }
        return []
    }
    
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
        formatter.dateFormat = resolvedDateFormat
        
        var generatedDrafts: [ImportedEntryDraft] = []
        var totalRowsProcessed = 0
        
        for row in parsedData {
            guard let dateString = row[selectedDate],
                  let date = formatter.date(from: dateString),
                  let title = row[selectedTitle], !title.isEmpty,
                  let amountString = row[selectedAmount] else { continue }
            
            guard let amountValue = AmountParserService.parseAmount(amountString) else { continue }
            
            let isExpense = negativeIsExpense ? (amountValue < 0) : (amountValue > 0)
            let type: TransactionType = isExpense ? .expense : .income
            let decimalAmount = isExpense ? Decimal(abs(amountValue)) * -1 : Decimal(abs(amountValue))
            
            let category = selectedCategory.isEmpty ? "" : (row[selectedCategory] ?? "")
            let desc = selectedDescription.isEmpty ? "" : (row[selectedDescription] ?? "")
            
            let fingerprint = ImportDuplicateDetector.generateFingerprint(date: date, amount: decimalAmount, title: title)
            
            let draft = ImportedEntryDraft(
                id: UUID(),
                originalTitle: title,
                normalizedMerchant: nil,
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
            totalRowsProcessed += 1
        }
        
        return ImportDuplicateDetector.filterDuplicates(
            drafts: generatedDrafts,
            existingTransactions: interactor.listTransactions,
            existingDrafts: DraftManager.shared.drafts
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Map your columns").font(.headline)) {
                    mappingPicker(title: "Transaction title", selection: $selectedTitle)
                    mappingPicker(title: "Date", selection: $selectedDate)
                    mappingPicker(title: "Amount", selection: $selectedAmount)
                    mappingPicker(title: "Category", selection: $selectedCategory, optional: true)
                    mappingPicker(title: "Description", selection: $selectedDescription, optional: true)
                }
                
                Section(header: Text("How does this file represent expenses?")) {
                    Picker("Expense Direction", selection: $negativeIsExpense) {
                        Text("Negative values are expenses").tag(true)
                        Text("Positive values are expenses").tag(false)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                if case let .ambiguous(options, sample) = dateAmbiguity {
                    Section(header: Text("Is \(sample) ...")) {
                        Picker("Resolve Ambiguity", selection: $resolvedDateFormat) {
                            ForEach(options, id: \.self) { format in
                                Text(formattedSample(format: format, sample: sample)).tag(format)
                            }
                        }
                        .pickerStyle(.inline)
                        .labelsHidden()
                    }
                }
                
                let processedRows = mappedRows
                let newDrafts = processedRows.filter { !$0.isDuplicate }.map { $0.draft }
                let duplicatesCount = processedRows.filter { $0.isDuplicate }.count
                let totalFound = processedRows.count
                let invalidCount = parsedData.count - totalFound
                
                if totalFound > 0 {
                    Section(header: Text("Preview")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(totalFound) rows found")
                                .font(.headline)
                            
                            HStack {
                                Text("\(newDrafts.count) new")
                                    .foregroundColor(.green)
                                Spacer()
                                Text("\(duplicatesCount) possible duplicates")
                                    .foregroundColor(.orange)
                                Spacer()
                                Text("\(invalidCount) invalid")
                                    .foregroundColor(.red)
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                        
                        ForEach(newDrafts.prefix(5)) { t in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(t.originalTitle).font(.headline)
                                    Text(t.date, style: .date).font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                Text(KeepiFormat.currency(t.amount))
                                    .foregroundColor(t.amount < 0 ? .red : .green)
                            }
                        }
                        if newDrafts.count > 5 {
                            Text("... and \(newDrafts.count - 5) more")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
            }
            
            let processedRows = mappedRows
            let newDrafts = processedRows.filter { !$0.isDuplicate }.map { $0.draft }
            
            Button("Import \(newDrafts.count) Entries") {
                onImport(newDrafts)
            }
            .disabled(newDrafts.isEmpty)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(newDrafts.isEmpty ? Color.gray : Color("darkGreenKeepi"))
            .cornerRadius(10)
            .padding()
        }
        .onAppear {
            if let first = headers.first { selectedDate = first }
            if headers.count > 1 { selectedTitle = headers[1] }
            if headers.count > 2 { selectedAmount = headers[2] }
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
}
