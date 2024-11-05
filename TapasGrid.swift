import SwiftUI
private let detents: [PresentationDetent] = [.height(320), .large]

struct TapasGrid: View {
  let tapas: [Tapa]
  let location: Location?
  @Binding var selectedItem: Tapa?
  @State private var searchText: String = ""
  @State private var isPresented: Bool = false
  @State private var presentation: PresentationDetent = detents.first!
  
  
  var body: some View {
    let isSearching = isPresented && !searchText.isEmpty
    let tapas = isSearching ? tapas.filter { $0.title.localizedStandardContains(searchText) } : tapas
    let showEmpty = tapas.isEmpty && isSearching
    
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
    .overlay { EmptyTapas(show: showEmpty) }
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
  
  @ViewBuilder
  func EmptyTapas(show: Bool) -> some View {
    if show {
      ContentUnavailableView.search(text: searchText)
    }
  }
}
