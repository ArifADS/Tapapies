import Foundation

struct Location: Identifiable, Hashable {
  let latitude: Double
  let longitude: Double
  var id: String { "\(latitude),\(longitude)" }
}

extension Location {
  func distance(from location: Location) -> Double {
    coreLocation.distance(from: location.coreLocation)
  }
  
  func measure(from location: Location) -> Measurement<UnitLength> {
    Measurement(value: distance(from: location), unit: .meters)
  }
  
  func sorting(_ tapas: [Tapa]) -> [Tapa] {
    tapas.sorted {
      distance(from: $0.location) < distance(from: $1.location)
    }
  }
}

extension Location: Codable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let values = try container.decode(String.self).split(separator: ",").map {
      Double($0)!
    }
    
    self.latitude = values.first!
    self.longitude = values.last!
  }
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(id)
  }
}
