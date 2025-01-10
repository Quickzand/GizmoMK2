//
//  AppsCustomizationListView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/20/24.
//

import SwiftUI

struct AppsCustomizationListView: View {
    @EnvironmentObject var appState : AppState
    @State var searchText : String = ""
    var body: some View {
        List {
            ForEach(searchResults, id:\.self) {appInfo in
                NavigationLink(destination: AppCustomizationView(appToCustomize: appInfo)) {
                    Text(appInfo.name)
                }
            }
        }
        .navigationTitle("App Customizations")
        .onAppear {
            appState.requestAppInfos()
        }
        .searchable(text:$searchText)
    }
    var searchResults: [AppInfoModel] {
        if searchText.isEmpty {
            return appState.appInfos
        } else {
            return appState.appInfos.filter { $0.name.contains( searchText) }
        }
    }
}

#Preview {
    AppsCustomizationListView().environmentObject(AppState())
}
