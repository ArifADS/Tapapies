import SwiftUI
import CoreLocation

struct ContentView: View {
  let dataSource = RestaurantDataSource()
  @State private var restaurants: [Restaurant] = []
  @State private var location: CLLocation?
  @State private var isPresented: Bool = true
  @State private var selectedItem: Restaurant?
  
  var body: some View {
    RestaurantsMap(restaurants: restaurants, selectedItem: $selectedItem)
      .sheet(isPresented: .constant(true)) {
        RestaurantsList(restaurants)
      }
      .task {
        await searchRestaurants()
      }
  }
  
  func RestaurantsList(_ restaurants: [Restaurant]) -> some View {
    NavigationStack {
      List {
        Section {
          ForEach(restaurants) { restaurant in
            Button(action: { selectedItem = restaurant }) {
              TapaView(tapa: restaurant)
            }
          }
        }
      }
      .navigationTitle("Restaurants")
    }
    .presentationDetents([.fraction(0.25), .medium])
    .presentationBackgroundInteraction(.enabled)
    .interactiveDismissDisabled()
  }
}

extension ContentView {
  func searchRestaurants() async {
    do {
      var rests = try await dataSource.restaurants()
      self.restaurants = rests
      
      let manager = LocationManager()
      let l = try await manager.currentLocation
      self.location = l
    }
    catch {
      print(error)
    }
  }
}


