//
//  NoInternetScreen.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/// The no internet screen to be shown once there are problems while connecting to internet
struct NoInternetScreen: View {

    var action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(.noInternet)

            Text("There is no internet connection")
                .font(.abzHeading1)

            PrimaryFilledButton(label: "Try Again") {
                action()
            }
        }
    }
}

#Preview {
    NoInternetScreen() {}
}
