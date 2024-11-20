//Copyright (C) 2021 Gwendal Roué
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Combine
import SwiftUI

// See https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/environmentstateobject
@propertyWrapper
@MainActor public struct EnvironmentStateObject<ObjectType>: DynamicProperty
where ObjectType: ObservableObject {
  /// The environment values.
  @Environment(\.self) private var environmentValues

  /// The SwiftUI `StateObject` that deals with the lifetime of the
  /// observable object.
  @StateObject private var core = Core()

  /// The closure that creates an instance of the observable object.
  private let makeObject: (EnvironmentValues) -> ObjectType

  /// Creates a new ``EnvironmentStateObject`` with a closure that builds an
  /// object from environment values.
  public init(_ makeObject: @escaping (EnvironmentValues) -> ObjectType) {
    self.makeObject = makeObject
  }

  /// The underlying object.
  public var wrappedValue: ObjectType {
    // If `core.object` is nil, this means that `wrappedValue` is accessed
    // before `update()` was called, and SwiftUI would provide the expected
    // context in the environment.
    //
    // This is a programmer error. We count on SwiftUI to emit a
    // runtime warning:
    //
    // > Accessing StateObject's object without being installed on a
    // > View. This will create a new instance each time.
    core.object ?? makeObject(environmentValues)
  }

  /// A projection that creates bindings to the properties of the
  /// underlying object.
  public var projectedValue: Wrapper {
    Wrapper(object: wrappedValue)
  }

  /// Part of the SwiftUI `DynamicProperty` protocol. Do not call this method.
  nonisolated public func update() {
    MainActor.assumeIsolated {
      core.update(makeObject: { makeObject(environmentValues) })
    }
  }

  /// A wrapper of the underlying object that can create bindings to its
  /// properties using dynamic member lookup.
  @MainActor @dynamicMemberLookup public struct Wrapper {
    fileprivate let object: ObjectType

    #if compiler(>=6)
      /// Returns a binding to the resulting value of a given key path.
      public subscript<U>(
        dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, U>
          & Sendable
      ) -> Binding<U> {
        Binding(
          get: { object[keyPath: keyPath] },
          set: { object[keyPath: keyPath] = $0 }
        )
      }
    #else
      public subscript<U>(
        dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, U>
      ) -> Binding<U> {
        Binding(
          get: { object[keyPath: keyPath] },
          set: { object[keyPath: keyPath] = $0 }
        )
      }
    #endif
  }

  /// An observable object that keeps a strong reference to the object,
  /// and publishes its changes.
  private class Core: ObservableObject {
    let objectWillChange = PassthroughSubject<
      ObjectType.ObjectWillChangePublisher.Output, Never
    >()
    private var cancellable: AnyCancellable?
    private(set) var object: ObjectType?

    func update(makeObject: () -> ObjectType) {
      guard object == nil else { return }
      let object = makeObject()
      self.object = object

      // Transmit all object changes
      var isUpdating = true
      cancellable = object.objectWillChange.sink { [weak self] value in
        guard let self = self else { return }
        if !isUpdating {
          // Avoid the runtime warning in the case of publishers
          // that publish values right on subscription:
          // > Publishing changes from within view updates is not
          // > allowed, this will cause undefined behavior.
          self.objectWillChange.send(value)
        }
      }
      isUpdating = false
    }
  }
}
