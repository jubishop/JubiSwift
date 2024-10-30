// Copyright Justin Bishop, 2024

import SwiftUI

public struct AlertConfig {
  let title: String
  var message: () -> any View = { EmptyView() }
  var actions: () -> any View = { Button("OK", action: {}) }
}

extension View {
  func customAlert(config: Binding<AlertConfig?>) -> some View {
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

