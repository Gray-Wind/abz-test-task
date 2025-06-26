//
//  SheetScreenContainer.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/// The sheet screen container to standardize the sheet view
///
/// You need just to include the content view and you will have a nice sheet view.
struct SheetScreenContainer<ContentView: View>: View {

    /// The content of the sheet screen container
    @ViewBuilder let content: ContentView

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(.close)
                    }

                }
                Spacer()
            }
            .padding()

            content
        }
    }
}
