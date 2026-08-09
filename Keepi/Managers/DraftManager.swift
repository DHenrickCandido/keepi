import Foundation
import SwiftUI

class DraftManager: ObservableObject {
    static let shared = DraftManager()
    @Published var drafts: [ImportedEntryDraft] = []
    
    private let draftsFileURL: URL
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        draftsFileURL = documentsDirectory.appendingPathComponent("keepi_drafts.json")
        loadDrafts()
    }
    
    func loadDrafts() {
        guard let data = try? Data(contentsOf: draftsFileURL),
              let decoded = try? JSONDecoder().decode([ImportedEntryDraft].self, from: data) else {
            drafts = []
            return
        }
        drafts = decoded
    }
    
    func saveDrafts() {
        guard let data = try? JSONEncoder().encode(drafts) else { return }
        try? data.write(to: draftsFileURL)
    }
    
    func addDrafts(_ newDrafts: [ImportedEntryDraft]) {
        drafts.append(contentsOf: newDrafts)
        saveDrafts()
    }
    
    func clearDrafts() {
        drafts = []
        saveDrafts()
    }
}
