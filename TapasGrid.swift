import SwiftUI
import CoreLocation

struct TapasGrid: View {
  let tapas: [Restaurant]
  let location: CLLocation?
  @Binding var selectedItem: Restaurant?
  @State private var searchText: String = ""
  @State private var isPresented: Bool = false
  @State private var presentation: PresentationDetent = .fraction(0.25)
  
  
  var body: some View {
    let isSearching = isPresented && !searchText.isEmpty
    let tapas = isSearching ? tapas.filter { $0.title.localizedStandardContains(searchText) } : tapas
    
    return ScrollView {
      ActualGrid(tapas).animation(.bouncy, value: tapas)
    }
    .scrollContentBackground(.hidden)
    .presentationDetents([.fraction(0.25), .medium, .large], selection: $presentation)
    .presentationBackgroundInteraction(.enabled)
    .presentationBackground(.thinMaterial)
    .interactiveDismissDisabled()
    .searchable(text: $searchText, isPresented: $isPresented, placement: .toolbar, prompt: Text("Search Tapas"))
    .searchPresentationToolbarBehavior(.avoidHidingContent)
    .onChange(of: isPresented) { presentation = $1 ? .large : .fraction(0.25) }
  }
}

extension TapasGrid {
  func ActualGrid(_ tapas: [Restaurant]) -> some View {
    let items: [GridItem] = Array(repeating: .init(.flexible(minimum: 100, maximum: 200)), count: 2)
    return LazyVGrid(columns: items) {
      ForEach(tapas) { tapa in
        Button(action: { selectedItem = tapa }) {
          TapaView(tapa: tapa, location: location)
        }
      }
    }
    .padding()
  }
}
