//
//  ExecutorCreationView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import SwiftUI
import SwiftUIIntrospect
import SymbolPicker

struct ExecutorCreationView: View {
    @State var executor: ExecutorModel = ExecutorModel(label:"Default Label")
    var isEditing : Bool = false
    
    @State private var selectedBackgroundColor : Color = .black
    
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var iconPickerPresented = false
    
    @EnvironmentObject var appState: AppState
    
    // State variables for animations
    @State private var gradientOpacity: Double = 0.0
    @State private var gradientScale: CGFloat = 1.0
    @State private var gradientBrightness: Double = 0.0
    @State private var flickerAmount: CGFloat = 0.0
    @State private var gradientShift: CGFloat = 0.0
    
    @State private var submissionAnimation : Bool = false
    
    var ExecutorTypeSelector : some View {
        TabView {
            ExecutorView(executor: executor)
            Text("Knob")
        }
        .tabViewStyle(.page)
        .introspect(.tabView(style: .page), on: .iOS(.v18)) {
            $0.backgroundColor = .clear
        }
    }
    
    var body: some View {
        VStack {
            ExecutorTypeSelector
                .scaleEffect(submissionAnimation ? 2 : 1)
            if !submissionAnimation
            {
            Form {
                HStack {
                    Button(action:{
                        withAnimation {
                            executor.labelHidden.toggle()
                        }
                    }) {
                        Image(systemName: executor.labelHidden ?  "eye.slash.fill" : "eye.fill")
                    }
                    .buttonStyle(.plain)
                    TextField("Label", text: $executor.label)
                        .introspect(.textField, on: .iOS(.v18)) {
                            $0.backgroundColor = .clear
                        }
                }
                HStack {
                    Text("Icon: ")
                    Button(action:{
                        withAnimation {
                            executor.iconHidden.toggle()
                        }
                    }) {
                        Image(systemName: executor.iconHidden ?  "eye.slash.fill" : "eye.fill")
                    }
                    
                    Button(action: {
                        iconPickerPresented = true
                    }) {
                        Image(systemName: executor.icon)
                    }
                }
                .buttonStyle(.plain)
                
                Section(header: Text("Background")) {
                    HStack {
                        Text("Background Color:")
                        ColorPicker("", selection: $selectedBackgroundColor, supportsOpacity: false)
                            .onChange(of:selectedBackgroundColor) {
                                executor.backgroundColor = selectedBackgroundColor.toHex() ?? "#000000"
                                
                            }
                            .onAppear {
                                selectedBackgroundColor = Color(hex:executor.backgroundColor)
                            }
                    }
                    HStack {
                        Text("Opacity:")
                        Slider(value: $executor.backgroundOpacity, in: 0...1)
                    }
                }
                
                
                Picker("Action", selection: $executor.actionID) {
                    ForEach(appState.actions) {action in
                        Text(action.name)
                            .tag(action.id)
                    }
                }
            }
            .pickerStyle(.navigationLink)
            .listRowBackground(Color.red)
            .scrollContentBackground(.hidden)
        }
            Button(action: {
                // Simulate form submission
                submitForm()
            }) {
                Text(isEditing ? "Update" : "Create")
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial.opacity(0.5))
                    .font(.system(size: 30, weight: .bold))
            }.foregroundStyle(.foreground)
            
        }
        .background(
            MeshGradientLayer(
                gradientOpacity: gradientOpacity,
                gradientScale: gradientScale,
                gradientBrightness: gradientBrightness,
                flickerAmount: flickerAmount,
                gradientShift: gradientShift
            )
        )
        .onAppear {
            // Fade in the gradient
            withAnimation(.easeInOut(duration: 2)) {
                gradientOpacity = 1.0
                gradientBrightness = 0.0 // Start from dark
            }
            // Start flickering and shifting animations
            startFlickering()
            startShifting()
        }
        .sheet(isPresented: $iconPickerPresented) {
            SymbolPicker(symbol: $executor.icon)
        }
    }
    
    // Function to simulate form submission
    func submitForm() {
        withAnimation(.easeInOut(duration: 1)) {
            // Increase scale and brightness of the gradient
            gradientScale = 5.0
            gradientBrightness = 1.5 // Increase brightness
        }
        
        withAnimation(.easeInOut(duration: 1)) {
            submissionAnimation = true
        }
        
        if isEditing {
            appState.modifyExecutor(executor: executor)
        } else {
            appState.createExecutor(executor: executor, pageID: appState.currentPageID)
        }
//        Wait 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    // Function to start the flickering effect
    func startFlickering() {
        let randomDuration = Double.random(in: 0.1...0.3)
        let baseAnimation = Animation.linear(duration: randomDuration)
        withAnimation(baseAnimation) {
            flickerAmount = CGFloat.random(in: -0.01...0.01)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDuration) {
            self.startFlickering()
        }
    }
    
    // Function to start the shifting animation
    func startShifting() {
        withAnimation(
            Animation.easeInOut(duration: 5)
                .repeatForever(autoreverses: true)
        ) {
            gradientShift = 0.05
        }
    }
}

struct MeshGradientLayer: View {
    var gradientOpacity: Double
    var gradientScale: CGFloat
    var gradientBrightness: Double
    var flickerAmount: CGFloat
    var gradientShift: CGFloat
    
    var body: some View {
        // Define the points array
        let points: [SIMD2<Float>] = [
            SIMD2<Float>(0.0, 0.0),
            SIMD2<Float>(0.5, 0.0),
            SIMD2<Float>(1.0, 0.0),
            SIMD2<Float>(0.0, 0.5),
            SIMD2<Float>(0.5, Float(0.5 + gradientShift + flickerAmount)),
            SIMD2<Float>(1.0, 0.5),
            SIMD2<Float>(0.0, 1.0),
            SIMD2<Float>(0.5, 1.0),
            SIMD2<Float>(1.0, 1.0)
        ]
        
        // Define the colors array
        let colors: [Color] = [
            Color.clear,
            Color.clear,
            Color.clear,
            Color.clear,
            Color.secondaryAccent.opacity(0.3),
            Color.clear,
            Color.tertiaryAccent.opacity(0.2),
            Color.primaryAccent.opacity(0.4),
            Color.tertiaryAccent.opacity(0.2)
        ]
        
        MeshGradient(
            width: 3,
            height: 3,
            points: points,
            colors: colors
        )
        .brightness(gradientBrightness)
        .scaleEffect(gradientScale)
        .opacity(gradientOpacity)
        .blendMode(.plusLighter)
        .ignoresSafeArea()
    }
}

#Preview {
    ExecutorCreationView().environmentObject(AppState())
}
