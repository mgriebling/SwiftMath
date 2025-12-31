import Foundation

final class KeyBox<Value: Hashable>: NSObject {
  let wrappedValue: Value

  init(_ wrappedValue: Value) {
    self.wrappedValue = wrappedValue
  }

  override var hash: Int {
    var hasher = Hasher()
    hasher.combine(wrappedValue)
    return hasher.finalize()
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let other = object as? KeyBox<Value> else {
      return false
    }
    return wrappedValue == other.wrappedValue
  }
}
