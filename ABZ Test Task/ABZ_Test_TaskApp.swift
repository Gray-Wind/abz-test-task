//
//  ABZ_Test_TaskApp.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI
import OSLog

let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.example.ABZ-Test-Task", category: "ABZ-Test-Task")

@main
struct ABZ_Test_TaskApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
