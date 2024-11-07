// Copyright Justin Bishop, 2024

import SwiftUI

public struct AlertConfig {
  public let title: String
  public var message: () -> AnyView
  public var actions: () -> AnyView

  public init(
    title: String,
    @ViewBuilder message: @escaping () -> some View = {
      EmptyView()
    },
    @ViewBuilder actions: @escaping () -> some View = {
      Button("OK", action: {})
    }
  ) {
    self.title = title
    self.message = { AnyView(message()) }
    self.actions = { AnyView(actions()) }
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
          actions
        }
      },
      message: {
        if let message = config.wrappedValue?.message() {
          message
        }
      }
    )
  }
}
