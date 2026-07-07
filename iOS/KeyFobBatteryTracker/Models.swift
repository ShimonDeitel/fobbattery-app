import Foundation

struct Fob: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String        // Fob name
    var detail: String      // Battery type
    var date: Date           // Replaced date
    var note: String = ""
}
