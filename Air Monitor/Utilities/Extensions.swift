import Foundation

extension Array {
  func map<T>(_ kp: KeyPath<Element, T>) -> [T] {
    return map { $0[keyPath: kp] }
  }
  
  func min<T: Comparable>(by kp: KeyPath<Element, T>) -> Element? {
    return self.min { $0[keyPath: kp] < $1[keyPath: kp] }
  }
  
  func max<T: Comparable>(by kp: KeyPath<Element, T>) -> Element? {
    return self.max { $0[keyPath: kp] < $1[keyPath: kp] }
  }
}

extension NumberFormatter {
  static var singleDecimal: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.locale = Calendar.current.locale
    formatter.maximumFractionDigits = 1
    formatter.minimumFractionDigits = 0
    return formatter
  }
}
