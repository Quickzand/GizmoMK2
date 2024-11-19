//
//  ContentView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 10/27/24.
//

import SwiftUI
import SwiftUIIntrospect

struct ContentView: View {
    
    @EnvironmentObject var appState : AppState

    var NavigationButtons : some View {
        let buttonSize = 20.0
        let buttonPadding = 10.0
        return HStack {
            VStack(alignment: .leading) {
                Button(action: {
                    appState.executorCreationModel = ExecutorModel(label:"Default Label")
                    appState.executorCreationShown = true
                }) {Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: buttonSize, height:buttonSize)
                                        .padding(buttonPadding)
                
                                }
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
                .cornerRadius(500)
                Button {
                    withAnimation {
                        appState.editMode.toggle()
                    }
                } label: {Image(systemName: appState.editMode ?   "checkmark" : "pencil")
                        .resizable()
                        .frame(width: buttonSize, height:buttonSize)
                        .padding(buttonPadding)
                        
                }
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
                .cornerRadius(500)
                NavigationLink(destination: SettingsView()) {Image(systemName: "gear")
                        .resizable()
                        .frame(width: buttonSize, height:buttonSize)
                        .padding(buttonPadding)
                        
                }
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
                .cornerRadius(500)
            }
            .padding(.leading, 5)
            Spacer()
        }
    }
    
    var body: some View {
        NavigationStack {
            if(appState.connection == nil){
                ConnectToHostView()
            } else {
                ZStack {
                    TabView(selection:$appState.currentPageID) {
                        ForEach(appState.pages.indices, id: \.self) {index in
                            PageView(pageNum: index)
                                .tag(appState.pages[index].id)
                        }
                    }
                    .tabViewStyle(.page)
                    .introspect(.tabView(style: .page), on: .iOS(.v18)) {
                        $0.backgroundColor = .clear
                    }
                    NavigationButtons
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BackgroundView()) 
            }
            
               
        }
        
    }
}






#Preview {
    ContentView().environmentObject(AppState())
}
