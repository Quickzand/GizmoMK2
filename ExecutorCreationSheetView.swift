//
//  ExecutorCreationSheetView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/15/24.
//


import SwiftUI
import SwiftUIIntrospect
import SymbolPicker

struct ExecutorCreationSheetView: View {
    
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
            ExecutorView(executor: appState.executorCreationModel)
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
                            appState.executorCreationModel.labelHidden.toggle()
                        }
                    }) {
                        Image(systemName: appState.executorCreationModel.labelHidden ?  "eye.slash.fill" : "eye.fill")
                    }
                    .buttonStyle(.plain)
                    TextField("Label", text: $appState.executorCreationModel.label)
                        .introspect(.textField, on: .iOS(.v18)) {
                            $0.backgroundColor = .clear
                        }
                }
                HStack {
                    Text("Icon: ")
                    Button(action:{
                        withAnimation {
                            appState.executorCreationModel.iconHidden.toggle()
                        }
                    }) {
                        Image(systemName: appState.executorCreationModel.iconHidden ?  "eye.slash.fill" : "eye.fill")
                    }
                    
                    Button(action: {
                        iconPickerPresented = true
                    }) {
                        Image(systemName: appState.executorCreationModel.icon)
                    }
                }
                .buttonStyle(.plain)
                
                Section(header: Text("Background")) {
                    HStack {
                        Text("Background Color:")
                        ColorPicker("", selection: $selectedBackgroundColor, supportsOpacity: false)
                            .onChange(of:selectedBackgroundColor) {
                                appState.executorCreationModel.backgroundColor = selectedBackgroundColor.toHex() ?? "#000000"
                                
                            }
                            .onAppear {
                                selectedBackgroundColor = Color(hex:appState.executorCreationModel.backgroundColor)
                            }
                    }
                    HStack {
                        Text("Opacity:")
                        Slider(value: $appState.executorCreationModel.backgroundOpacity, in: 0...1)
                    }
                }
                
                
                Picker("Action", selection: $appState.executorCreationModel.actionID) {
                    ForEach(appState.actions) {action in
                        Text(action.name)
                            .tag(action.id)
                    }
                }
            }
            .opacity(submissionAnimation ? 0.0 : 1.0)
            .pickerStyle(.navigationLink)
            .listRowBackground(Color.red)
            .scrollContentBackground(.hidden)
        }
            Button(action: {
                // Simulate form submission
                submitForm()
            }) {
                Text(appState.editMode ? "Update" : "Create")
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
            SymbolPicker(symbol: $appState.executorCreationModel.icon)
        }
    }
    
    // Function to simulate form submission
    func submitForm() {
        withAnimation(.easeInOut(duration: 1)) {
            // Increase scale and brightness of the gradient
            gradientScale = 5.0
            gradientBrightness = 1.5 // Increase brightness
            submissionAnimation = true
        }
        
        if appState.editMode {
            appState.modifyExecutor(executor: appState.executorCreationModel)
        } else {
            appState.createExecutor(executor: appState.executorCreationModel, pageID: appState.currentPageID)
        }
//        Wait 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
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


#Preview {
//    ExecutorCreationSheetView().environmentObject(AppState())
}
