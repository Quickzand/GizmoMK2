//
//  ActionsListView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

//import SwiftUI
//
//struct ActionsListView: View {
//    @EnvironmentObject var appState : AppState
//    var body: some View {
//        List {
//            ForEach(appState.actions) { action in
//                ActionRow(action: action, isSelected: false, onTap: {})
//            }.onDelete(perform: {
//                let indexSet = $0
//                appState.deleteAction(id: appState.actions[indexSet.first!].id)
//                
//                
//            })
//        }
//        .navigationTitle("Actions")
//        .toolbar {
//            ToolbarItem {
//                NavigationLink(destination: ActionCreationView()) {
//                    Label("Add", systemImage: "plus" )
//                }
//            }
//        }
//            .onAppear {
//                appState.requestActions()
//                appState.requestShortcuts()
//            }
//    }
//}
//
//
//#Preview {
//    ActionsListView().environmentObject(AppState())
//}
