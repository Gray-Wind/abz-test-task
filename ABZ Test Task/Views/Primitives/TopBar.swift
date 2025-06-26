//
//  TopBar.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/// The top bar shown on top of the tab views
struct TopBar: View {

    /// The title to be show on the top bar
    var title: String

    var body: some View {
        Text(title)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(.primaryApp)
            .font(.abzHeading1)
    }
}

#Preview {
    TopBar(title: "Working with GET request")
}
