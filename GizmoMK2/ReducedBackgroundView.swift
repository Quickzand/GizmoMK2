//
//  ReducedBackgroundView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import SwiftUI
import simd

struct ReducedBackgroundView: View {
    @State var t: Float = 0.0
    @State var timer: Timer?

    var body: some View {
        MeshGradient(width: 2, height: 2, points: [
            .init(0, 0), .init(1, 0),

            [sinInRange(-0.8...0.0, offset: 1.439, timeScale: 0.442, t: t), sinInRange(1.4...1.9, offset: 3.42, timeScale: 0.984, t: t)],
            [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.056, t: t), sinInRange(1.3...1.7, offset: 0.47, timeScale: 0.342, t: t)]
        ], colors: [
            .primaryAccent, .secondaryAccent,
            .secondaryAccent
        ])
        .onAppear {
            guard timer == nil else { return }
            t += 500
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                t += 0.26
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .background(.black)
        .ignoresSafeArea()
    }

    func sinInRange(_ range: ClosedRange<Float>, offset: Float, timeScale: Float, t: Float) -> Float {
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin(timeScale * t + offset)
    }
}


#Preview {
    ReducedBackgroundView()
}
