import Foundation

extension Array {
  func map<T>(_ kp: KeyPath<Element, T>) -> [T] {
    return map { $0[keyPath: kp] }
  }
}
