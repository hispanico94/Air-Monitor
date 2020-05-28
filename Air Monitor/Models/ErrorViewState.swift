//
//  ErrorViewState.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 28/05/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation

struct ErrorViewState: Identifiable {
  let title: String
  let description: String
  
  var id: String { description }
}

extension ErrorViewState {
  init(description: String) {
    self.title = "Error"
    self.description = description
  }
}
