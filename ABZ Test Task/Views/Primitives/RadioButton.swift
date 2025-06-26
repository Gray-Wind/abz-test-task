//
//  RadioButton.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/// The data for an element of the radio button control
struct RadioButtonElement {

    /// The id of the radio button element
    let id: Int
    /// The title of the radio button
    let title: String
}

/// The radio button group view
///
/// The current version only support text based elements in the view.
struct RadioButtonGroup: View {

    /// The title of the radio button group
    let groupTitle: String
    /// Elements to show in the radio button group
    ///
    /// NB: in the future it would be nice to use @ViewBuilder here
    let elements: [RadioButtonElement]
    @Binding var currentElementId: Int?

    var body: some View {
        VStack(alignment: .leading) {
            Text(groupTitle)
                .font(.abzBody2)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(elements, id: \.id) { element in
                RadioButton(text: element.title, isOn: currentElementId == element.id) {
                    currentElementId = element.id
                }
                .padding(.leading, 8)
            }
        }
    }
}

/// The radio button itself for the radio button group
private struct RadioButton: View {

    let text: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                isOn ? Image(.radioButtonFilled) : Image(.radioButtonEmpty)
                Text(text)
                    .font(.abzBody1)
            }
        }
        .buttonStyle(RadioButtonStyle())
    }
}

private struct RadioButtonStyle: ButtonStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
    }
}

#Preview {
    @Previewable @State var currentElement: Int? = nil
    RadioButtonGroup(
        groupTitle: "Select your position",
        elements: [.init(id: 1, title: "Frontend developer"), .init(id: 2, title: "Backend developer"), .init(id: 3, title: "Mobile developer")],
        currentElementId: $currentElement
    )
}
