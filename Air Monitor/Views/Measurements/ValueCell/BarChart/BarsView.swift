//
//  BarsView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 18/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct BarsView: View {
  let bars: [Bar]
  var maxValue: Double {
    return bars.map(\.value).max() ?? .greatestFiniteMagnitude
  }
  
  var body: some View {
    GeometryReader { geometry in
      HStack(alignment: .bottom, spacing: 0) {
        ForEach(self.bars) { bar in
          Capsule()
            .fill(bar.color)
            .frame(height: CGFloat(bar.value) / CGFloat(self.maxValue) * geometry.size.height)
            .overlay(Rectangle().stroke(Color(.secondarySystemBackground)))
        }
      }
    }
  }
}

struct BarsView_Previews: PreviewProvider {
  private static let previewBars = [
    Bar(id: UUID(), value: 1, color: .green),
    Bar(id: UUID(), value: 2, color: .green),
    Bar(id: UUID(), value: 3, color: .green),
    Bar(id: UUID(), value: 5, color: .yellow),
    Bar(id: UUID(), value: 6, color: .yellow),
    Bar(id: UUID(), value: 8, color: .yellow),
    Bar(id: UUID(), value: 5, color: .yellow),
    Bar(id: UUID(), value: 3, color: .green),
    Bar(id: UUID(), value: 1, color: .green),
    Bar(id: UUID(), value: 2, color: .green),
    Bar(id: UUID(), value: 3, color: .green),
    Bar(id: UUID(), value: 4, color: .green),
    Bar(id: UUID(), value: 6, color: .yellow),
    Bar(id: UUID(), value: 9, color: .red),
    Bar(id: UUID(), value: 12, color: .red),
    Bar(id: UUID(), value: 10, color: .red),
    Bar(id: UUID(), value: 8, color: .yellow),
    Bar(id: UUID(), value: 7, color: .yellow),
    Bar(id: UUID(), value: 6, color: .yellow),
    Bar(id: UUID(), value: 4, color: .green),
    Bar(id: UUID(), value: 2, color: .green),
    Bar(id: UUID(), value: 1, color: .green),
    Bar(id: UUID(), value: 1, color: .green),
    Bar(id: UUID(), value: 3, color: .green)
  ]
  
    static var previews: some View {
        BarsView(bars: previewBars)
    }
}
