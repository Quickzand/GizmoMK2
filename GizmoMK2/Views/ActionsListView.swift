//
//  ActionsListView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import SwiftUI

struct ActionsListView: View {
    @EnvironmentObject var appState : AppState
    var body: some View {
        List {
            ForEach(appState.actions) { action in
                ActionRow(action: action)
            }.onDelete(perform: {
                let indexSet = $0
                appState.deleteAction(id: appState.actions[indexSet.first!].id)
                
                
            })
        }
        .navigationTitle("Actions")
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: ActionCreationView()) {
                    Label("Add", systemImage: "plus" )
                }
            }
        }
            .onAppear {
                appState.requestActions()
                appState.requestShortcuts()
            }
    }
}


struct ActionRow : View {
    var action : ActionModel
    var body : some View {
        NavigationLink(destination: ActionCreationView(action: action, isEditing: true)) {
            Text(action.name)
        }
    }
}

#Preview {
    ActionsListView().environmentObject(AppState())
}
