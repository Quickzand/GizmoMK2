//
//  PageCreationSheetView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 1/8/25.
//

import SwiftUI


// MARK: - Background Layer
struct PageCreationBackgroundLayer: View {
    // Animation states
    @State private var gradientOpacity: Double = 0.0
    @State private var gradientBrightness: Double = 0.0
    @State private var flickerAmount: CGFloat = 0.0
    @State private var gradientShift: CGFloat = 0.0
    
    var body: some View {
        // Define a different mesh arrangement
        let points: [SIMD2<Float>] = [
            SIMD2<Float>(0.0, 0.0),
            SIMD2<Float>(0.5, Float(0.0 + flickerAmount)),
            SIMD2<Float>(1.0, 0.0),
            SIMD2<Float>(0.0, 0.5),
            SIMD2<Float>(0.5, Float(0.5 + gradientShift)),
            SIMD2<Float>(1.0, Float(0.5 - flickerAmount)),
            SIMD2<Float>(0.0, 1.0),
            SIMD2<Float>(0.5, Float(1.0 - gradientShift)),
            SIMD2<Float>(1.0, 1.0)
        ]
        
        // Pick some subtle background colors
        let colors: [Color] = [
            .clear,
            .clear,
            .clear,
            .clear,
            Color.secondaryAccent.opacity(0.4),
            .clear,
            Color.primaryAccent.opacity(0.3),
            Color.tertiaryAccent.opacity(0.25),
            Color.secondaryAccent.opacity(0.4)
        ]
        
        MeshGradient(
            width: 3,
            height: 3,
            points: points,
            colors: colors
        )
        .brightness(gradientBrightness)
        .scaleEffect(1.5)
        .opacity(gradientOpacity)
        .blendMode(.plusLighter)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                gradientOpacity = 1.0
            }
            startFlickering()
            startShifting()
        }
    }
    
    // Flickering animation
    private func startFlickering() {
        let randDuration = Double.random(in: 0.15...0.3)
        withAnimation(Animation.linear(duration: randDuration)) {
            flickerAmount = CGFloat.random(in: -0.02...0.02)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + randDuration) {
            self.startFlickering()
        }
    }
    
    // Gradual shifting animation
    private func startShifting() {
        withAnimation(Animation.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            gradientShift = 0.04
        }
    }
}


struct PageCreationSheetView : View {
    @EnvironmentObject var appState : AppState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var page = PageModel(name: "New Page")
    var isEditing : Bool = false
    
    
    var body: some View {
        ZStack {
            ActionPickerBackgroundLayer()
                .ignoresSafeArea()
            VStack {
                ScrollView([.vertical]) {
                    Section {
                        TextField("Page Name", text: $page.name)
                    }
                }
                
                SubmitButton(submissionAnimation: .constant(false)) {
                    if(isEditing) {
                        appState.modifyPage(page:page)
                    }
                    else {
                        appState.createPage(page: page)
                    }
                    appState.editMode = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            
        }
        
    }
}

#Preview {
    PageCreationSheetView()
}
