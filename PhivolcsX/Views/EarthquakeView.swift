import SwiftUI

struct EarthquakeView: View {
    @StateObject private var vm = EarthquakeVM()
    @State private var showError = false
    @State private var searchText: String = ""
    @State private var isResetVisible = false
    @Namespace var namespace
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Earthquakes")
                    .font(.largeTitle)
                    .bold()
                if(!vm.isLoading){
                    Text("Last update: \(vm.lastUpdate.formatted(date: .long, time: .omitted)) \(vm.lastUpdate.formatted(date: .omitted, time: .shortened))")
                        .foregroundStyle(Color.gray)
                    if(vm.hasError){
                        Text("⚠️ \(vm.errorMessage ?? "")")
                            .foregroundStyle(Color.red)
                    }
                }
                if(vm.isLoading){
                    Text("Retrieving data from Phivolcs...")
                }
                
                GlassEffectContainer(spacing: 20){
                    HStack(spacing: 20){
                        TextField("Search...", text: $searchText)
                            .padding(.leading, 15)
                            .padding(.vertical, 5)
                            .font(.system(size: 20))
                            .glassEffectID("SearchText", in: namespace)
                            .glassEffectTransition(.materialize)
                            .glassEffectUnion(id: "searchUnion", namespace: namespace)
                            .glassEffect()
                        
                        if(vm.displayIsFiltered)
                        {
                            Button(action: {
                                vm.resetSearch()
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.red)
                            }
                            .font(.system(size: 20))
                            .buttonStyle(.glass)
                            .glassEffectID("Reset", in: namespace)
                            .glassEffectTransition(.materialize)
                            .glassEffectUnion(id: "searchUnion", namespace: namespace)
                        }
                        Button(action: {
                            Task{ await vm.search(searchText: searchText)}
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                            if(!vm.displayIsFiltered){
                                Text("Search ")
                                    .font(.system(size: 15))
                            }
                        }
                        
                        .buttonStyle(.glass)
                        .glassEffectTransition(.materialize)
                        .glassEffectID("Search", in: namespace)
                    }
                    .animation(.bouncy, value: vm.displayIsFiltered)
                }
                
                List(vm.quakes) { quake in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(quake.date, style: .date)
                                .font(.headline)
                            Text(quake.date, style: .time)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(quake.shortenedLoc)
                                .font(.body)
                            magnitudeView(for: quake.magnitude)
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .refreshable {
                    await vm.refresh()
                }
            }
        }
        .onChange(of: vm.errorMessage) { oldValue, newValue in
            if newValue != nil {
                showError = true
            }
        }
        .task {
            await vm.refresh()
        }
        .padding(30)
    }
}

@ViewBuilder
func magnitudeView(for magnitude: Double) -> some View {
    let formatted = String(format: "%.1f", magnitude)
    switch magnitude {
    case 0..<2.0:
        Text("🟢 \(formatted)")
            .foregroundStyle(.green)
    case 2.0..<4.0:
        Text("🟡 \(formatted)")
            .foregroundStyle(.yellow)
    case 4.0..<6.0:
        Text("🟠 \(formatted)")
            .foregroundStyle(.orange)
    case 6.0..<7.0:
        Text("🔴 \(formatted)")
            .foregroundStyle(.red)
            .bold()
    case 7.0..<8.0:
        Text("⚠️ \(formatted)")
            .foregroundStyle(.red)
            .bold()
    default:
        Text("💀 \(formatted)")
            .foregroundStyle(.purple)
            .bold()
    }
}
