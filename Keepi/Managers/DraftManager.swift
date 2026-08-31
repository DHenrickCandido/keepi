import Foundation
import SwiftUI

enum DraftStorageError: LocalizedError {
    case encodingFailed
    case writeFailed(Error)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Keepi couldn't prepare the imported entries for storage."
        case .writeFailed:
            return "Keepi couldn't save the imported entries on this device."
        }
    }
}

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
    
    func saveDrafts() throws {
        guard let data = try? JSONEncoder().encode(drafts) else {
            throw DraftStorageError.encodingFailed
        }
        do {
            try data.write(to: draftsFileURL, options: [.atomic, .completeFileProtection])
        } catch {
            throw DraftStorageError.writeFailed(error)
        }
    }
    
    func addDrafts(_ newDrafts: [ImportedEntryDraft]) throws {
        let previousDrafts = drafts
        drafts.append(contentsOf: newDrafts)
        do {
            try saveDrafts()
        } catch {
            drafts = previousDrafts
            throw error
        }
    }
    
    func clearDrafts() throws {
        let previousDrafts = drafts
        drafts = []
        do {
            try saveDrafts()
        } catch {
            drafts = previousDrafts
            throw error
        }
    }

    func deleteAllData() throws {
        do {
            if FileManager.default.fileExists(atPath: draftsFileURL.path) {
                try FileManager.default.removeItem(at: draftsFileURL)
            }
            drafts = []
        } catch {
            throw DraftStorageError.writeFailed(error)
        }
    }
    
    func removeDraft(id: UUID) throws {
        let previousDrafts = drafts
        drafts.removeAll { $0.id == id }
        do {
            try saveDrafts()
        } catch {
            drafts = previousDrafts
            throw error
        }
    }
}
