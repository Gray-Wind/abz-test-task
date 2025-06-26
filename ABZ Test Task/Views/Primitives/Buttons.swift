//
//  Buttons.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/// The primary filled button
struct PrimaryFilledButton: View {

    var label: String
    var action: () -> Void

    @Environment(\.isEnabled) private var isEnabled: Bool

    var body: some View {
        Button(label) {
            action()
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }
}

/// The secondary button
struct SecondaryButton: View {

    var label: String
    var action: () -> Void

    @Environment(\.isEnabled) private var isEnabled: Bool

    var body: some View {
        Button(label) {
            action()
        }
        .buttonStyle(SecondaryButtonStyle(isEnabled: isEnabled))
    }
}

private struct PrimaryButtonStyle: ButtonStyle {

    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal)
            .padding(.vertical)
            .frame(minWidth: 140)
            .font(.abzHeading1)
            .fontWeight(.medium)
            .background(background(configuration: configuration))
            .foregroundStyle(foreground)
            .clipShape(Capsule())
    }

    var foreground: Color {
        isEnabled ? .primary : .secondary
    }

    func background(configuration: Configuration) -> Color {
        if isEnabled {
            return configuration.isPressed ? .primaryButtonPressed : .primaryApp
        }
        return .primaryButtonDisabled
    }
}

private struct SecondaryButtonStyle: ButtonStyle {

    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal)
            .padding(.vertical, 10)
            .font(.abzBody1)
            .foregroundColor(foreground)
            .background(background(configuration: configuration))
            .clipShape(Capsule())
    }

    var foreground: Color {
        isEnabled ? .secondaryButtonText : .secondary
    }

    func background(configuration: Configuration) -> Color {
        if isEnabled {
            return configuration.isPressed ? .secondaryButtonPressed : .clear
        }
        return .clear
    }
}

#Preview {
    VStack {
        HStack {
            PrimaryFilledButton(label: "Tap me") {}
            PrimaryFilledButton(label: "Tap me2") {}
                .disabled(true)
        }
        HStack {
            SecondaryButton(label: "Tap me") {}
            SecondaryButton(label: "Tap me2") {}
                .disabled(true)
        }
    }
}
