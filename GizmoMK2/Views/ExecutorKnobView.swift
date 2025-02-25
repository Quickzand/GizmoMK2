//
//  ExecutorKnobView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 2/12/25.
//

import SwiftUI

extension ExecutorView {
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
                            .frame(maxWidth: itemWidth - 10)
                            .opacity(executor.labelHidden ? 0.0 : 1.0)
                            .scaledToFill()
                               .minimumScaleFactor(0.25)
                               .lineLimit(1)
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
}
