//
//  SettingsView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Form {
            Section(header:Text("General")) {
                NavigationLink("Host", destination: ConnectToHostView())
                Toggle(isOn: $appState.settings.backgroundEnabled) {
                    Text("Background")
                }
            }
            
            
            Section(header: EmptyView()) {
                NavigationLink("Pages", destination: PagesListView())
                NavigationLink("Apps Customization", destination: AppInfoSelectionListView(selectedAppBundleId: .constant(""),navigationSelection: true))
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
