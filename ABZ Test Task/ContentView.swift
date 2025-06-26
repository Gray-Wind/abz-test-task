//
//  ContentView.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            Tab("Users", systemImage: "person.3.sequence.fill") {
                VStack {
                    TopBar(title: "Working with GET request")
                    UsersScreen()
                }
            }

            Tab("Sign up", systemImage: "person.crop.circle.fill.badge.plus") {
                VStack {
                    TopBar(title: "Working with POST request")
                    SignUpScreen()
                }
            }
        }
        .tabViewSidebarBottomBar(content: {
            Text("aaa")
        })
        .toolbarBackground(.red, for: .tabBar)
        .toolbarBackgroundVisibility(.visible, for: .tabBar)
        .toolbar(.visible, for: .tabBar)
        .accentColor(.secondaryApp)
    }
}

#Preview {
    ContentView()
}
