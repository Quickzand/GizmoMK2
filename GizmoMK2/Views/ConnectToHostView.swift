//
//  ConnectToClientView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/3/24.
//

import SwiftUI

struct ConnectToHostView: View {
    @EnvironmentObject var appState : AppState
    var body: some View {
        VStack {
            List(appState.foundHosts) {host in
                Button(action:{
                    appState.connectToHost(host)}) {
                        Text(host.name + ": ")
                    }
            }
            .onChange(of: appState.foundHosts) { _ in
//                            If any of the hosts name match previouslyFoundHost then connect to it
                if let previouslyFoundHost = appState.foundHosts.first(where:{ appState.settings.previouslyConnectedHostName == $0.name}) {
                    appState.connectToHost(previouslyFoundHost)
                }
                
            }
            .onAppear {
                appState.startBrowsing()
            }
            .onDisappear {
                appState.stopBrowsing()
            }
            Text("Searching for hosts...")
        }
    }
}

#Preview {
    ConnectToHostView().environmentObject(AppState())
}
