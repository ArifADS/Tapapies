import SwiftUI
import MapKit


struct TapasMap: View {
  let tapas: [Tapa]
  @State private var position: MapCameraPosition = .automatic
  @Binding var selectedItem: Tapa?
  
  var body: some View {
    return Map(position: $position, selection: $selectedItem) {
      ForEach(tapas) { r in
        Marker(r.maker, coordinate: r.coordinate)
          .tag(r)
      }
      
      UserAnnotation()
    }
    .mapControls {
      MapCompass()
      MapUserLocationButton()
      MapScaleView()
    }
    .onChange(of: selectedItem) {
      guard let item = $1?.coordinate else { return }
      let cam = MapCamera(centerCoordinate: item, distance: 5000)
      withAnimation { position = .camera(cam) }
    }
    .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 310) }
  }
}

private extension Tapa {
  var coordinate: CLLocationCoordinate2D {
    location.coreLocation.coordinate
  }
}

extension Location {  
  var coreLocation: CLLocation {
    .init(latitude: latitude, longitude: longitude)
  }
}


extension View {
  func onLocationUpdate(perform action: @escaping (Location) -> Void) -> some View {
    let updates = CLLocationUpdate.liveUpdates()
    
    return self.task {
      do {
        var lastLocation: CLLocation = .init()
        for try await update in updates {
          guard let loc = update.location else { continue }
          guard loc.distance(from: lastLocation) > 10 else { continue }
          lastLocation = loc
          action(.init(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
          print(loc)
        }
      }
      catch {
        print("onLocationUpdate error:", error)
      }
    }
  }
}
