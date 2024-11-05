import Foundation


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

extension Restaurant {
  var title: String { "\(name)-\(tapaName)" }
  
  func tapa() -> Tapa {
    let id = UUID().uuidString.split(separator: "-").first!
    let url = picture.absoluteString.replacingOccurrences(of: "-1024x1024", with: "")
    let countries = country.split(separator: "/").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    
    let address = self.address
//      .replacingOccurrences(of: "Embajadores 41 MSF", with: "M. San Fernando")
//      .replacingOccurrences(of: "Santa Isabel 5 MAM", with: "M. Antón Martín")
    
    return .init(
      id: String(id),
      name: tapaName,
      maker: name,
      picture: URL(string: url)!,
      location: .init(latitude: latitude, longitude: longitude),
      address: address,
      countries: countries
    )
  }
}
