//
//  SearchBar.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 01/04/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
  @Binding var text: String
  var placeholder: String
  
  var body: some View {
    HStack(alignment: .center) {
      HStack {
        Image(systemName: "magnifyingglass")
        
        TextField(placeholder, text: $text)
          .foregroundColor(.primary)
        
        if !text.isEmpty {
          Button(action: {
            self.text = ""
          }) {
            Image(systemName: "xmark.circle.fill")
          }
        } else {
          EmptyView()
        }
      }
      .padding(.all, 8)
      .foregroundColor(.secondary)
      .background(Color(.secondarySystemBackground))
      .cornerRadius(8)
    }
  .padding()
  }
}
