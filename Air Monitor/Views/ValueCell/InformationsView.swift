//
//  InformationsView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 15/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct InformationsView: View {
  let currentMeasure: CurrentMeasure
  let measureDateBounds: (String, String)
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .lastTextBaseline) {
        Text("\(currentMeasure.name):")
          .bold()
          .padding(.trailing, 4)
        
        Text(currentMeasure.value)
          .font(.title)
          .fontWeight(.medium)
          .foregroundColor(currentMeasure.riskColor)
        
        Text(currentMeasure.unit)
        
        Spacer(minLength: 4)
        
        Text("Aggiornato al \(currentMeasure.date)")
          .font(.caption)
          .minimumScaleFactor(0.8)
      }
      
      Text("Dal \(measureDateBounds.0) al \(measureDateBounds.1):")
        .font(.caption)
    }
  }
}

struct InformationsView_Previews: PreviewProvider {
  static let currentMeasure = CurrentMeasure(
    name: "PM10",
    value: "100",
    unit: "ug/m3",
    riskColor: .red,
    date: "09/03/2020"
  )
  
  static let measureDateBounds = ("01/03/2020", "09/03/2020")
  
  static var previews: some View {
    InformationsView(
      currentMeasure: currentMeasure,
      measureDateBounds: measureDateBounds
    )
      .previewDevice("iPhone SE")
  }
}
