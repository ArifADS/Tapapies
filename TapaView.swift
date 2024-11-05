import SwiftUI

struct TapaView: View {
  let tapa: Tapa
  let location: Location?
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Icon(tapa.picture.resized(to: .small))
      Info().padding([.horizontal, .bottom], 8)
    }
    .foregroundStyle(.foreground)
    .frame(height: 8*29, alignment: .top)
    .background(.regularMaterial)
    .clipShape(.rect(cornerRadius: 12))
    .labelStyle(TinyLabelStyle())
    .multilineTextAlignment(.leading)
  }
  
  func Info() -> some View {
    let distance = location?.measure(from: tapa.location)
    
    let countries = tapa.countries
      .joined(separator: "•")
//      .formatted(.list(type: .and))
    
    return VStack(alignment: .leading) {
      LabeledContent {
        distance.map {
          Text($0, format: .measurement(width: .abbreviated))
        }
      } label: {
        Text(tapa.maker)
      }
      .font(.caption)
      .foregroundStyle(.secondary)
      .textScale(.secondary)
      .lineLimit(1)
      
      Text(tapa.name)
        .font(.subheadline.weight(.medium))
      
      Spacer()
      
      Label(tapa.address, systemImage: "signpost.left")
      Label(countries, systemImage: "globe")
    }
  }
  
  func Icon(_ url: URL) -> some View {
    AsyncImage(url: url) { image in
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
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      configuration.icon.frame(width: 16)
      configuration.title
    }
    .imageScale(.small)
    .font(.caption)
    .fontWidth(.condensed)
    .foregroundStyle(.secondary)
    .lineLimit(1)
  }
}
