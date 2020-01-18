//
//  VerticalIndexView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 18/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct VerticalIndexView: View {
  let values: [Double]
  let formatter: NumberFormatter
  
  var body: some View {
    VStack(alignment: .leading) {
      ForEach(self.values.reversed(), id: \.self) { value in
        Group {
          if self.values.last != value {
            Spacer()
          }
          
          Text("\(self.formatter.string(from: NSNumber(floatLiteral: value)) ?? "")")
          
          if self.values.first != value {
            Spacer()
          }
        }
      }
    }
  }
}

struct VerticalIndexView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalIndexView(values: [0, 1, 2, 3, 4, 5], formatter: NumberFormatter())
    }
}
