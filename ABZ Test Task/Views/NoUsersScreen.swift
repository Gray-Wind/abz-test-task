//
//  NoUsersScreen.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/// No users screen shown when there are no users on the users tab
struct NoUsersScreen: View {

    var body: some View {
        VStack(spacing: 16) {
            Image(.noUsers)
            Text("There are no users yet")
                .font(.abzHeading1)
        }
    }
}

#Preview {
    NoUsersScreen()
}
