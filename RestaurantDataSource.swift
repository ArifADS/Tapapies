import Foundation
import CoreLocation
import CoreLocationUI
import Contacts
import SwiftUI

struct Migrate1: Codable {
  let name: String
  var latitude: Double
  var longitude: Double
}

@MainActor
final class RestaurantDataSource {
  init() {}
  
  func restaurants() async throws -> [Restaurant] {
    let dec = JSONDecoder()
    let url = URL(string: "https://gist.githubusercontent.com/ArifADS/e27c94a1c7a98477f0f63fc90530d4bb/raw/restaurants.json")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let locales = (try? dec.decode([Migrate1].self, from: data)) ?? []
    return try parse(locales)
    
//    for locale in locales where locale.address.isEmpty {
//      let rest = try await findRestaurant(from: locale)
//      rests.append(rest)
//    }
    
//    let enc = JSONEncoder()
//    enc.outputFormatting = [.prettyPrinted, .sortedKeys]
//    let newData = try enc.encode(rests)
//    let str = String(data: newData, encoding: .utf8)!.replacingOccurrences(of: "\\n", with: "\\\n")
//    print(str)
    
//    return locales
  }
  
  func findRestaurant(from restaurant: Restaurant) async throws -> Restaurant {
    var rest = restaurant
    let geocoder = CLGeocoder()
    let model = CNMutablePostalAddress()
    model.country = "Spain"
    model.city = "Madrid"
    model.street = restaurant.name + " , Lavapies"
    model.subLocality = "Lavapies"
//    model.postalCode = "28012"
    
    if let mark = try? await geocoder.geocodePostalAddress(model).first {
      rest.latitude = mark.location!.coordinate.latitude
      rest.longitude = mark.location!.coordinate.longitude
      rest.address = mark.name ?? ""
    }
    
    return rest
  }
  
  private func parse(_ restaurants: [Migrate1]) throws -> [Restaurant] {
    let infos = try JSONDecoder().decode([RestObj].self, from: raw_data)
    
    return infos.compactMap { info in
      let name = String(info.title.split(separator: "-").first!)
      let tapa = String(info.title.split(separator: "-").last!)
      let r = restaurants.first(where: { info.title.localizedCaseInsensitiveContains($0.name) })
      
      if r == nil {
        print("Not found", info.title)
      }
      
      return .init(
        name: name,
        tapaName: tapa,
        picture: info.image_url,
        latitude: r?.latitude ?? 0,
        longitude: r?.longitude ?? 0,
        address: info.location,
        country: info.country
      )
    }
  }
}

struct RestObj: Codable {
  let title: String
  let image_url: URL
  let location: String
  let country: String
  let categories: [String]
  let voting_url: URL
}

