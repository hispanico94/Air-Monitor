//
//  Free Functions.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 28/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation

func updating<A>(_ value: A, using f: (inout A) -> Void) -> A {
  var mValue = value
  f(&mValue)
  return mValue
}

func curry<A, B, C>(f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}
