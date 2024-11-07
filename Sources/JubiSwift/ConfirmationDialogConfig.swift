// Copyright Justin Bishop, 2024

import SwiftUI

public struct ConfirmationDialogConfig {
  public let title: String
  public var titleVisibility: Visibility
  public var actions: () -> any View
  public var message: () -> any View

  public init(
    title: String,
    titleVisibility: Visibility = .automatic,
    actions: @escaping () -> any View = { Button("Cancel", role: .cancel) {} },
    message: @escaping () -> any View = { EmptyView() }
  ) {
    self.title = title
    self.titleVisibility = titleVisibility
    self.actions = actions
    self.message = message
  }
}

extension View {
  public func customConfirmationDialog(config: Binding<ConfirmationDialogConfig?>) -> some View {
    confirmationDialog(
      config.wrappedValue?.title ?? "",
      isPresented: Binding(
        get: { config.wrappedValue != nil },
        set: { isShown in
          if !isShown {
            config.wrappedValue = nil
          }
        }
      ),
      titleVisibility: config.wrappedValue?.titleVisibility ?? .automatic,
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
