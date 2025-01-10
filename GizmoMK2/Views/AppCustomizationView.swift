//
//  AppCustomizationView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/20/24.
//

import SwiftUI

struct AppCustomizationView: View {
    @EnvironmentObject var appState : AppState
    @State var appToCustomize: AppInfoModel
    
    var body: some View {
        Form {
            
            Section(header: Text("Associated Pages")) {
                List {
                    ForEach(appState.pages) {
                        AppCustomizationPageRowView(page: $0, appInfo: appToCustomize)
                    }
                }
            }
        }
        .navigationTitle(appToCustomize.name)
    }
}

struct AppCustomizationPageRowView : View {
    @EnvironmentObject var appState : AppState
    @State var page : PageModel
    @State var appInfo : AppInfoModel
    @State var isOn : Bool = false
    var body : some View {
        Toggle(isOn: $isOn) {
            Text(page.name)
        }
        .onChange(of: isOn) {
            let appIndex = appState.appInfos.firstIndex(where: {$0 == appInfo})
            if appIndex != nil {
                appState.appInfos[appIndex!].associatedPageIDs[page.id] = isOn
                appState.updateAppInfo(appInfo: appState.appInfos[appIndex!])
            }
        }
        .onAppear {
            let appIndex = appState.appInfos.firstIndex(where: {$0 == appInfo})
            if appIndex != nil {
                if appState.appInfos[appIndex!].associatedPageIDs[page.id] != nil || appState.appInfos[appIndex!].associatedPageIDs[page.id] == true{
                    isOn = true
                }
            }
        }
    }
}

#Preview {
    AppCustomizationView(appToCustomize: AppInfoModel(name: "Test App", bundleID: "")).environmentObject(AppState())
}
