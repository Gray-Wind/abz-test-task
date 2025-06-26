//
//  TextField.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/// The standard text field for the task
struct ABZTextField: View {

    /// Styles in the one place to make it easier to customize the view
    private struct Styles {
        // TODO: move more magic constants here
        static let textFieldHeight: CGFloat = 55
    }

    /// The label of the text field view to be shown on the top of it
    var label: String
    /// The binding text for the text field
    @Binding var text: String
    /// The supporting text to be shown on the bottom of the text field
    var supportingText: String?
    /// The error to be shown for the text field
    ///
    /// The error will replace to supporting text.
    var fieldError: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                if !text.isEmpty || isFocused {
                    Text(label)
                        .font(.abzBody3)
                        .foregroundStyle(placeholderShapeStyle)
                        .padding(.leading)
                }
                TextField("", text: $text, prompt: isFocused ? nil : Text(label).foregroundStyle(placeholderShapeStyle))
                    .padding(.horizontal)
                    .font(.abzBody1)
                    .focused($isFocused)
            }
            .frame(height: Styles.textFieldHeight)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        borderColor,
                        lineWidth: isFocused && !isError ? 2 : 1
                    )
            }
            if let fieldError {
                Text(fieldError)
                    .font(.abzBody3)
                    .padding(.horizontal)
                    .fontWeight(.light)
                    .foregroundStyle(.textFieldError)
            } else if let supportingText {
                Text(supportingText)
                    .font(.abzBody3)
                    .fontWeight(.light)
                    .padding(.horizontal)
            }
        }
        .padding(.all, 1)  // so overlay could be drawn normally
    }

    private var placeholderShapeStyle: any ShapeStyle {
        if isError {
            return .textFieldError
        }
        if text.isEmpty {
            return isFocused ? .secondaryApp : .primary
        }
        return .placeholder
    }

    private var borderColor: Color {
        if isError {
            return .textFieldError
        }
        return isFocused ? .secondaryApp : .secondary
    }

    private var isError: Bool {
        fieldError != nil
    }
}

#Preview {
    @Previewable @State var text1 = ""
    @Previewable @State var text2 = ""
    @Previewable @State var text3 = ""

    VStack {
        ABZTextField(
            label: "Label",
            text: $text1,
            supportingText: "Supporting text"
        )
        ABZTextField(
            label: "Label",
            text: $text2,
            supportingText: "Supporting text"
        )
        ABZTextField(
            label: "Label",
            text: $text3,
            supportingText: "Supporting text",
            fieldError: "Error text"
        )
    }
    .padding()
}
