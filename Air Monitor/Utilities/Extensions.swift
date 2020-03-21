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
    formatter.numberStyle = .decimal
    return formatter
  }
}

extension DateFormatter {
  static var airParameterFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.calendar = Calendar.current
    formatter.locale = Calendar.current.locale
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter
  }
}
