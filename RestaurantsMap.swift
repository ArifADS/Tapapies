import SwiftUI
import MapKit


struct RestaurantsMap: View {
  let restaurants: [Restaurant]
  @State private var position: MapCameraPosition = .automatic
  @Binding var selectedItem: Restaurant?
  
  var body: some View {
    let restaurants = restaurants.filter { $0.latitude != 0 }
    return Map(position: $position, selection: $selectedItem) {
      ForEach(restaurants) { r in
        Marker(r.name, coordinate: r.coordinate)
          .tag(r)
      }
      
      UserAnnotation()
        .mapOverlayLevel(level: .aboveLabels)
        .mapItemDetailSelectionAccessory(.sheet)
    }
    .mapControls {
      MapCompass()
      MapUserLocationButton()
      MapScaleView()
    }
    .onChange(of: selectedItem) {
      guard let item = $1 else { return }
      let cam = MapCamera(centerCoordinate: item.coordinate, distance: 7500)
      withAnimation { position = .camera(cam) }
    }
  }
}

extension Restaurant {
  var coordinate: CLLocationCoordinate2D {
    .init(latitude: latitude, longitude: longitude)
  }
  
  var location: CLLocation {
    .init(latitude: latitude, longitude: longitude)
  }
}
