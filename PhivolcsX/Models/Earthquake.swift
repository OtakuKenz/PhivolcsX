import Foundation

struct Earthquake: Codable, Identifiable{
    var id = UUID()
    let date: Date
    let magnitude: Double
    let location: String
    let shortenedLoc: String
}
