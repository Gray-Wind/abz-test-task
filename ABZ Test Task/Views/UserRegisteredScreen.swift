//
//  UserRegisteredScreen.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/// The screen to be shown after sign up process succeeded
struct UserRegisteredScreen: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SheetScreenContainer {
            VStack(spacing: 16) {
                Image(.userSuccessfullyRegistered)
                Text("User successfully registered")
                    .font(.abzHeading1)
                PrimaryFilledButton(label: "Got it") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    UserRegisteredScreen()
}
