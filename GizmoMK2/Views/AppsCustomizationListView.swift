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
        ScrollView([.vertical]) {
            LazyVGrid(columns:[GridItem(), GridItem(), GridItem()] ) {
                ForEach(searchResults, id:\.self) {appInfo in
                    NavigationLink(destination: AppCustomizationView(appToCustomize: appInfo)) {
                        LazyVStack {
                            if let appIcon = appInfo.appIcon {
                                Image(uiImage: UIImage(cgImage: appIcon)).resizable()
                                    .frame(width:50, height:50)
                            }
                            else {
                                VStack {
                                    
                                }.frame(width:50, height:50)
                                    .background(.thickMaterial)
                            }
                            Text(appInfo.name)
                                .scaledToFill()
                                   .minimumScaleFactor(0.25)
                                   .lineLimit(1)
                                   .foregroundStyle(.foreground)
                        }
                        .padding(.all,5)
                        .background(.thinMaterial)
                        .cornerRadius(25)
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
