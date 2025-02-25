//
//  ExecutorView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/10/24.
//

import SwiftUI
import UIKit // Import UIKit for haptic feedback

struct ExecutorView: View {
    @EnvironmentObject var appState: AppState

    var executor: ExecutorModel

    @State var itemWidth: CGFloat = 100
    @State var cellCornerRadius: CGFloat = 10
    @State var scale = 0.0

    
    
    // State variables for knob rotation
    @State public var currentAngle: Double = 0.0
    @State public var lastAngle: Double = 0.0
    @State public var isDragging: Bool = false

    // State variables to track the notches
    @State public var lastNotchIndex: Int = 0
    @State public var lastActionNotchIndex: Int = 0 // Variable for action notch index
    
    @State public var isPressed : Bool = false
    
    @State private var showDeleteConfirmation = false
    
    @State public var successCount : Int = 0
    
    

    
    
    var gestureView: some View {
        Group {
            ZStack {
                VStack {
                    if !executor.iconHidden {
                        Image(systemName: executor.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    if !executor.labelHidden {
                        Text(executor.label)
                            .frame(maxWidth: itemWidth - 10)
                            .opacity(executor.labelHidden ? 0.0 : 1.0)
                            .scaledToFill()
                               .minimumScaleFactor(0.25)
                               .lineLimit(1)
                    }
                }
                .foregroundStyle(Color(hex: executor.foregroundColor))
            }
            .padding(2)
            .frame(width: itemWidth, height: itemWidth)
            .background(
                ZStack {
                    
                    Circle()
                        .fill(.primaryAccent)
                        .frame(width:100, height:100)
                        .blur(radius:30)
                    // Your existing background color
                    Color(hex: executor.backgroundColor).opacity(executor.backgroundOpacity)
                   
                    // The grid overlay
                    GridBackground(lineSpacing: 10, lineColor: Color(hex:executor.foregroundColor).opacity(0.15))
                    
                    
                }
            )
            .cornerRadius(cellCornerRadius)
            .shadow(radius: 15)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        let dx = value.translation.width
                        let dy = value.translation.height
                        if abs(dx) > abs(dy) {
                            if dx > 0 {
                                // Swipe right
                                appState.executeAction(executorID: executor.id, actionContextOption: .rightAction)
                            } else {
                                // Swipe left
                                appState.executeAction(executorID: executor.id, actionContextOption: .leftAction)
                            }
                        } else {
                            if dy > 0 {
                                // Swipe down
                                appState.executeAction(executorID: executor.id, actionContextOption: .downAction)
                            } else {
                                // Swipe up
                                appState.executeAction(executorID: executor.id, actionContextOption: .upAction)
                            }
                        }
                    }
            )
        }
    }
    
    var displayView : some View {
        Group {
            ZStack {
                VStack {
                    if !executor.iconHidden {
                        Image(systemName: executor.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    if !executor.labelHidden {
                        Text(executor.label)
                        
                    }
                }
                .foregroundStyle(Color(hex: executor.foregroundColor))
            }
            .padding(2)
            .frame(width: itemWidth, height: itemWidth)
            .background(
                ZStack {
                    
                    Circle()
                        .fill(.primaryAccent)
                        .frame(width:100, height:100)
                        .blur(radius:30)
                    
                    Color(hex: executor.backgroundColor).opacity(executor.backgroundOpacity)
                    
                    
                }
            )
            .cornerRadius(cellCornerRadius)
            .shadow(radius: 15)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        let dx = value.translation.width
                        let dy = value.translation.height
                        if abs(dx) > abs(dy) {
                            if dx > 0 {
                                // Swipe right
                                appState.executeAction(executorID: executor.id, actionContextOption: .rightAction)
                            } else {
                                // Swipe left
                                appState.executeAction(executorID: executor.id, actionContextOption: .leftAction)
                            }
                        } else {
                            if dy > 0 {
                                // Swipe down
                                appState.executeAction(executorID: executor.id, actionContextOption: .downAction)
                            } else {
                                // Swipe up
                                appState.executeAction(executorID: executor.id, actionContextOption: .upAction)
                            }
                        }
                    }
            )
        }
    }

    var ExecutorBody: some View {
        ZStack {
            switch executor.interactionType {
            case .button:
                buttonView
            case .knob:
                knobView
            case .gesture:
                gestureView
            case .display:
                displayView
            }
        }
        .overlay {
            if appState.editMode {
                ZStack {
                    // Edit button
                    Button(action: {
                        appState.executorCreationModel = executor
                        appState.executorCreationShown = true
                    }) {
                        Color.clear
                    }

                    // Delete button
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "x.circle.fill")
                            .padding()
                    }
                    .position(CGPoint(x: 0, y: 0))
                    .offset(x: 5, y: 5)
                    .foregroundStyle(.primary)
                }
            }
        }
        .rotationEffect(
            withAnimation { appState.getCurrentRotation() }
        )
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1
            }
        }
        .alert("Delete Executor?", isPresented: $showDeleteConfirmation) {
                   Button("Delete", role: .destructive) {
                       appState.deleteExecutor(id: executor.id) // Perform delete action
                   }
                   Button("Cancel", role: .cancel) {
                       showDeleteConfirmation = false // Dismiss the alert
                   }
               } message: {
                   Text("Are you sure you want to delete this executor? This action cannot be undone.")
               }
    }

    var body: some View {
        if appState.editMode {
            ExecutorBody.draggable(executor)
        } else {
            ExecutorBody
        }
    }
}

struct GridBackground: View {
    var lineSpacing: CGFloat = 8
    var lineColor: Color = .white.opacity(0.15)
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                // horizontal lines
                var y = CGFloat(0)
                while y <= geo.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    y += lineSpacing
                }
                // vertical lines
                var x = CGFloat(0)
                while x <= geo.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    x += lineSpacing
                }
            }
            .stroke(lineColor, lineWidth: 1)
        }
    }
}

#Preview {
    ExecutorView(executor: ExecutorModel(label: "Volume", interactionType: .knob, icon: "speaker.wave.2.fill", backgroundColor: "#FAFAFA"))
        .environmentObject(AppState())
}
