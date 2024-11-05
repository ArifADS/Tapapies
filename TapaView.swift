import SwiftUI
import CoreLocation

struct TapaView: View {
  let tapa: Restaurant
  let location: CLLocation?
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Icon(tapa.picture)
      Info().padding([.horizontal, .bottom], 8)
    }
    .foregroundStyle(.foreground)
    .frame(height: 240, alignment: .top)
    .background(.regularMaterial)
    .clipShape(.rect(cornerRadius: 12))
    .labelStyle(TinyLabelStyle())
    .multilineTextAlignment(.leading)
  }
  
  func Info() -> some View {
    let distance = (location?.distance(from: tapa.location)).map {
      Measurement(value: $0, unit: UnitLength.meters)
    }
    
    var text = Text(tapa.name)
    
    if let distance {
      text = text + Text(" • ") + Text(distance, format: .measurement(width: .abbreviated))
    }
    
    return VStack(alignment: .leading) {
      LabeledContent {
        distance.map {
          Text($0, format: .measurement(width: .abbreviated))
        }
      } label: {
        Text(tapa.name)
      }
      .font(.caption)
      .foregroundStyle(.secondary)
      .textScale(.secondary)
      .lineLimit(1)
      
      Text(tapa.tapaName)
        .font(.subheadline.weight(.medium))
      
      Spacer()
      
      Label(tapa.address, systemImage: "signpost.left")
      Label(tapa.country, systemImage: "globe")
        
    }
  }
  
  func Icon(_ url: URL) -> some View {
    let newURL = URL(string: url.absoluteString.replacingOccurrences(of: "-1024x1024", with: "-300x300"))!
    return AsyncImage(url: newURL) { image in
      image
        .resizable()
        .scaledToFill()
    } placeholder: {
      Image(systemName: "clock").foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .frame(height: 96)
    .clipped()
  }
}

struct TinyLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 4) {
      configuration.icon
      configuration.title
    }
    .imageScale(.small)
    .font(.caption)
    .fontWidth(.condensed)
    .foregroundStyle(.secondary)
    .lineLimit(1)
  }
}
