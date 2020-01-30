//
//  RequestProvider.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 26/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation

protocol RequestProvider {
  var request: URLRequest { get }
}
