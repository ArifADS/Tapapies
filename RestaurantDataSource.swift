import Foundation
import CoreLocation
import CoreLocationUI
import Contacts
import SwiftUI

@MainActor
final class RestaurantDataSource {
  init() {}
  
  func restaurants() async throws -> [Restaurant] {
    let dec = JSONDecoder()
    let url = URL(string: "https://gist.githubusercontent.com/ArifADS/e27c94a1c7a98477f0f63fc90530d4bb/raw/restaurants.json")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let locales = (try? dec.decode([Restaurant].self, from: data)) ?? []
    return locales
  }
  
  func tapasData(_ tapas: [Restaurant]) -> String? {
    let enc = JSONEncoder()
    enc.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try? enc.encode(tapas)
    let str = data.flatMap { String(data: $0, encoding: .utf8) }
    return str
  }
  
  func findRestaurant(from restaurant: Restaurant, retried: Bool = false) async -> Restaurant {
    guard restaurant.latitude == 0 else { return restaurant }
    var rest = restaurant
    let geocoder = CLGeocoder()
    let str = rest.address + ", Madrid"
    
    do {
      if let mark = try await geocoder.geocodeAddressString(str).first {
        rest.latitude = mark.location!.coordinate.latitude
        rest.longitude = mark.location!.coordinate.longitude
      }
      print("Found", rest.name)
    }
    catch {
      print(error)
      try? await Task.sleep(for: .seconds(60))
      if retried { return restaurant }
      else {
        rest = await findRestaurant(from: restaurant, retried: true)
      }
    }
    
    return rest
  }
}
