//
//  InformationsView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 15/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct InformationsView: View {
  var measureName = "PM10:"
  var measureValue = "110"
  var measureUnit = "µg/m"
  var date = Date()
  
  var initialDate = Date(timeIntervalSinceNow: -2_592_000)
  
  var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar.current
    formatter.locale = Calendar.current.locale
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter
  }()
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .lastTextBaseline) {
        Text(measureName)
          .bold()
          .padding(.trailing, 4)
        
        Text(measureValue)
          .font(.title)
          .fontWeight(.medium)
          .foregroundColor(.red)
        
        Text(measureUnit)
        
        Spacer(minLength: 4)
        
        Text("Aggiornato al \(date, formatter: dateFormatter)")
          .font(.caption)
          .minimumScaleFactor(0.8)
      }
      
      Text("Dal \(initialDate, formatter: dateFormatter) al \(date, formatter: dateFormatter):")
        .font(.caption)
    }
  }
}

struct InformationsView_Previews: PreviewProvider {
  static var previews: some View {
    InformationsView()
      .previewDevice("iPhone SE")
  }
}
