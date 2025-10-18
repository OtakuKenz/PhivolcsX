import Foundation
import SwiftSoup

final class PhivolcsService: Sendable {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    // Public async method to get earthquakes
    func fetchLatest() async throws -> [Earthquake] {
        let url = URL(string: "https://earthquake.phivolcs.dost.gov.ph")! // replace with exact page/endpoint
        let (data, _) = try await session.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            return []
        }
        return try parseHTML(html)
    }

    // Parse with SwiftSoup — you'll need to adapt selectors to the actual PHIVOLCS page
    private func parseHTML(_ html: String) throws -> [Earthquake] {
        var results = [Earthquake]()
        let doc = try SwiftSoup.parse(html)

        // Example: find a table or list of quakes
        // Update selector according to actual page structure
        let tables = try doc.select("table.MsoNormalTable")
        let rows = try tables[2].select("tbody tr")
        for row in rows.array() {
            let cols = try row.select("td")
            
            guard cols.size() >= 3 else { continue }

            let dateStr = try cols.get(0).text()
            let magStr  = try cols.get(4).text()
            let loc     = try cols.get(5).text()
            // parse date & magnitude according to the site's format
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy - hh:mm a" // e.g. 18 October 2025 - 02:23 PM

            let date = formatter.date(from: dateStr) ?? Date()
            let magnitude = Double(magStr) ?? 0.0
            
            let shortenedLoc = cleanLocation(loc)

            let quake = Earthquake(date: date, magnitude: magnitude, location: loc, shortenedLoc: shortenedLoc)
            results.append(quake)
        }
        return results
    }
    
    private func cleanLocation(_ location: String) -> String {
        if let range = location.range(of: " of ") {
            return String(location[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        }
        return location.trimmingCharacters(in: .whitespaces)
    }
}

