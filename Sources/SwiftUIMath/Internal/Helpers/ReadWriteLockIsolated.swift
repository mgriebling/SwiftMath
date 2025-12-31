import Foundation

@dynamicMemberLookup
final class ReadWriteLockIsolated<Value>: @unchecked Sendable {
  private var _value: Value
  private let lock: UnsafeMutablePointer<pthread_rwlock_t> = .create()

  init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
    self._value = try value()
  }

  deinit {
    lock.destroy()
  }

  subscript<Subject: Sendable>(dynamicMember keyPath: KeyPath<Value, Subject>) -> Subject {
    self.lock.sync {
      self._value[keyPath: keyPath]
    }
  }

  func withValue<T: Sendable>(
    _ operation: @Sendable (inout Value) throws -> T
  ) rethrows -> T {
    try self.lock.sync {
      var value = self._value
      defer { self._value = value }
      return try operation(&value)
    }
  }

  func setValue(_ newValue: @autoclosure @Sendable () throws -> Value) rethrows {
    try self.lock.sync {
      self._value = try newValue()
    }
  }
}

extension ReadWriteLockIsolated where Value: Sendable {
  var value: Value {
    self.lock.sync {
      self._value
    }
  }
}

extension UnsafeMutablePointer where Pointee == pthread_rwlock_t {
  fileprivate static func create() -> Self {
    // allocate on the heap to create a stable pointer
    let lock = Self.allocate(capacity: 1)
    lock.initialize(to: pthread_rwlock_t())
    pthread_rwlock_init(lock, nil)
    return lock
  }

  fileprivate func destroy() {
    pthread_rwlock_destroy(self)
    self.deinitialize(count: 1)
    self.deallocate()
  }

  fileprivate func sync<R>(work: () throws -> R) rethrows -> R {
    pthread_rwlock_wrlock(self)
    defer { pthread_rwlock_unlock(self) }
    return try work()
  }
}
