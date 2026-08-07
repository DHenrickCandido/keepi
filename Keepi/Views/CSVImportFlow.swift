import SwiftUI

struct CSVImportFlow: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var interactor: HomeInteractor
    
    let fileURL: URL
    
    @State private var parsedData: [[String: String]] = []
    @State private var mappedTransactions: [TransactionModel] = []
    @State private var step: ImportStep = .parsing
    @State private var errorMessage: String?
    
    enum ImportStep {
        case parsing
        case mapping
        case importing
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
                            onImport: importTransactions,
                            onCancel: { dismiss() }
                        )
                    case .importing:
                        ProgressView("Importing entries into Review Inbox...")
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
    

    
    private func importTransactions(transactions: [TransactionModel]) {
        self.mappedTransactions = transactions
        step = .importing
        
        // Save recursively to avoid overwhelming Firebase/Combine
        var itemsToSave = transactions
        
        func saveNext() {
            guard !itemsToSave.isEmpty else {
                DispatchQueue.main.async {
                    dismiss()
                }
                return
            }
            
            let item = itemsToSave.removeFirst()
            interactor.addTransaction(transaction: item) { _ in
                saveNext()
            }
        }
        
        saveNext()
    }
}

struct CSVColumnMappingView: View {
    let parsedData: [[String: String]]
    let onImport: ([TransactionModel]) -> Void
    let onCancel: () -> Void
    
    @State private var selectedDate = ""
    @State private var selectedTitle = ""
    @State private var selectedAmount = ""
    @State private var selectedCategory = ""
    @State private var selectedDescription = ""
    @State private var dateFormat = "dd/MM/yyyy"
    
    let dateFormats = ["dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd"]
    
    var headers: [String] {
        if let keys = parsedData.first?.keys {
            return Array(keys)
        }
        return []
    }
    
    var mappedTransactions: [TransactionModel] {
        guard !selectedDate.isEmpty, !selectedTitle.isEmpty, !selectedAmount.isEmpty else { return [] }
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        var transactions: [TransactionModel] = []
        
        for row in parsedData {
            guard let dateString = row[selectedDate],
                  let date = formatter.date(from: dateString),
                  let title = row[selectedTitle], !title.isEmpty,
                  let amountString = row[selectedAmount] else { continue }
            
            let normalizedAmount = amountString.replacingOccurrences(of: ",", with: ".")
                .replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)
            
            guard let amount = Double(normalizedAmount) else { continue }
            let decimalAmount = Decimal(abs(amount))
            let type: TransactionType = amount < 0 ? .expense : .income
            
            let category = selectedCategory.isEmpty ? "" : (row[selectedCategory] ?? "")
            let desc = selectedDescription.isEmpty ? "" : (row[selectedDescription] ?? "")
            
            let model = TransactionModel(
                id: TradeIdentity.make(),
                name: title,
                value: decimalAmount,
                date: date,
                type: type,
                isReviewed: false,
                note: category,
                journalEntry: desc
            )
            transactions.append(model)
        }
        return transactions
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Map your columns").font(.headline)) {
                    mappingPicker(title: "Transaction title", selection: $selectedTitle)
                    mappingPicker(title: "Date", selection: $selectedDate)
                    
                    Picker("Date Format", selection: $dateFormat) {
                        ForEach(dateFormats, id: \.self) { Text($0).tag($0) }
                    }
                    
                    mappingPicker(title: "Amount", selection: $selectedAmount)
                    mappingPicker(title: "Category", selection: $selectedCategory, optional: true)
                    mappingPicker(title: "Description", selection: $selectedDescription, optional: true)
                }
                
                let previewItems = mappedTransactions
                if !previewItems.isEmpty {
                    Section(header: Text("Preview (\(previewItems.count) entries)")) {
                        ForEach(previewItems.prefix(5)) { t in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(t.name).font(.headline)
                                    Text(t.date, style: .date).font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                Text(KeepiFormat.currency(t.value))
                                    .foregroundColor(t.type == .expense ? .red : .green)
                            }
                        }
                        if previewItems.count > 5 {
                            Text("... and \(previewItems.count - 5) more")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
            }
            
            let previewItems = mappedTransactions
            Button("Import \(previewItems.count) Entries") {
                onImport(previewItems)
            }
            .disabled(previewItems.isEmpty)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(previewItems.isEmpty ? Color.gray : Color("darkGreenKeepi"))
            .cornerRadius(10)
            .padding()
        }
        .onAppear {
            if let first = headers.first { selectedDate = first }
            if headers.count > 1 { selectedTitle = headers[1] }
            if headers.count > 2 { selectedAmount = headers[2] }
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
}
