//
//  Free Functions.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 28/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation
import UIKit

func updating<A>(_ value: A, using f: (inout A) -> Void) -> A {
  var mValue = value
  f(&mValue)
  return mValue
}

func curry<A, B, C>(f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}


/// Returns a tuple of the non-optional parameters passed to the function
/// - Parameters:
///   - a: the first parameter
///   - b: the second parameter
/// - Returns: a tuple of the first and second paramter not nil, only if both parameters
/// are not nil, otherwise it returns nil
func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
  guard
    let a = a,
    let b = b
    else { return nil }
  return (a, b)
}

/// Returns a tuple of the non-optional parameters passed to the function
/// - Parameters:
///   - a: the first parameter
///   - b: the second parameter
///   - c: the third parameter
/// - Returns: a tuple of the first, second and third paramter not nil,
/// only if all parameters are not nil, otherwise it returns nil
func zip<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
  guard
    let a = a,
    let b = b,
    let c = c
    else { return nil }
  return (a, b, c)
}

/// Returns a tuple of the non-optional parameters passed to the function
/// - Parameters:
///   - a: the first parameter
///   - b: the second parameter
///   - c: the third parameter
///   - d: the fourth parameter
/// - Returns: a tuple of the first, second, third and fourth paramter not nil,
/// only if all parameters are not nil, otherwise it returns nil
func zip<A, B, C, D>(_ a: A?, _ b: B?, _ c: C?, _ d: D?) -> (A, B, C, D)? {
  guard
    let a = a,
    let b = b,
    let c = c,
    let d = d
    else { return nil }
  return (a, b, c, d)
}

/// Returns a tuple of the non-optional parameters passed to the function
/// - Parameters:
///   - a: the first parameter
///   - b: the second parameter
///   - c: the third parameter
///   - d: the fourth parameter
///   - e: the fifth parameter
/// - Returns: a tuple of the first, second, third, fourth and fifth paramter not nil,
/// only if all parameters are not nil, otherwise it returns nil
func zip<A, B, C, D, E>(_ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?) -> (A, B, C, D, E)? {
  guard
    let a = a,
    let b = b,
    let c = c,
    let d = d,
    let e = e
    else { return nil }
  return (a, b, c, d, e)
}

func resignFirstResponder() {
  UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
