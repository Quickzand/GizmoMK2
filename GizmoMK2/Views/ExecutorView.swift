//
//  ExecutorView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/10/24.
//

import SwiftUI

struct ExecutorView: View {
    @EnvironmentObject var appState: AppState
    

    
    var executor : ExecutorModel
    
    
    @State var itemWidth : CGFloat = 100
    @State var cellCornerRadius : CGFloat = 10
    @State var scale = 0.0
    
    func getCurrentRotation() -> Angle {
        
        switch appState.deviceOrientation {
        case .landscapeLeft:
            return Angle(degrees: 90.0)
        case .landscapeRight:
            return Angle(degrees: -90.0)
        default:
            return Angle(degrees: 0.0)
        }
    }
    
    var ExecutorBody : some View {
        Button(action: {
            appState.executeAction(actionID: executor.actionID)
        }) {
            ZStack {
                VStack {
                    if !executor.iconHidden {
                        Image(systemName: executor.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(executor.iconHidden ? 0.0 : 1.0)
                    }
                    if !executor.labelHidden {
                        Text(executor.label)
                            .opacity(executor.labelHidden ? 0.0 : 1.0)
                    }
                }
            }
            .padding(.all, 2)
                .frame(width: itemWidth, height: itemWidth)
                
                .background(Color(hex:executor.backgroundColor).opacity(executor.backgroundOpacity)) // Background for filled cells
                .cornerRadius(cellCornerRadius)
        }
        .overlay {
            if appState.editMode {
                ZStack {
//                                    Edit button
                    Button(action: {
                        appState.executorCreationModel = executor
                        appState.executorCreationShown = true
                    }) {
                        Color.clear
                    }
                    
                    
//                                    Delete button
                    Button(action: {
                        appState.deleteExecutor(id: executor.id)
                    }) {
                        Image(systemName:"x.circle.fill")
                            .padding()
                    }
                    .position(CGPoint(x: 0,y: 0))
                    .offset(x: 5,y: 5)
                }
            }
        }.foregroundStyle(.foreground)
            .rotationEffect(
                withAnimation {getCurrentRotation()
                })
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(.bouncy(), blendDuration: 1.5)) {
                    scale = 1
                }
            }
    }
    
    
    var body: some View {
        if appState.editMode {
            ExecutorBody.draggable(executor)
        }
        else {
            ExecutorBody
        }
       
    }
}

#Preview {
    ExecutorView(executor: ExecutorModel(label:"Test")).environmentObject(AppState())
}
