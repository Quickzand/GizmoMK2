//
//  PagesListView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/20/24.
//

import SwiftUI

struct PagesListView: View {
    @EnvironmentObject var appState : AppState
    
    var body: some View {
        List {
            ForEach(appState.pages) { page in
                PageRow(page: page)
            }.onDelete(perform: {
                let indexSet = $0
                appState.deletePage(withID: appState.pages[indexSet.first!].id)
                
                
            })
        }
        .navigationTitle("Pages")
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: PageCreationSheetView()) {
                    Label("Add", systemImage: "plus" )
                }
            }
        }
            .onAppear {
                appState.requestPages()
            }
    }
}


struct PageRow : View {
    var page : PageModel
    var body : some View {
        NavigationLink(destination: PageCreationSheetView(page: page, isEditing: true)) {
            Text(page.name)
        }
    }
}

#Preview {
    PagesListView().environmentObject(AppState())
}
