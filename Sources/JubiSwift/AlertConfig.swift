// Copyright Justin Bishop, 2024

import SwiftUI

public struct AlertConfig {
  public let title: String
  public var message: () -> any View
  public var actions: () -> any View

  // Public initializer with default values for message and actions
  public init(
    title: String,
    message: @escaping () -> any View = { EmptyView() },
    actions: @escaping () -> any View = { Button("OK", action: {}) }
  ) {
    self.title = title
    self.message = message
    self.actions = actions
  }
}

extension View {
  public func customAlert(config: Binding<AlertConfig?>) -> some View {
    alert(
      config.wrappedValue?.title ?? "",
      isPresented: Binding(
        get: { config.wrappedValue != nil },
        set: { isShown in
          if !isShown {
            config.wrappedValue = nil
          }
        }
      ),
      actions: {
        if let actions = config.wrappedValue?.actions() {
          AnyView(actions)
        }
      },
      message: {
        if let message = config.wrappedValue?.message() {
          AnyView(message)
        }
      }
    )
  }
}
