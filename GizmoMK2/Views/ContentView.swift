//
//  ContentView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 10/27/24.
//

import SwiftUI
import SwiftUIIntrospect

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            if appState.connection == nil {
                // Not connected yet
                ConnectToHostView()
            } else {
                HomeView()
            }
        }
    }
}

