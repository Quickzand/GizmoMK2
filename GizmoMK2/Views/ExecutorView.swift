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
    @State private var currentAngle: Double = 0.0
    @State private var lastAngle: Double = 0.0
    @State private var isDragging: Bool = false

    // State variables to track the notches
    @State private var lastNotchIndex: Int = 0
    @State private var lastActionNotchIndex: Int = 0 // Variable for action notch index
    
    @State private var isPressed : Bool = false
    
    @State private var showDeleteConfirmation = false
    
    @State private var successCount : Int = 0
    

    var buttonView: some View {
        Button(action: {
            appState.executeAction(executorID: executor.id, actionContextOption: .action)
            
            successCount += 1

            UINotificationFeedbackGenerator().notificationOccurred(.success)
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
                }.foregroundStyle(Color(hex: executor.foregroundColor))
            }
            .simultaneousGesture (
                DragGesture(minimumDistance: 0).onChanged { _ in
                    withAnimation(.spring) {
                        isPressed = true
                    }
                }.onEnded
                {_ in
                    withAnimation(.spring) {
                        isPressed = false
                    }
                }
            )
            .padding(.all, 2)
            .frame(width: itemWidth, height: itemWidth)
            .background(Color(hex: executor.backgroundColor).opacity(executor.backgroundOpacity))
            .cornerRadius(cellCornerRadius)
            .shadow(color:Color(hex:executor.foregroundColor).opacity(0.3), radius: 10)
            .shadow(radius:15)
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .keyframeAnimator(
                initialValue: RingProgress(innerRingProgress: 0, outerRingProgress: 0),
                trigger: successCount
            ) { content, value in
                content
                    .overlay {
                        RadialGradient(
                            gradient: Gradient(stops: [
                                // Stop 1: Clear at 0.0
                                .init(color: .clear, location: 0.0),
                                
                                // Stop 2: Accent color at "innerRingProgress"
                                .init(color: .primaryAccent, location: value.innerRingProgress),
                                
                                // Stop 3: Clear at "outerRingProgress"
                                .init(color: .clear, location: value.outerRingProgress)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: itemWidth
                        )
                        .blur(radius:10)
                        .cornerRadius(cellCornerRadius)
                    }
            } keyframes: {_ in 
                KeyframeTrack(\.innerRingProgress) {
                    // Go from 0 to 1, then back to 0
                    LinearKeyframe(0.0, duration: 0.01)
                    LinearKeyframe(0.0, duration: 0.25)
                    CubicKeyframe(10.0, duration: 2.0)
                }
                
                KeyframeTrack(\.outerRingProgress) {
                    // Go from 0 to 1, then back to 0
                    LinearKeyframe(0.0, duration: 0.01)
                    CubicKeyframe(1.0, duration: 0.5)
                    LinearKeyframe(1.0, duration: 2)
                    LinearKeyframe(0.0, duration: 0.01)
                }
            }
        }
    }
    
    struct RingProgress {
        var innerRingProgress: CGFloat
        var outerRingProgress: CGFloat
    }

    var knobView: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let stepDegrees: Double = 10 // Visual notch degrees
            let actionStepDegrees: Double = 30 // Degrees per action (every third notch)

            ZStack {
                // Knob base with gradient for a 3D effect
                Circle()
                    .fill(
                        Color(hex: executor.backgroundColor)
                        .opacity(executor.backgroundOpacity)
                    )

                // Tick marks around the knob
                ForEach(0..<12) { tick in
                    Rectangle()
                        .fill(.white)
                        .frame(width: 2, height: size / 10)
                        .offset(y: -(size-5) / 2 + (size-5) / 20)
                        .rotationEffect(Angle(degrees: Double(tick) / 12 * 360))
                }
         

                // Icon and Label inside the knob
                VStack {
                    if !executor.iconHidden {
                        Image(systemName: executor.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size / 2, height: size / 2)
                            .foregroundStyle(.foreground)
                    }
                    if !executor.labelHidden {
                        Text(executor.label)
                            .font(.caption)
                            .foregroundStyle(.foreground)
                    }
                }
            }
            .rotationEffect(Angle(degrees: currentAngle))
            .shadow(color:Color(hex:executor.foregroundColor).opacity(0.25), radius: 10)
            .shadow(radius:15)
            .gesture(
                DragGesture(minimumDistance: 0.0)
                    .onChanged { value in
                        let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
                        let angleInRadians = atan2(vector.dy, vector.dx)
                        let angleInDegrees = angleInRadians * 180 / .pi

                        if !isDragging {
                            isDragging = true
                            lastAngle = angleInDegrees
                            lastNotchIndex = Int(round(currentAngle / stepDegrees))
                            lastActionNotchIndex = Int(round(currentAngle / actionStepDegrees))
                        }

                        var delta = angleInDegrees - lastAngle

                        // Handle angle wrapping
                        if delta > 180 {
                            delta -= 360
                        } else if delta < -180 {
                            delta += 360
                        }

                        currentAngle += delta
                        lastAngle = angleInDegrees

                        // Apply visual ratcheting effect
                        currentAngle = round(currentAngle / stepDegrees) * stepDegrees

                        // Calculate the current notch indices
                        let currentNotchIndex = Int(round(currentAngle / stepDegrees))
                        let currentActionNotchIndex = Int(round(currentAngle / actionStepDegrees))

                        // Update visual notch index
                        if currentNotchIndex != lastNotchIndex {
                            lastNotchIndex = currentNotchIndex
                        }

                        // Check if the action notch has changed
                        if currentActionNotchIndex != lastActionNotchIndex {
                            // Generate haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()

                            // Determine rotation direction
                            let direction = currentActionNotchIndex - lastActionNotchIndex
                            if direction > 0 {
                                // Clockwise rotation
                                appState.executeAction(executorID: executor.id, actionContextOption: .action)                            } else if direction < 0 {
                                // Counter-clockwise rotation
                                    appState.executeAction(executorID: executor.id, actionContextOption: .secondaryAction)
                            }

                            // Update the last action notch index
                            lastActionNotchIndex = currentActionNotchIndex
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        // Optionally, perform an action when rotation ends
                    }
            )
        }
        .frame(width: itemWidth, height: itemWidth)
    }
    
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
