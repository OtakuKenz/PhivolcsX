import SwiftUI

struct MainView: View {
    // Selected view enum
    enum Destination: Hashable {
        case earthquakes, about
    }
    
    @State private var selection: Destination? = .earthquakes
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink("Earthquakes", value: Destination.earthquakes)
                NavigationLink("About", value: Destination.about)
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("PhivolcsX")
        } detail: {
            // Show content based on selection
            switch selection {
            case .earthquakes:
                EarthquakeView()
            case .about:
                AboutView()
            case .none:
                Text("Select a view")
            }
        }
    }
}

#Preview {
    MainView()
}
