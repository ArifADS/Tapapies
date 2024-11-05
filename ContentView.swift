import SwiftUI

struct ContentView: View {
  let dataSource = DataSource()
  @State private var tapas: [Tapa] = []
  @State private var location: Location?
  @State private var selectedItem: Tapa?
  
  var body: some View {
    TapasMap(tapas: tapas, selectedItem: $selectedItem)
      .sheet(isPresented: .constant(true)) {
        RestaurantsList(tapas)
      }
      .onLocationUpdate { location = $0 }
      .task { await searchRestaurants() }
  }
  
  func RestaurantsList(_ tapas: [Tapa]) -> some View {
    let tapas = location?.sorting(tapas) ?? tapas
    
    return NavigationStack {
      TapasGrid(tapas: tapas, location: location, selectedItem: $selectedItem.animation())
//        .toolbar { Button("Copy") { pasteAction() } }
    }
  }
}

extension ContentView {
  func pasteAction() {
    guard let str = dataSource.tapasData(tapas) else { return }
    UIPasteboard.general.string = str
    print(str)
  }
  
  func searchRestaurants() async {
    do {
      self.tapas = try await dataSource.tapas
    }
    catch {
      print(error)
    }
  }
}
