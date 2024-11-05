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
      .onLocationUpdate { location = $0 }
      .task { await searchRestaurants() }
  }
  
  func RestaurantsList(_ restaurants: [Restaurant]) -> some View {
    let tapas = self.location.map { l in restaurants.sorted {
      $0.location.distance(from: l) < $1.location.distance(from: l)
    } }
    ?? restaurants
    
    return NavigationStack {
      TapasGrid(tapas: tapas, location: location, selectedItem: $selectedItem.animation())
    }
  }
}

extension ContentView {
  func pasteAction() {
    guard let str = dataSource.tapasData(restaurants) else { return }
    UIPasteboard.general.string = str
    print(str)
  }
  
  func searchRestaurants() async {
    do {
      self.restaurants = try await dataSource.restaurants()
    }
    catch {
      print(error)
    }
  }
}

extension View {
  func onLocationUpdate(perform action: @escaping (CLLocation) -> Void) -> some View {
    let updates = CLLocationUpdate.liveUpdates()
    
    return self.task {
      do {
        var lastLocation: CLLocation = .init()
        for try await update in updates {
          guard let loc = update.location else { continue }
          guard loc.distance(from: lastLocation) > 10 else { continue }
          lastLocation = loc
          action(loc)
          print(loc)
        }
      }
      catch {
        print("onLocationUpdate error:", error)
      }
    }
  }
}
