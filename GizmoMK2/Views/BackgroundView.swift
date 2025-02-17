//
//  BackgroundView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 10/27/24.
//

import SwiftUI
import simd

struct BackgroundView: View {
    @State var t: Float = 0.0
    @State var timer: Timer?
    
    @EnvironmentObject var appState : AppState

    var body: some View {
        if let currentPage = appState.pages.first(where: {$0.id == appState.currentPageID}) {
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                
                [sinInRange(-0.8...(-0.2), offset: 0.439, timeScale: 0.342, t: t), sinInRange(0.3...0.7, offset: 3.42, timeScale: 0.984, t: t)],
                [sinInRange(0.1...0.8, offset: 0.239, timeScale: 0.084, t: t), sinInRange(0.2...0.8, offset: 5.21, timeScale: 0.242, t: t)],
                [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.084, t: t), sinInRange(0.4...0.8, offset: 0.25, timeScale: 0.642, t: t)],
                [sinInRange(-0.8...0.0, offset: 1.439, timeScale: 0.442, t: t), sinInRange(1.4...1.9, offset: 3.42, timeScale: 0.984, t: t)],
                [sinInRange(0.3...0.6, offset: 0.339, timeScale: 0.784, t: t), sinInRange(1.0...1.2, offset: 1.22, timeScale: 0.772, t: t)],
                [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.056, t: t), sinInRange(1.3...1.7, offset: 0.47, timeScale: 0.342, t: t)]
            ], colors: [
                Color(hex:currentPage.primaryAccentColor), Color(hex:currentPage.secondaryAccentColor), Color(hex:currentPage.tertiaryAccentColor),
                Color(hex:currentPage.secondaryAccentColor), Color(hex:currentPage.tertiaryAccentColor), Color(hex:currentPage.primaryAccentColor),
                Color(hex:currentPage.tertiaryAccentColor), Color(hex:currentPage.primaryAccentColor), Color(hex:currentPage.secondaryAccentColor)
            ])
            .onAppear {
                guard timer == nil else { return }
                t += 500
                timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    t += 0.02
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
            .background(.black)
            .innerShadow(color:  Color(UIColor.secondarySystemBackground), radius: 0.9)
            .ignoresSafeArea()
        }
    }

    func sinInRange(_ range: ClosedRange<Float>, offset: Float, timeScale: Float, t: Float) -> Float {
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin(timeScale * t + offset)
    }
}


#Preview {
    BackgroundView().environmentObject(AppState())
}
