import SwiftUI
private let detents: [PresentationDetent] = [.fraction(0.2), .medium, .large]

struct TapasGrid: View {
  let tapas: [Tapa]
  let location: Location?
  @Binding var selectedItem: Tapa?
  @State private var searchText: String = ""
  @State private var isPresented: Bool = false
  @State private var presentation: PresentationDetent = .fraction(0.25)
  
  
  var body: some View {
    let isSearching = isPresented && !searchText.isEmpty
    let tapas = isSearching ? tapas.filter { $0.title.localizedStandardContains(searchText) } : tapas
    
    return ScrollView {
      ActualGrid(tapas).animation(.smooth, value: tapas)
    }
    .scrollContentBackground(.hidden)
    .presentationDetents(Set(detents), selection: $presentation)
    .presentationBackgroundInteraction(.enabled)
    .presentationBackground(.thinMaterial)
    .interactiveDismissDisabled()
    .searchable(text: $searchText, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .always))
    .onChange(of: isPresented) { presentation = $1 ? detents.last! : detents.first! }
    .toolbarTitleDisplayMode(.inlineLarge)
    .navigationTitle("Tapas")
  }
}

extension TapasGrid {
  func ActualGrid(_ tapas: [Tapa]) -> some View {
    let items: [GridItem] = Array(repeating: .init(.flexible(minimum: 100, maximum: 200)), count: 2)
    return LazyVGrid(columns: items) {
      ForEach(tapas) { tapa in
        Button(action: { selectedItem = tapa }) {
          TapaView(tapa: tapa, location: location)
        }
      }
    }
    .padding(.horizontal)
  }
}
