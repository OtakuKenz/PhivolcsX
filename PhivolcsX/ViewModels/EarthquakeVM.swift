import Foundation
import Combine
import SwiftUI

@MainActor
final class EarthquakeVM: ObservableObject {
    @Published var quakes: [Earthquake] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdate: Date = Date.now
    @Published var hasError = false
    @Published var displayIsFiltered = false
    
    private let cacheKey = "cachedQuakes"
    private let cacheDateKey = "cachedQuakesDate"
    
    @Published var quakesOriginal: [Earthquake] = []
    
    private let service: PhivolcsService

    init(service: PhivolcsService = PhivolcsService()) {
        self.service = service
        loadCache()
    }

    func refresh() async {
        isLoading = true
        displayIsFiltered = false
        
        do {
            let data = try await service.fetchLatest()
            quakes = data
            lastUpdate = Date.now
            hasError = data.isEmpty
            quakesOriginal = quakes
        } catch {
            hasError = true
            errorMessage = "Failed to connect to Phivolcs website"
        }
        isLoading = false
    }
    
    func search(searchText: String) async{
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !query.isEmpty else {
            quakes = quakesOriginal
            return
        }
        
        quakes = quakesOriginal.filter { quake in
            // Convert each field to lowercase string and check if query is contained
            let dateString = quake.date.formatted(.dateTime.month().day().year().hour().minute()).lowercased()
            let magnitudeString = String(quake.magnitude).lowercased()
            let locationString = quake.location.lowercased()
            
            return dateString.contains(query) ||
                   magnitudeString.contains(query) ||
                   locationString.contains(query)
        }
        
        displayIsFiltered = true
    }
    
    func resetSearch() {
        quakes = quakesOriginal
        displayIsFiltered = false
    }
    
    private func loadCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cachedQuakes = try? JSONDecoder().decode([Earthquake].self, from: data) {
            quakes = cachedQuakes
            quakesOriginal = quakes
        }
        if let date = UserDefaults.standard.object(forKey: cacheDateKey) as? Date {
            lastUpdate = date
        }
    }
    
    private func saveCache() {
        if let data = try? JSONEncoder().encode(quakes) {
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(lastUpdate, forKey: cacheDateKey)
        }
    }
}
