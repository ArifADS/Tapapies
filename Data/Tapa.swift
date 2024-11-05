import Foundation

struct Tapa: Identifiable, Codable, Hashable {
  let id: String
  let name: String
  let maker: String
  let picture: URL
  let location: Location
  var address: String
  let countries: [String]
}

extension Tapa {
  var title: String { "\(name)-\(maker)" }
}

extension URL {
  enum Scale {
    case small
    case large
    
    var size: String {
      switch self {
      case .small: return "300x300"
      case .large: return "1024x1024"
      }
    }
  }
  
  func resized(to scale: Scale) -> URL {
    let url = self
      .absoluteString
      .replacingOccurrences(of: ".jpg", with: "-\(scale.size).jpg")
    
    return URL(string: url)!
  }
}
