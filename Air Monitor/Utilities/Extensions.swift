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
  
  func sorted<T: Comparable>(by kp: KeyPath<Element, T>, comparator: (T, T) -> Bool) -> Self {
    return self.sorted { comparator($0[keyPath: kp], $1[keyPath: kp]) }
  }
  
  func sorted<T: Comparable>(by kp: KeyPath<Element, T>) -> Self {
    return self.sorted(by: kp, comparator: <)
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

extension ISO8601DateFormatter {
  static var openAqiDateFormatter: ISO8601DateFormatter {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [
      .withInternetDateTime,
      .withFractionalSeconds
      ]
    return dateFormatter
  }
}

extension Date {
  func isInTheSameDay(of date2: Date) -> Bool {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar.isDate(self, equalTo: date2, toGranularity: .day)
  }
  
  func toMidnight(in timeZone: TimeZone) -> Date? {
    var calendar = Calendar.current
    calendar.timeZone = timeZone
    return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)
  }
}
