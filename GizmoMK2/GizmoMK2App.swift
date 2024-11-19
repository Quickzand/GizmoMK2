//
//  GizmoMK2App.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 10/27/24.
//

import SwiftUI

@main
struct GizmoMK2App: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
        }
    }
}
