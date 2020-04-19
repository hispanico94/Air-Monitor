//
//  ActivityIndicator.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 30/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

private struct UIActivityIndicator: UIViewRepresentable {
  let isAnimating: Bool
  let style: UIActivityIndicatorView.Style
  
  func makeUIView(context: Context) -> UIActivityIndicatorView {
    let v = UIActivityIndicatorView(style: style)
    v.hidesWhenStopped = true
    return v
  }
  
  func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
    if isAnimating {
      uiView.startAnimating()
    } else {
      uiView.stopAnimating()
    }
  }
}

struct ActivityIndicator: View {
  let isAnimating: Bool
  let style: UIActivityIndicatorView.Style
  
  var body: some View {
    Group {
      if isAnimating {
        UIActivityIndicator(isAnimating: isAnimating, style: style)
          .foregroundColor(Color(.label))
          .padding(40)
          .background(Color(.tertiarySystemBackground))
          .cornerRadius(12)
      } else {
        EmptyView()
      }
    }
  }
}

