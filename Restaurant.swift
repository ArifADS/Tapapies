import Foundation
import CoreLocation


struct Restaurant: Codable, Identifiable, Hashable {
  var id: String { name }
  let name: String
  var tapaName: String
  var picture: URL
  var latitude: Double
  var longitude: Double
  var address: String
  var country: String
}
