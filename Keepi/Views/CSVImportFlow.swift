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
        case preview
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
                        if let firstRow = parsedData.first {
                            CSVColumnMappingView(
                                headers: Array(firstRow.keys),
                                onMap: { dateCol, descCol, amountCol, dateFormat in
                                    mapData(dateCol: dateCol, descCol: descCol, amountCol: amountCol, dateFormat: dateFormat)
                                },
                                onCancel: { dismiss() }
                            )
                        }
                    case .preview:
                        CSVPreviewView(
                            transactions: $mappedTransactions,
                            onConfirm: importTransactions,
                            onCancel: { step = .mapping }
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
    
    private func mapData(dateCol: String, descCol: String, amountCol: String, dateFormat: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        var transactions: [TransactionModel] = []
        
        for row in parsedData {
            guard let dateString = row[dateCol],
                  let date = formatter.date(from: dateString),
                  let desc = row[descCol], !desc.isEmpty,
                  let amountString = row[amountCol] else { continue }
            
            let normalizedAmount = amountString.replacingOccurrences(of: ",", with: ".")
                .replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)
            
            guard let amount = Double(normalizedAmount) else { continue }
            let decimalAmount = Decimal(abs(amount))
            let type: TransactionType = amount < 0 ? .expense : .income
            
            let model = TransactionModel(
                id: TradeIdentity.make(),
                name: desc,
                value: decimalAmount,
                date: date,
                type: type,
                isReviewed: false
            )
            transactions.append(model)
        }
        
        if transactions.isEmpty {
            self.errorMessage = "No rows could be mapped successfully. Check your column choices and date format."
        } else {
            self.mappedTransactions = transactions
            self.step = .preview
        }
    }
    
    private func importTransactions() {
        step = .importing
        
        // Save recursively to avoid overwhelming Firebase/Combine
        var itemsToSave = mappedTransactions
        
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
    let headers: [String]
    let onMap: (String, String, String, String) -> Void
    let onCancel: () -> Void
    
    @State private var selectedDate = ""
    @State private var selectedDesc = ""
    @State private var selectedAmount = ""
    @State private var dateFormat = "dd/MM/yyyy"
    
    let dateFormats = ["dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd"]
    
    var body: some View {
        Form {
            Section(header: Text("Map Columns")) {
                Picker("Date Column", selection: $selectedDate) {
                    Text("Select...").tag("")
                    ForEach(headers, id: \.self) { Text($0).tag($0) }
                }
                
                Picker("Date Format", selection: $dateFormat) {
                    ForEach(dateFormats, id: \.self) { Text($0).tag($0) }
                }
                
                Picker("Description Column", selection: $selectedDesc) {
                    Text("Select...").tag("")
                    ForEach(headers, id: \.self) { Text($0).tag($0) }
                }
                
                Picker("Amount Column", selection: $selectedAmount) {
                    Text("Select...").tag("")
                    ForEach(headers, id: \.self) { Text($0).tag($0) }
                }
            }
            
            Section {
                Button("Preview Import") {
                    onMap(selectedDate, selectedDesc, selectedAmount, dateFormat)
                }
                .disabled(selectedDate.isEmpty || selectedDesc.isEmpty || selectedAmount.isEmpty)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(selectedDate.isEmpty || selectedDesc.isEmpty || selectedAmount.isEmpty ? .gray : .white)
                .padding()
                .background(selectedDate.isEmpty || selectedDesc.isEmpty || selectedAmount.isEmpty ? Color(UIColor.systemGray5) : Color("darkGreenKeepi"))
                .cornerRadius(10)
            }
        }
        .onAppear {
            if let first = headers.first { selectedDate = first }
            if headers.count > 1 { selectedDesc = headers[1] }
            if headers.count > 2 { selectedAmount = headers[2] }
        }
    }
}

struct CSVPreviewView: View {
    @Binding var transactions: [TransactionModel]
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Preview (\(transactions.count) entries)")) {
                    ForEach(transactions) { t in
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
                    .onDelete(perform: delete)
                }
            }
            
            Button("Import \(transactions.count) Entries") {
                onConfirm()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("darkGreenKeepi"))
            .cornerRadius(10)
            .padding()
        }
    }
    
    private func delete(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
    }
}
