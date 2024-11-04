import SwiftUI

struct TapaView: View {
  let tapa: Restaurant
  
  var body: some View {
    HStack {
      Icon(tapa.picture)
      Info()
    }
    .foregroundStyle(.foreground)
  }
  
  func Info() -> some View {
    VStack(alignment: .leading) {
      Text(tapa.name +  " • " + tapa.address)
        .font(.caption)
        .foregroundStyle(.secondary)
        .textScale(.secondary)
      
      Text(tapa.tapaName)
        .font(.headline)
    }
  }
  
  func Icon(_ url: URL?) -> some View {
    AsyncImage(url: url) { image in
      image
        .resizable()
        .scaledToFit()
    } placeholder: {
      Image(systemName: "clock").foregroundStyle(.secondary)
    }
    .frame(width: 64, height: 64)
    .clipShape(.circle)
  }
}
