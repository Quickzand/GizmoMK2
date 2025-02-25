//
//  ExecutorButtonView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 2/12/25.
//

import SwiftUI


struct RingProgress {
    var innerRingProgress: CGFloat
    var outerRingProgress: CGFloat
}


extension ExecutorView {
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
                            .frame(maxWidth: itemWidth - 10)
                            .opacity(executor.labelHidden ? 0.0 : 1.0)
                            .scaledToFill()
                               .minimumScaleFactor(0.25)
                               .lineLimit(1)
                               
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
}
