// Copyright Justin Bishop, 2024

import SwiftUI

public struct ConfirmationDialogConfig {
  public let title: String
  public var titleVisibility: Visibility
  public var actions: () -> AnyView
  public var message: () -> AnyView

  public init(
    title: String,
    titleVisibility: Visibility = .automatic,
    @ViewBuilder actions: @escaping () -> some View = {
      Button("Cancel", role: .cancel) {}
    },
    @ViewBuilder message: @escaping () -> some View = {
      EmptyView()
    }
  ) {
    self.title = title
    self.titleVisibility = titleVisibility
    self.actions = { AnyView(actions()) }
    self.message = { AnyView(message()) }
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