let raw_data: Data = """
[
  {
    "title": "Abascal Olmedo-Ensaladilla Olmedo",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/abascal-olmedo-ensaladilla-olmedo-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P37",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/abascal-olmedo-ensaladilla-olmedo/"
  },
  {
    "title": "África Food Madrid-Nem África Food",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/africa-food-madrid-nem-africa-food-01-1024x1024.jpg",
    "location": "Caravaca 17",
    "country": "Senegal",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/africa-food-madrid-nem-africa-food/"
  },
  {
    "title": "África Fusión-C’est Bon",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/africa-fusion-cest-bone-01-1024x1024.jpg",
    "location": "Argumosa 15",
    "country": "Senegal",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/africa-fusion-cest-bon/"
  },
  {
    "title": "Aloha Poké-Pica & Mex",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/aloha-poke-pica-y-mex-01-1024x1024.jpg",
    "location": "Ronda de Valencia 14",
    "country": "Hawái / México",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN PESCADO"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/aloha-poke-pica-mex/"
  },
  {
    "title": "Amanda Café-Bacalao de Olinda en Salsa Verde",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/amanda-cafe-bacalao-de-olinda-en-salsa-verde-01-1024x1024.jpg",
    "location": "Argumosa 31",
    "country": "Portugal",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/amanda-cafe-bacalao-de-olinda-en-salsa-verde/"
  },
  {
    "title": "Amor Voodoo-Carnitas al Mole con Crujientes",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/amor-voodoo-carnitas-al-mole-con-crujientes-01-1024x1024.jpg",
    "location": "Lavapiés 56",
    "country": "México / España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/amor-voodoo-carnitas-al-mole-con-crujientes/"
  },
  {
    "title": "Anarkoli-Rollo de Queso Anarkoli",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/anarkoli-rollo-de-queso-anarkoli-01-1024x1024.jpg",
    "location": "Lavapiés 46",
    "country": "India",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/anarkoli-rollo-de-queso-anarkoli/"
  },
  {
    "title": "Apululu-El Secreto más Dulce",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/apululu-el-secreto-mas-dulce-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P22",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/apululu-el-secreto-mas-dulce/"
  },
  {
    "title": "Arroces Tribulete-Arroz Tribulete",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/arroces-tribulete-arroz-tribulete-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P9",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/arroces-tribulete-arroz-tribulete/"
  },
  {
    "title": "Baisakhi-Adana Kebab",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/baisakhi-adana-kebab-01-1024x1024.jpg",
    "location": "Lavapiés 42",
    "country": "Turquía",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/baisakhi-adana-kebab/"
  },
  {
    "title": "Bendito vinos y vinilos-Caprichos de cecina",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/bendito-vinos-y-vinilos-caprichos-de-cecina-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P4",
    "country": "España / Italia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/bendito-vinos-y-vinilos-caprichos-de-cecina/"
  },
  {
    "title": "Bombay Palace-Pollo Tikka Masala",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/bombay-palace-pollo-tikka-masala-01-1024x1024.jpg",
    "location": "Ave María 26",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/bombay-palace-pollo-tikka-masala/"
  },
  {
    "title": "Café Barbieri-Caponata Barbieri",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/cafe-barbieri-caponata-barbieri-01-1024x1024.jpg",
    "location": "Ave María 45",
    "country": "Italia",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN GLUTEN BAJO DEMANDA",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "VEGANA BAJO DEMANDA",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/cafe-barbieri-caponata-barbieri/"
  },
  {
    "title": "Café Dieli-Tostones al Mojo Boricua",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/cafe-dieli-tostones-al-mojo-boricua-01-1024x1024.jpg",
    "location": "Mesón de Paredes 16",
    "country": "Puerto Rico",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/cafe-dieli-tostones-al-mojo-boricua/"
  },
  {
    "title": "Café Santay-Muchín Santay",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/cafe-santay-muchin-santay-01-1024x1024.jpg",
    "location": "Embajadores 5",
    "country": "Ecuador",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/cafe-santay-muchin-santay/"
  },
  {
    "title": "Calcuta-Chicken Samosa",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/calcuta-chicken-samosa-01-1024x1024.jpg",
    "location": "Lavapiés 48",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/calcuta-chicken-samosa/"
  },
  {
    "title": "Calvario-Arroz Verde del Calvario",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/calvario-arroz-verde-del-calvario-01-1024x1024.jpg",
    "location": "Calvario 16",
    "country": "Perú",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/calvario-arroz-verde-del-calvario/"
  },
  {
    "title": "Caminito-Pastel de Carne Piquillín",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/caminito-pastel-de-carne-piquillin-01-1024x1024.jpg",
    "location": "Salitre 27",
    "country": "Argentina",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/caminito-pastel-de-carne-piquillin/"
  },
  {
    "title": "Carmencita Brunch Lavapiés-Tosta Benedictina",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/carmencita-brunch-lavapies-tosta-benedictina-01-1024x1024.jpg",
    "location": "Sombrerería 6",
    "country": "EE.UU. / Inglaterra / España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN BAJO DEMANDA",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/carmencita-brunch-lavapies-tosta-benedictina/"
  },
  {
    "title": "Casa Calores-Tortilla Trufada",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/casa-calores-tortilla-trufada-01-1024x1024.jpg",
    "location": "Pza General Vara de Rey 11",
    "country": "España",
    "categories": [
      "CARNÍVORA BAJO DEMANDA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/casa-calores-tortilla-trufada/"
  },
  {
    "title": "Casa Jaguar Café-Ssäm de Cochinita Pibil",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/casa-jaguar-cafe-ssam-de-cochinita-pibil-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P17",
    "country": "Corea / México",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/casa-jaguar-cafe-ssam-de-cochinita-pibil/"
  },
  {
    "title": "Casa Jaguar Mercado-Ssäm de Cochinita Pibil",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/casa-jaguar-mercado-ssam-de-cochinita-pibil-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P17-20",
    "country": "Corea / México",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/casa-jaguar-mercado-ssam-de-cochinita-pibil/"
  },
  {
    "title": "Casa María-Tortilla Casa María",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/casa-maria-tosta-de-tortilla-de-patata-con-chistorra-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P28-31",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/casa-maria-tosta-de-tortilla-de-patata-con-chistorra/"
  },
  {
    "title": "Casino Kebab-Pollo Casino Kebab",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/casino-kebab-pollo-casino-kebab-01-1024x1024.jpg",
    "location": "Embajadores 47",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/casino-kebab-pollo-casino-kebab/"
  },
  {
    "title": "Chinaski-Tortilla Chipotata Mex",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/chinaski-tortilla-chipotata-mex-01-1024x1024.jpg",
    "location": "Salitre 38",
    "country": "México / España",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/chinaski-tortilla-chipotata-mex/"
  },
  {
    "title": "Citynizer-Patacón Citynizer",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/citynizer-patacon-citynizer-01-1024x1024.jpg",
    "location": "Juanelo 17",
    "country": "Japón / Venezuela",
    "categories": [
      "CARNÍVORA",
      "SIN APIO",
      "SIN MOSTAZA",
      "SIN SOJA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/citynizer-patacon-citynizer/"
  },
  {
    "title": "Cutzamala Mex Food-Frijoles Puercos",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/cutzamala-mex-food-frijoles-puercos-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P37",
    "country": "México",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/cutzamala-mex-food-frijoles-puercos/"
  },
  {
    "title": "Daaraji-Mafe Daaraji",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/daaraji-mafe-daaraji-01-1024x1024.jpg",
    "location": "Mesón de Paredes 17",
    "country": "Senegal",
    "categories": [
      "CARNÍVORA BAJO DEMANDA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "VEGANA BAJO DEMANDA",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/daaraji-mafe-daaraji/"
  },
  {
    "title": "Dakar-Boulette Dakar",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/dakar-boulette-dakar-01-1024x1024.jpg",
    "location": "Ave María 32",
    "country": "Senegal",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/dakar-boulette-dakar/"
  },
  {
    "title": "Darbuka-Fitira Arish",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/darbuka-fitira-arish-01-1024x1024.jpg",
    "location": "Buenavista 46",
    "country": "Egipto",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/darbuka-fitira-arish/"
  },
  {
    "title": "Delhi Darbar-Darbar Chicken Chaat",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/delhi-darbar-darbar-chicken-chaat-01-1024x1024.jpg",
    "location": "Argumosa 29",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/delhi-darbar-darbar-chicken-chaat/"
  },
  {
    "title": "Delhi Express-Pollo Tikka Masala",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/delhi-express-pollo-tikka-masala-01-1024x1024.jpg",
    "location": "Lavapiés 44",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/delhi-express-pollo-tikka-masala/"
  },
  {
    "title": "Distrito Vegano-Chopitos de la Huerta",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/distrito-vegano-chopitos-de-la-huerta-01-1024x1024.jpg",
    "location": "Conde de Romanones 10",
    "country": "España",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SULFITOS",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/distrito-vegano-chopitos-de-la-huerta/"
  },
  {
    "title": "Divino-Bomba Rosa",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/divino-bomba-rosa-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P2",
    "country": "Italia/ España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/divino-bomba-rosa/"
  },
  {
    "title": "El Colmado-Bocadín Asturleonés",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/el-colmado-bocadin-asturleones-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P12",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/el-colmado-bocadin-asturleones/"
  },
  {
    "title": "El Jamón-Tosta de Lomillako con Crema de Queso Asturiano",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/el-jamon-tosta-de-lomillako-con-crema-de-queso-asturiano-01-1024x1024.jpg",
    "location": "Lavapiés 47",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN BAJO DEMANDA",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/el-jamon-tosta-de-lomillako-con-crema-de-queso-asturiano/"
  },
  {
    "title": "El Jardín De Lavapiés-Chorizo del Jardín",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/el-jardin-de-lavapies-chorizo-del-jardin-01-1024x1024.jpg",
    "location": "Embajadores 42",
    "country": "Argentina",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/el-jardin-de-lavapies-chorizo-del-jardin/"
  },
  {
    "title": "El Perenquén-Waffleburger de Pulled Chicken",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/el-perenquen-waffleburger-de-pulled-chicken-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P29",
    "country": "Canarias",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/el-perenquen-waffleburger-de-pulled-chichen/"
  },
  {
    "title": "El Quijote-Morena Tropicana",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/el-quijote-morena-tropicana-01-1024x1024.jpg",
    "location": "Ave María 52",
    "country": "Brasil",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SOJA",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/el-quijote-morena-tropicana/"
  },
  {
    "title": "El Rincón De Ores-Caprichito",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/el-rincon-de-ores-caprichito-01-1024x1024.jpg",
    "location": "Lavapiés 27",
    "country": "España / Oriente Medio",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/el-rincon-de-ores-caprichito/"
  },
  {
    "title": "El Rincón De Ruda-Tosta Ruda",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/el-rincon-de-ruda-tosta-de-gulas-con-alioli-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P40-43",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/el-rincon-de-ruda-tosta-de-gulas-con-alioli/"
  },
  {
    "title": "Encuentros Bar-Ropa Vieja",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/encuentros-bar-ropa-vieja-01-1024x1024.jpg",
    "location": "Embajadores, 26",
    "country": "Puerto Rico",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/encuentros-bar-ropa-vieja/"
  },
  {
    "title": "Falafelería-Falafelito",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/falafeleria-falafelito-01-1024x1024.jpg",
    "location": "Santa Isabel 28",
    "country": "Oriente Medio",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN BAJO DEMANDA",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/falafeleria-falafelito/"
  },
  {
    "title": "Galipán-El Greñas Jr.",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/galipan-el-grenas-jr-01-1024x1024.jpg",
    "location": "Valencia 9",
    "country": "América",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN HUEVOS",
      "SIN MOLUSCOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/galipan-el-grenas-jr/"
  },
  {
    "title": "Garibaldi-Cocktail Molatown",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/garibaldi-cocktail-molatown-01-1024x1024.jpg",
    "location": "Ave María 8",
    "country": "Asia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/garibaldi-cocktail-molatown/"
  },
  {
    "title": "Gatopiés-Pincho Gatopiés",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/gatopies-pincho-gatopies-01-1024x1024.jpg",
    "location": "Esperanza 8",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/gatopies-pincho-gatopies/"
  },
  {
    "title": "Gracias Vieja-El Ceviche de La Vieja",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/gracias-vieja-el-ceviche-de-la-vieja-01-1024x1024.jpg",
    "location": "Lavapiés 25",
    "country": "Perú",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/gracias-vieja-el-ceviche-de-la-vieja/"
  },
  {
    "title": "Hartem-Focaccia Negra de Pastrami de León",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/hartem-focaccia-negra-de-pastrami-de-leon-01-1024x1024.jpg",
    "location": "Duque de Rivas 5",
    "country": "Oriente Medio",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/hartem-focaccia-negra-de-pastrami-de-leon/"
  },
  {
    "title": "Hopes-Mini Burger Esperanzado",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/hopes-mini-burger-esperanzado-01-1024x1024.jpg",
    "location": "Argumosa 29",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/hopes-mini-burger-esperanzado/"
  },
  {
    "title": "Il Morto Che Parla-La Gilda Ascolana",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/il-morto-che-parla-la-gilda-ascolana-01-1024x1024.jpg",
    "location": "Salitre 31",
    "country": "Italia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/il-morto-che-parla-la-gilda-ascolana/"
  },
  {
    "title": "Indian Masala-Chicken Biriani",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/indian-masala-chicken-biriani-01-1024x1024.jpg",
    "location": "Ave María 29",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/indian-masala-chicken-biriani/"
  },
  {
    "title": "Jam-Falafel Jam",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/jam-falafel-jam-01-1024x1024.jpg",
    "location": "Marques de Toca  7",
    "country": "Oriente Medio",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SOJA",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/jam-falafel-jam/"
  },
  {
    "title": "K-sdal-Salchicha Crepe",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/k-sdal-salchicha-crepe-01-1024x1024.jpg",
    "location": "Argumosa 30",
    "country": "Francia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/k-sdal-salchicha-crepe/"
  },
  {
    "title": "Kaldi Café-Cabrita",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/kaldi-cafe-cabrita-01-1024x1024.jpg",
    "location": "Embajadores 17 (esquina C/ del Oso 25)",
    "country": "España",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/kaldi-cafe-cabrita/"
  },
  {
    "title": "Kebab Lavapiés-Pollo Katsudon Burger",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/kebab-lavapies-pollo-katsudon-burger-01-1024x1024.jpg",
    "location": "Pza Lavapiés 5",
    "country": "Japón",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/kebab-lavapies-pollo-katsudon-burger/"
  },
  {
    "title": "La Alpargata Vegana-El Patacón de La Alpargata",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-alpargata-vegana-arepa-psicodelica-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P10",
    "country": "Venezuela",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-alpargata-vegana-el-patacon-de-la-alpargata/"
  },
  {
    "title": "La Buga Del Lobo-Volován de Toro Endiablado",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-buga-del-lobo-volovan-de-toro-endiablado-01-1024x1024.jpg",
    "location": "Argumosa 11",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-buga-del-lobo-volovan-de-toro-endiablado/"
  },
  {
    "title": "La Chaskona Bar-Delicia de Pollo",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-chaskona-bar-delicia-de-pollo-01-1024x1024.jpg",
    "location": "Olmo 12",
    "country": "Chile",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-chaskona-bar-delicia-de-pollo/"
  },
  {
    "title": "La Chingada Mx-Ternera Jarocha",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-chingada-mx-ternera-jarocha-01-1024x1024.jpg",
    "location": "Salitre 15",
    "country": "México",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-chingada-mx-ternera-jarocha/"
  },
  {
    "title": "La Chulapa En Mayrit-Barbacucu",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-chulapa-en-mayrit-barbacucu-01-1024x1024.jpg",
    "location": "Dr. Fourquet 37",
    "country": "España / Argentina",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-chulapa-en-mayrit-barbacucu/"
  },
  {
    "title": "La Cucusa-Lentejuela",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-cucusa-lentejuela-01-1024x1024.jpg",
    "location": "Cabeza 1",
    "country": "Argentina / Oriente Medio",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-cucusa-lentejuela/"
  },
  {
    "title": "La De Espronceda-Pollo al Curry de la Espronceda",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-de-espronceda-pollo-al-curry-de-la-espronceda-01-1024x1024.jpg",
    "location": "Santa Isabel 17",
    "country": "Asia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-de-espronceda-pollo-al-curry-de-la-espronceda/"
  },
  {
    "title": "La Encomienda-Escabeche Asiático",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-encomienda-escabeche-asiatico-01-1024x1024.jpg",
    "location": "Encomienda 19",
    "country": "España / Asia",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SULFITOS",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-encomienda-escabeche-asiatico/"
  },
  {
    "title": "La Fille Du Poulet-Montado de Churrasco da Katia",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-fille-du-poulet-montado-de-churrasco-da-katia-01-1024x1024.jpg",
    "location": "Torrecilla del Leal 29",
    "country": "Brasil",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-fille-du-poulet-montado-de-churrasco-da-katia/"
  },
  {
    "title": "La India Tetería-Salpicón de la Elsa",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-india-teteria-salpicon-de-la-elsa-01-1024x1024.jpg",
    "location": "Ave María 50",
    "country": "Santo Domingo",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-india-teteria-salpicon-de-la-elsa/"
  },
  {
    "title": "La Inquilina-Delicia de Otoño",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-inquilina-delicia-de-otono-01-1024x1024.jpg",
    "location": "Ave María 39",
    "country": "España / Francia",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-inquilina-delicia-de-otono/"
  },
  {
    "title": "La Lata De Cascorro-Bao-Picón",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-lata-de-cascorro-bao-picon-01-1024x1024.jpg",
    "location": "Embajadores 1",
    "country": "Española/ Asia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-lata-de-cascorro-bao-picon/"
  },
  {
    "title": "La Marimala-La Focaccia del Pueblo",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-marimala-la-focaccia-del-pueblo-01-1024x1024.jpg",
    "location": "Provisiones 18",
    "country": "Italia / Canarias / Grecia",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-marimala-la-focaccia-del-pueblo/"
  },
  {
    "title": "La Mercadería De Antón Martín-Meloso de Ibérico",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-mercaderia-de-anton-martin-carrillera-de-la-mercaderia-01-1024x1024.jpg",
    "location": "Pasaje Doré 19 MAM P16 -19",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-mercaderia-de-anton-martin-meloso-de-iberico/"
  },
  {
    "title": "La Playa De Lavapiés-Del Mediterráneo a Lavapiés",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-playa-de-lavapies-del-mediterraneo-a-lavapies-01-1024x1024.jpg",
    "location": "Argumosa 9",
    "country": "Italia / España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-playa-de-lavapies-del-mediterraneo-a-lavapies/"
  },
  {
    "title": "La Sal-Tostada de Atún Enchipotlado",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-sal-tostada-de-atun-tapapies-2024-1024x1024.png",
    "location": "Embajadores 41 MSF P31",
    "country": "Asia/ México",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-sal-tostada-de-atun-enchipotlado/"
  },
  {
    "title": "La Tranca-Gamboom",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-tranca-gamboom-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P24",
    "country": "España / Asia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-tranca-gamboom/"
  },
  {
    "title": "La Yapa Empanadas Argentinas-La Yapita",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/la-yapa-empanadas-argentinas-la-yapita-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P11-13",
    "country": "Argentina",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/la-yapa-empanadas-argentinas-la-yapita/"
  },
  {
    "title": "Latazo-Latazo Trufado",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/latazo-bolinho-de-huevo-con-trufa-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P6-7",
    "country": "Asia",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/latazo-bolinho-de-huevo-con-trufa/"
  },
  {
    "title": "Le Croustillant-Sabor Latino-Americano",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/le-croustillant-sabor-latino-americano-01-1024x1024.jpg",
    "location": "Dr Fourquet 32",
    "country": "Venezuela / México / Francia / España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/le-croustillant-sabor-latino-americano/"
  },
  {
    "title": "Liberté Café-Hummus de Guisantes con queso de cabra a la francesa",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/liberte-cafe-hummus-de-guisantes-con-queso-de-cabra-a-la-francesa-01-1024x1024.jpg",
    "location": "San Simón 3",
    "country": "Francia",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/liberte-cafe-hummus-de-guisantes-con-queso-de-cabra-a-la-francesa/"
  },
  {
    "title": "Limonzello-Focaccia Limonzello",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/limonzello-focaccia-limonzello-01-1024x1024.jpg",
    "location": "Argumosa 6",
    "country": "Italia",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/limonzello-focaccia-limonzello/"
  },
  {
    "title": "Lingueer Saveurs D’Afrik-Fufu de Fatou",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/lingueer-saveurs-dafrik-fufu-de-fatou-01-1024x1024.jpg",
    "location": "Embajadores 41 P6",
    "country": "África Central",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/lingueer-saveurs-dafrik-fufu-de-fatou/"
  },
  {
    "title": "Lonja Agroecológica-Nube",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/lonja-agroecologica-nube-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P27",
    "country": "España",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/lonja-agroecologica-nube/"
  },
  {
    "title": "Lonja De La Corrala-Cheli",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/lonja-de-la-corrala-cheli-01-1024x1024.jpg",
    "location": "Tribulete 13",
    "country": "México",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/lonja-de-la-corrala-cheli/"
  },
  {
    "title": "López & López-Indonesia",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/lopez-y-lopez-indonesia-01-1024x1024.jpg",
    "location": "Cabestreros 4",
    "country": "Italia / Indonesia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN PESCADO"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/lopez-lopez-indonesia/"
  },
  {
    "title": "Los Gamos-Chicken Tikka Masala con Arroz Basmati",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/los-gamos-chicken-tikka-masala-con-arroz-basmati-01-1024x1024.jpg",
    "location": "Ave María 31",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/los-gamos-chicken-tikka-masala-con-arroz-basmati/"
  },
  {
    "title": "Los Rotos De Lavapiés-Callos de los Rotos",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/los-rotos-de-lavapies-callos-de-los-rotos-01-1024x1024.jpg",
    "location": "Mesón de Paredes 81",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN GLUTEN",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/los-rotos-de-lavapies-callos-de-los-rotos/"
  },
  {
    "title": "Macanudos-Bao Mechado Cajún",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/macanudos-bao-mechado-01-1024x1024.jpg",
    "location": "Ave María 39",
    "country": "EE.UU. / Japón",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "VEGANA BAJO DEMANDA",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/macanudos-bao-mechado-cajun/"
  },
  {
    "title": "Majo’S Food-La Brocheta de Majo´s",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/majos-food-la-brocheta-de-majos-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P36-39",
    "country": "Colombia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/majos-food-la-brocheta-de-majos/"
  },
  {
    "title": "Maldito Querer-Manolita Bajo el Sol de Membrillo",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/maldito-querer-manolita-bajo-el-sol-de-membrillo-01-1024x1024.jpg",
    "location": "Argumosa 5",
    "country": "España",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/maldito-querer-manolita-bajo-el-sol-de-membrillo/"
  },
  {
    "title": "Mandela 100-Fideos Mandela 100",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/mandela-100-fideos-mandela-100-01-1024x1024.jpg",
    "location": "Mesón de Paredes 52",
    "country": "Senegal",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/mandela-100-fideos-mandela-100/"
  },
  {
    "title": "Mapenda-Mafe Vegetariano",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/mapenda-mafe-vegetariano-01-1024x1024.jpg",
    "location": "La Fe 9",
    "country": "Senegal",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/mapenda-mafe-vegetariano-2/"
  },
  {
    "title": "Mesón Los Platos-Shaji Briani de Pollo",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/meson-los-platos-shaji-briani-de-pollo-01-1024x1024.jpg",
    "location": "Escuadra 1",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/meson-los-platos-shaji-briani-de-pollo/"
  },
  {
    "title": "Moñetes Panino Italiano-La Anamari",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/monetes-panino-italiano-la-anamari-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P35 1ª Planta",
    "country": "Italiano",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN BAJO DEMANDA",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/monetes-panino-italiano-la-anamari/"
  },
  {
    "title": "One Love-Jamaican Lollipop",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/one-love-jamaican-lollipop-01-1024x1024.jpg",
    "location": "Buenavista 14",
    "country": "Jamaica",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/one-love-jamaican-lollipop/"
  },
  {
    "title": "Orishas-Perla de Bacalao en Coral con Salsa de Camarón Rojo",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/orishas-perla-de-bacalao-en-coral-con-salsa-de-camaron-rojo-01-1024x1024.jpg",
    "location": "Argumosa 39",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN CACAHUETES",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/orishas-perla-de-bacalao-en-coral-con-salsa-de-camaron-rojo/"
  },
  {
    "title": "Otoman Kebab-Otomán Perrito",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/otoman-kebab-otoman-perrito-01-1024x1024.jpg",
    "location": "Argumosa 21",
    "country": "EE.UU.",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/otoman-kebab-otoman-perrito/"
  },
  {
    "title": "Pakistaní Restaurante-Reshvri Mango Qorma",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/pakistani-restaurante-reshvri-mango-qorma-01-1024x1024.jpg",
    "location": "Lavapiés 53",
    "country": "Pakistán",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/pakistani-restaurante-reshvri-mango-qorma/"
  },
  {
    "title": "Pirámide-Alcachofa Pirámide",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/piramide-alcachofa-piramide-01-1024x1024.jpg",
    "location": "Torrecilla del Leal 15",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN LÁCTEOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/piramide-alcachofa-piramide/"
  },
  {
    "title": "Portomarín-Carrigocho",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/portomarin-carrigocho-01-1024x1024.jpg",
    "location": "Valencia  4",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN BAJO DEMANDA",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/portomarin-carrigocho/"
  },
  {
    "title": "Preity Raj-Pollo Korma",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/preity-raj-pollo-korma-01-1024x1024.jpg",
    "location": "Ave María 29",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/preity-raj-pollo-korma/"
  },
  {
    "title": "Primadonna-Che Bella Donna",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/primadonna-garibaldi-01-1024x1024.jpg",
    "location": "Argumosa 18",
    "country": "Italia",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/primadonna-garibaldi/"
  },
  {
    "title": "Raj Puth-Baozi de Pollo",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/raj-puth-baozi-de-pollo-01-1024x1024.jpg",
    "location": "Pza Lavapiés 4",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/raj-puth-baozi-de-pollo/"
  },
  {
    "title": "Raja Hindustaní-Malai Kofta",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/raja-hindustani-malai-kofta-01-1024x1024.jpg",
    "location": "Dr Piga 21",
    "country": "India/México",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/raja-hindustani-malai-kofta/"
  },
  {
    "title": "Rincón Guay-Cómeme el Cono",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/rincon-guay-comeme-el-cono-01-1024x1024.jpg",
    "location": "Embajadores 62",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN FRUTOS SECOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/rincon-guay-comeme-el-cono/"
  },
  {
    "title": "Serendipia-Viva Venezuela",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/serendipia-viva-venezuela-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P35 Planta baja",
    "country": "Venezuela",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/serendipia-viva-venezuela/"
  },
  {
    "title": "Shapla I-Butter Chicken",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/shapla-i-butter-chicken-01-1024x1024.jpg",
    "location": "Lavapiés 42",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/shapla-i-butter-chicken/"
  },
  {
    "title": "Shapla Ii-Pollo Tikka Masala con Arroz Polao",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/shapla-ii-pollo-tikka-masala-con-arroz-polao-01-1024x1024.jpg",
    "location": "Lavapiés 40",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/shapla-ii-pollo-tikka-masala-con-arroz-polao/"
  },
  {
    "title": "Sonali-Chana Puri",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/sonali-chana-puri-01-1024x1024.jpg",
    "location": "Lavapiés 34",
    "country": "India",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/sonali-chana-puri/"
  },
  {
    "title": "Souksou-Finger de Pastela",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/souksou-finguer-de-pastela-01-1024x1024.jpg",
    "location": "Salitre 43",
    "country": "Marruecos",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CRUSTÁCEOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SULFITOS",
      "VEGANA BAJO DEMANDA",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/souksou-finger-de-pastela/"
  },
  {
    "title": "Sr. Matambre-Coca Caramelizada con Berenjena Sefardí",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/sr-matambre-coca-caramelizada-con-berenjena-sefardi-01-1024x1024.jpg",
    "location": "Amparo 12",
    "country": "Oriente Medio",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGETARIANA",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/sr-matambre-coca-caramelizada-con-berenjena-sefardi/"
  },
  {
    "title": "Taj Mahal -Chicken Tikka Masala con Arroz",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/taj-mahal-chicken-tikka-masala-con-arroz-01-1024x1024.jpg",
    "location": "Lavapiés 46",
    "country": "India",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/taj-mahal-chicken-tikka-masala-con-arroz/"
  },
  {
    "title": "Tal Qual-Rabo de Toro Estofado en Barquillo",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/tal-qual-rabo-de-toro-estofado-en-barquillo-01-1024x1024.jpg",
    "location": "Santa Isabel 5 MAM P1-2",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/tal-qual-rabo-de-toro-estofado-en-barquillo/"
  },
  {
    "title": "Tapioquería-Tapioca Mediterránea",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/tapioqueria-tapioca-mediterranea-01-1024x1024.jpg",
    "location": "La Fe 1",
    "country": "Brasil",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN SÉSAMO",
      "SIN SOJA",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/tapioqueria-tapioca-mediterranea/"
  },
  {
    "title": "Tetería Babel-Falafel Babel",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/teteria-babel-falafel-babel-01-1024x1024.jpg",
    "location": "Lavapiés 44",
    "country": "Oriente Medio",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/teteria-babel-falafel-babel/"
  },
  {
    "title": "Ven Ven Ven-Accara Niébé",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/ven-ven-ven-accara-niebe-01-1024x1024.jpg",
    "location": "Argumosa 15",
    "country": "Senegal",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CEREALES CON GLUTEN",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/ven-ven-ven-accara-niebe/"
  },
  {
    "title": "Viva Chapata-Curry Vegano de Sojalitas",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/viva-chapata-curry-vegano-de-sojalitas-01-1024x1024.jpg",
    "location": "Ave María 43",
    "country": "Bangladesh",
    "categories": [
      "SIN ALTRAMUZ",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "SIN SULFITOS",
      "VEGANA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/viva-chapata-curry-vegano-de-sojalitas/"
  },
  {
    "title": "Xantico-Castizo Montado de Pringá",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/xantico-castizo-montado-de-pringa-01-1024x1024.jpg",
    "location": "Dr Piga 21",
    "country": "España",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN GLUTEN BAJO DEMANDA",
      "SIN HUEVOS",
      "SIN LÁCTEOS",
      "SIN MOLUSCOS",
      "SIN MOSTAZA",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SOJA",
      "VEGANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/xantico-castizo-montado-de-pringa/"
  },
  {
    "title": "Zerotrenta-Maccheroni del Bosco",
    "image_url": "https://enlavapies.com/wp-content/uploads/2024/10/zerotrenta-maccheroni-del-bosco-01-1024x1024.jpg",
    "location": "Embajadores 41 MSF P35",
    "country": "Italia",
    "categories": [
      "CARNÍVORA",
      "SIN ALTRAMUZ",
      "SIN APIO",
      "SIN CACAHUETES",
      "SIN CRUSTÁCEOS",
      "SIN FRUTOS SECOS",
      "SIN HUEVOS",
      "SIN MOLUSCOS",
      "SIN PESCADO",
      "SIN SÉSAMO",
      "SIN SULFITOS",
      "VEGETARIANA BAJO DEMANDA"
    ],
    "voting_url": "https://enlavapies.com/tapapies/2024/zerotrenta-maccheroni-del-bosco/"
  }
]

""".data(using: .utf8)!
