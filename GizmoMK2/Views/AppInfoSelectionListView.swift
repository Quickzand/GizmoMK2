//
//  AppsCustomizationListView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/20/24.
//

import SwiftUI

struct AppInfoSelectionListView: View {
    @EnvironmentObject var appState : AppState
    @State var searchText : String = ""
    
    @Binding var selectedAppBundleId : String
    
    @Environment(\.presentationMode) var presentationMode
    
    var navigationSelection : Bool = false
    
    var body: some View {
        ScrollView([.vertical]) {
            LazyVGrid(columns:[GridItem(), GridItem(), GridItem()] ) {
                ForEach(searchResults, id:\.self) {appInfo in
                    Group {
                        if navigationSelection {
                            NavigationLink(destination: AppCustomizationView(appToCustomize: appInfo)) {
                                AppButtonView(appInfo: appInfo)
                            }
                        }
                        else {
                            Button(action: {
                                selectedAppBundleId = appInfo.bundleID
                                presentationMode.wrappedValue.dismiss()
                                
                            }) {
                                AppButtonView(appInfo:appInfo)
                            }
                        }
                    }
                    .onAppear {
                        if(appInfo.appIcon == nil) {
                            appState.requestAppIcon(bundleID: appInfo.bundleID)
                        }
                    }
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
        let filteredResults: [AppInfoModel]
        
        if searchText.isEmpty {
            filteredResults = appState.appInfos
        } else {
            filteredResults = appState.appInfos.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return filteredResults.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
}

#Preview {
    AppInfoSelectionListView(selectedAppBundleId: .constant("")).environmentObject(AppState())
}

struct AppButtonView: View {
    var appInfo : AppInfoModel
    
    var body: some View {
        LazyVStack {
            if let appIcon = appInfo.appIcon {
                Image(uiImage: UIImage(cgImage: appIcon)).resizable()
                    .frame(width:100, height:100)
            }
            else {
                VStack {
                    
                }.frame(width:100, height:100)
                    .background(.thickMaterial)
            }
            Text(appInfo.name)
                .scaledToFill()
                .minimumScaleFactor(0.25)
                .lineLimit(1)
                .foregroundStyle(.foreground)
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(25)
    }
}
