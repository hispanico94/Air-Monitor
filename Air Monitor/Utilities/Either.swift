//
//  Either.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 15/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

enum Either<A, B> {
  case left(A)
  case right(B)
}
