//
//  EmptyListView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 21/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct EmptyListView<T: RandomAccessCollection, V: View, W: View>: View where T.Element: Identifiable {
  var data: T
  var emptyContent: () -> W
  var rowContent: (T.Element) -> V
  
  var body: some View {
    Group {
      if data.isEmpty {
        emptyContent()
      } else {
        List(data, rowContent: rowContent)
      }
    }
  }
}
