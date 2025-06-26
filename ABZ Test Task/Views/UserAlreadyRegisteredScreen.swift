//
//  UserAlreadRegisteredScreen.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/// The screen to be shown after sign up process failed due to existing user
struct UserAlreadyRegisteredScreen: View {

    var action: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SheetScreenContainer {
            VStack(spacing: 16) {
                Image(.userAlreadyRegistered)
                Text("That email is already registered")
                    .font(.abzHeading1)
                PrimaryFilledButton(label: "Try again") {
                    action()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    UserAlreadyRegisteredScreen {}
}
