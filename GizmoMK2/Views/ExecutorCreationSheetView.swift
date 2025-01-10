//
//  ExecutorCreationSheetView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/15/24.
//


import SwiftUI
import PhotosUI
import SwiftUIIntrospect
import SymbolPicker

struct ExecutorCreationSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    @State private var iconPickerPresented = false
    @State private var actionPickerPresented = false
    @State private var secondaryActionPickerPresented = false
    
    @State private var upActionPickerPresented = false
    @State private var downActionPickerPresented = false
    @State private var leftActionPickerPresented = false
    @State private var rightActionPickerPresented = false
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    @State private var submissionAnimation = false
    @State private var gradientOpacity: Double = 0.0
    @State private var gradientScale: CGFloat = 1.0
    @State private var gradientBrightness: Double = 0.0
    @State private var flickerAmount: CGFloat = 0.0
    @State private var gradientShift: CGFloat = 0.0
    
    var body: some View {
        VStack {
            ExecutorTypeSelectorView(submissionAnimation: submissionAnimation)
                .scaleEffect(submissionAnimation ? 2 : 1)
            
            if !submissionAnimation {
                ScrollView {
                    ForegroundSectionView(
                        iconPickerPresented: $iconPickerPresented
                    )
                    .scrollTransition(.animated.threshold(.visible(0.9))) { view, transition in
                        view.opacity(transition.isIdentity ? 1 : 0.1)
                            .scaleEffect(transition.isIdentity ? 1 : 0.1)
                            .blur(radius: transition.isIdentity ? 0 : 10)
                    }
                    BackgroundSectionView(
                        selectedPhoto: $selectedPhoto
                    )
                    .scrollTransition(.animated.threshold(.visible(0.9))) { view, transition in
                        view.opacity(transition.isIdentity ? 1 : 0)
                        .scaleEffect(transition.isIdentity ? 1 : 0)
                    }
                    ActionSectionView(
                        actionPickerPresented: $actionPickerPresented, secondaryActionPickerPresented: $secondaryActionPickerPresented, upActionPickerPresented: $upActionPickerPresented, downActionPickerPresented: $downActionPickerPresented, leftActionPickerPresented: $leftActionPickerPresented, rightActionPickerPresented: $rightActionPickerPresented
                    )
                    .scrollTransition(.animated.threshold(.visible(1))) { view, transition in
                        view.opacity(transition.isIdentity ? 1 : 0)
                        .scaleEffect(transition.isIdentity ? 1 : 0)
                    }
                }
                
                .opacity(submissionAnimation ? 0 : 1)
                .scrollContentBackground(.hidden)
                .padding(.horizontal)
            }
                
            
            SubmitButton(submissionAnimation: $submissionAnimation) {
                submitForm()
            }
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
            withAnimation(.easeInOut(duration: 1)) {
                gradientOpacity = 1.0
                gradientBrightness = 0.0
            }
            startFlickering()
            startShifting()
        }
        .sheet(isPresented: $iconPickerPresented) {
            SymbolPicker(symbol: $appState.executorCreationModel.icon)
        }
        .sheet(isPresented: $actionPickerPresented) {
            ActionPickerView(selectedActionId: $appState.executorCreationModel.actionID)
        }
        .sheet(isPresented: $secondaryActionPickerPresented) {
            ActionPickerView(selectedActionId: $appState.executorCreationModel.secondaryActionID)
        }
        .sheet(isPresented: $upActionPickerPresented) {
            ActionPickerView(selectedActionId: $appState.executorCreationModel.upActionID)
        }
        .sheet(isPresented: $downActionPickerPresented) {
            ActionPickerView(selectedActionId: $appState.executorCreationModel.downActionID)
        }
        .sheet(isPresented: $leftActionPickerPresented) {
            ActionPickerView(selectedActionId: $appState.executorCreationModel.leftActionID)
        }
        .sheet(isPresented: $rightActionPickerPresented) {
            ActionPickerView(selectedActionId: $appState.executorCreationModel.rightActionID)
        }
    }
    
    func submitForm() {
        withAnimation(.easeInOut(duration: 1)) {
            gradientScale = 5.0
            gradientBrightness = 1.5
            submissionAnimation = true
        }
        if appState.editMode {
            appState.modifyExecutor(executor: appState.executorCreationModel)
            appState.editMode = false
        } else {
            appState.createExecutor(
                executor: appState.executorCreationModel,
                pageID: appState.currentPageID
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
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
    
    func startShifting() {
        withAnimation(
            Animation.easeInOut(duration: 5)
                .repeatForever(autoreverses: true)
        ) {
            gradientShift = 0.05
        }
    }
}

struct ExecutorTypeSelectorView: View {
    @EnvironmentObject var appState: AppState
    let submissionAnimation: Bool
    
    var body: some View {
        TabView(selection: $appState.executorCreationModel.interactionType) {
            ExecutorView(executor: appState.executorCreationModel)
                .tag(InteractionType.button)
            ExecutorView(executor: appState.executorCreationModel)
                .tag(InteractionType.knob)
            ExecutorView(executor: appState.executorCreationModel)
                .tag(InteractionType.gesture)
        }
        .frame(maxHeight: 200)
        .tabViewStyle(.page)
        .introspect(.tabView(style: .page), on: .iOS(.v18)) {
            $0.backgroundColor = .clear
        }
    }
}

struct ForegroundSectionView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var selectedForegroundColor: Color = .white
    
    @Binding var iconPickerPresented: Bool
    
    var body: some View {
        Section(header: Text("Foreground")) {
            VStack {
                HStack {
                    Button {
                        withAnimation { appState.executorCreationModel.labelHidden.toggle() }
                    } label: {
                        Image(systemName: appState.executorCreationModel.labelHidden ? "eye.slash.fill" : "eye.fill")
                    }
                    .buttonStyle(.plain)
                    
                    TextField("Label", text: $appState.executorCreationModel.label)
                }
                
                HStack {
                    Text("Icon: ")
                    Button {
                        withAnimation { appState.executorCreationModel.iconHidden.toggle() }
                    } label: {
                        Image(systemName: appState.executorCreationModel.iconHidden ? "eye.slash.fill" : "eye.fill")
                    }
                    Button {
                        iconPickerPresented = true
                    } label: {
                        Image(systemName: appState.executorCreationModel.icon)
                    }
                    Spacer()
                }
                .buttonStyle(.plain)
                
                HStack {
                    Text("Foreground Color:")
                    ColorPicker("", selection: $selectedForegroundColor, supportsOpacity: false)
                        .onChange(of: selectedForegroundColor) { newValue in
                            appState.executorCreationModel.foregroundColor = newValue.toHex() ?? "#000000"
                        }
                        .onAppear {
                            selectedForegroundColor = Color(hex: appState.executorCreationModel.foregroundColor)
                        }
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(10)
        }
    }
}

struct BackgroundSectionView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var selectedBackgroundColor: Color = .black
    @Binding var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        Section(header: Text("Background")) {
            VStack {
                HStack {
                    Text("Background Color:")
                    ColorPicker("", selection: $selectedBackgroundColor, supportsOpacity: false)
                        .onChange(of: selectedBackgroundColor) { newValue in
                            appState.executorCreationModel.backgroundColor = newValue.toHex() ?? "#000000"
                        }
                        .onAppear {
                            selectedBackgroundColor = Color(hex: appState.executorCreationModel.backgroundColor)
                        }
                }
                HStack {
                    PhotosPicker("Background Image", selection: $selectedPhoto)
                }
                HStack {
                    Text("Opacity:")
                    Slider(value: $appState.executorCreationModel.backgroundOpacity, in: 0...1)
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(10)
        }
    }
}

struct ActionSectionView: View {
    @EnvironmentObject var appState: AppState
    @Binding var actionPickerPresented: Bool
    @Binding var secondaryActionPickerPresented: Bool
    @Binding var upActionPickerPresented: Bool
    @Binding var downActionPickerPresented: Bool
    @Binding var leftActionPickerPresented: Bool
    @Binding var rightActionPickerPresented: Bool
    
    
    var body: some View {
        Section(header: Text("Action")) {
            VStack {
                switch appState.executorCreationModel.interactionType {
                    case .button, .knob:
                        Button {
                            actionPickerPresented = true
                        } label: {
                            HStack {
                                Text("Action: ")
                                Spacer()
                                if let action = appState.actions.first(where: { $0.id == appState.executorCreationModel.actionID }) {
                                    Image(systemName: action.type.associatedIcon)
                                    Text(action.name)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                        
                        if appState.executorCreationModel.interactionType == .knob {
                            Button {
                                secondaryActionPickerPresented = true
                            } label: {
                                HStack {
                                    Text("Secondary Action: ")
                                    Spacer()
                                    if let action = appState.actions.first(where: { $0.id == appState.executorCreationModel.secondaryActionID }) {
                                        Image(systemName: action.type.associatedIcon)
                                        Text(action.name)
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                case .gesture:
                    Button {
                        upActionPickerPresented = true
                    } label: {
                        HStack {
                            Text("Up Action: ")
                            Spacer()
                            if let action = appState.actions.first(where: { $0.id == appState.executorCreationModel.upActionID }) {
                                Image(systemName: action.type.associatedIcon)
                                Text(action.name)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                    Button {
                        downActionPickerPresented = true
                    } label: {
                        HStack {
                            Text("Down Action: ")
                            Spacer()
                            if let action = appState.actions.first(where: { $0.id == appState.executorCreationModel.downActionID }) {
                                Image(systemName: action.type.associatedIcon)
                                Text(action.name)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                    Button {
                        leftActionPickerPresented = true
                    } label: {
                        HStack {
                            Text("Left Action: ")
                            Spacer()
                            if let action = appState.actions.first(where: { $0.id == appState.executorCreationModel.leftActionID }) {
                                Image(systemName: action.type.associatedIcon)
                                Text(action.name)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                    Button {
                        rightActionPickerPresented = true
                    } label: {
                        HStack {
                            Text("Right Action: ")
                            Spacer()
                            if let action = appState.actions.first(where: { $0.id == appState.executorCreationModel.rightActionID }) {
                                Image(systemName: action.type.associatedIcon)
                                Text(action.name)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                
                    
                    
                }
               
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(10)
        }
    }
}

struct SubmitButton: View {
    @Binding var submissionAnimation: Bool
    var onSubmit: () -> Void
    
    var body: some View {
        Button {
            onSubmit()
        } label: {
            Text("Submit")
                .padding(.top)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial.opacity(0.5))
                .font(.system(size: 30, weight: .bold))
        }
        .foregroundStyle(.foreground)
    }
}

struct MeshGradientLayer: View {
    var gradientOpacity: Double
    var gradientScale: CGFloat
    var gradientBrightness: Double
    var flickerAmount: CGFloat
    var gradientShift: CGFloat
    
    var body: some View {
        let points: [SIMD2<Float>] = [
            SIMD2<Float>(0.0, 0.0),
            SIMD2<Float>(0.5, 0.0),
            SIMD2<Float>(1.0, 0.0),
            SIMD2<Float>(0.0, 0.5),
            SIMD2<Float>(0.5, Float(0.5 + gradientShift + CGFloat(flickerAmount))),
            SIMD2<Float>(1.0, 0.5),
            SIMD2<Float>(0.0, 1.0),
            SIMD2<Float>(0.5, 1.0),
            SIMD2<Float>(1.0, 1.0)
        ]
        
        let colors: [Color] = [
            .clear,
            .clear,
            .clear,
            .clear,
            Color.secondaryAccent.opacity(0.3),
            .clear,
            Color.tertiaryAccent.opacity(0.2),
            Color.primaryAccent.opacity(0.4),
            Color.tertiaryAccent.opacity(0.2)
        ]
        
        MeshGradient(width: 3, height: 3, points: points, colors: colors)
            .brightness(gradientBrightness)
            .scaleEffect(gradientScale)
            .opacity(gradientOpacity)
            .blendMode(.plusLighter)
            .ignoresSafeArea()
    }
}

#Preview {
    ExecutorCreationSheetView()
        .environmentObject(AppState())
}
