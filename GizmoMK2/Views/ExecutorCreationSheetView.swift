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
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    @State private var submissionAnimation = false
    @State private var gradientOpacity: Double = 0.0
    @State private var gradientScale: CGFloat = 1.0
    @State private var gradientBrightness: Double = 0.0
    @State private var flickerAmount: CGFloat = 0.0
    @State private var gradientShift: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            VStack {
                ExecutorTypeSelectorView(submissionAnimation: submissionAnimation)
                    .scaleEffect(submissionAnimation ? 2 : 1)
                
                if !submissionAnimation {
                    ScrollView {
                        VisualsSelectionView(
                            iconPickerPresented: $iconPickerPresented
                        )
                        
                        
                        ActionSectionView()
                        
                        Spacer().frame(height: 100)
                    }
                    .shadow(radius:15)
                    .opacity(submissionAnimation ? 0 : 1)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal)
                }
           
                
            }
            VStack {
                Spacer()
                SubmitButton(submissionAnimation: $submissionAnimation, isEditing: appState.editMode) {
                    submitForm()
                }
                .opacity(submissionAnimation ? 0 : 1)
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
            ExecutorView(executor: appState.executorCreationModel)
                .tag(InteractionType.display)
        }
        .frame(maxHeight: 200)
        .tabViewStyle(.page)
        .introspect(.tabView(style: .page), on: .iOS(.v18)) {
            $0.backgroundColor = .clear
        }
    }
}

struct VisualsSelectionView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var selectedForegroundColor: Color = .white
    
    @Binding var iconPickerPresented: Bool
    
    @State private var selectedBackgroundColor: Color = .black
    
    var body: some View {
        Section(header: Text("Visuals").creationRowViewStyle().cornerRadius(15).padding(.top)) {
            VStack(spacing: 0) {
                HStack {
                    Text("Label: ")
                    Spacer()
                    TextField("Label", text: $appState.executorCreationModel.label)
                        .creationRowViewStyle()
                        .frame(width: 150)
                        .cornerRadius(15)
                    Button {
                        withAnimation { appState.executorCreationModel.labelHidden.toggle() }
                    } label: {
                        Image(systemName: appState.executorCreationModel.labelHidden ? "eye.slash.fill" : "eye.fill")
                            .aspectRatio(contentMode: .fill)
                    }
                    .buttonStyle(.plain)
                }
                .creationRowViewStyle()
                .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 15))
                
                HStack {
                    Text("Icon: ")
                    Spacer()
                    Button {
                        iconPickerPresented = true
                    } label: {
                        Image(systemName: appState.executorCreationModel.icon)
                    }.creationRowViewStyle().cornerRadius(15)
                    Button {
                        withAnimation { appState.executorCreationModel.iconHidden.toggle() }
                    } label: {
                        Image(systemName: appState.executorCreationModel.iconHidden ? "eye.slash.fill" : "eye.fill")
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .creationRowViewStyle()
                .buttonStyle(.plain)
                
                HStack {
                    Text("Foreground Color:")
                    Spacer()
                    ColorPicker("", selection: $selectedForegroundColor, supportsOpacity: false)
                        .onChange(of: selectedForegroundColor) { newValue in
                            appState.executorCreationModel.foregroundColor = newValue.toHex() ?? "#000000"
                        }
                        .onAppear {
                            selectedForegroundColor = Color(hex: appState.executorCreationModel.foregroundColor)
                        }
                }
                .scrollTransition(
                    topLeading: .animated.threshold(.visible(1.0)),
                    bottomTrailing: .identity,
                    axis: .vertical
                ) { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.1)
                        .scaleEffect(phase.isIdentity ? 1 : 0.1)
                        .blur(radius: phase.isIdentity ? 0 : 10)
                }
                .creationRowViewStyle()
                
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
                .creationRowViewStyle()
                .clipShape(CustomCorners(corners: [.bottomLeft, .bottomRight], radius: 15))
            }
        }
    }
}

struct BackgroundSectionView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var selectedBackgroundColor: Color = .black
    @Binding var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        Section(header: Text("Background").creationRowViewStyle().padding(.top)) {
            VStack {
                HStack {
                    Text("Background Color:")
                        .creationRowViewStyle()
                    ColorPicker("", selection: $selectedBackgroundColor, supportsOpacity: false)
                        .onChange(of: selectedBackgroundColor) { newValue in
                            appState.executorCreationModel.backgroundColor = newValue.toHex() ?? "#000000"
                        }
                        .onAppear {
                            selectedBackgroundColor = Color(hex: appState.executorCreationModel.backgroundColor)
                        }
                }
                HStack {
                    //                    PhotosPicker("Background Image", selection: $selectedPhoto)
                    //                        .onChange(of: selectedPhoto) { newValue in
                    //                            Task {
                    //                                if let selectedPhoto = selectedPhoto { // Safely unwrap the optional
                    //                                    if let image = try? await selectedPhoto.loadTransferable(type: Data.self) {
                    //                                        appState.executorCreationModel.backgroundImageData = image
                    //                                    }
                    //                                }
                    //                            }
                    //                        }
                    //                        .creationRowViewStyle()
                    
                    if let image = UIImage(data:appState.executorCreationModel.backgroundImageData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    }
                    
                }
                HStack {
                    Text("Opacity:")
                        .frame(height: 30)
                        .creationRowViewStyle()
                    
                    Slider(value: $appState.executorCreationModel.backgroundOpacity, in: 0...1)
                        .creationRowViewStyle()
                }
            }
        }
    }
}

struct ActionSectionView: View {
    @EnvironmentObject var appState: AppState
    
    
    struct ActionPickerView : View {
        var label : String
        @Binding var associatedAction : ActionModel
        @State var associatedActionPickerPresented: Bool = false
        
        
        @EnvironmentObject var appState : AppState
        
        
        var NumericActionValueCustomizationView: some View  {
            HStack {
                Text("\(associatedAction.type.valueLabel):")
                Slider(value: $associatedAction.numericValue, in: associatedAction.type.numericInputStartingValue...associatedAction.type.numericInputEndingValue, step: associatedAction.type.numericInputStepSize)
                Text("\(associatedAction.numericValue, specifier: "%.1f")")
            }
        }
        
        
        var PageActionValueCustomizationView : some View {
            HStack {
                Text("Page:")
                Spacer()
                Picker("Page", selection: $associatedAction.destinationPageId) {
                    ForEach(appState.pages.indices, id: \.self) { index in
                        Text(appState.pages[index].name)
                            .tag(appState.pages[index].id)
                    }
                }
            }
        }
        
        var KeybindActionValueCustomizationView : some View {
            HStack {
                ForEach(ModifierButton.allCases) {modifier in
                    Button(action: {
                        withAnimation {
                            associatedAction.modifiers[modifier]?.toggle()
                            
                            if(associatedAction.modifiers[modifier] == nil) {
                                associatedAction.modifiers[modifier] = true
                            }
                        }
                    }) {
                        Image(systemName: modifier.icon)
                            .resizable()
                            .bold(true)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .creationRowViewStyle()
                            .foregroundStyle(associatedAction.modifiers[modifier] == true ? Color.primaryAccent : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    }
                }
                Spacer()
                TextField("", text: $associatedAction.key)
                    .frame(width: 10)
                    .creationRowViewStyle()
                    .multilineTextAlignment(.center)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
            }
        }
        
        
        var body : some View {
            Section(header: Text(label).creationRowViewStyle().cornerRadius(15)) {
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            associatedActionPickerPresented = true
                        } label: {
                            HStack {
                                Text("Action Type: ")
                                Spacer()
                                HStack {
                                    Image(systemName: associatedAction.type.category.associatedIcon)
                                    Text(associatedAction.type == .siriShortcut ? associatedAction.shortcut :  associatedAction.type.rawValue)
                                }
                                .creationRowViewStyle()
                            }
                        }
                    }
                    .creationRowViewStyle()
                    .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 15))
                    .clipShape(CustomCorners(corners: [.bottomLeft, .bottomRight], radius: associatedAction.type == .none ? 15 : 0))
                    Group {
                        if associatedAction.type.inputType == .Numeric {
                            NumericActionValueCustomizationView
                        }
                        if associatedAction.type.inputType == .Keybind {
                            KeybindActionValueCustomizationView
                        }
                        if associatedAction.type.inputType == .Page {
                            PageActionValueCustomizationView
                        }
                    }
                    .creationRowViewStyle()
                    .clipShape(CustomCorners(corners: [.bottomLeft, .bottomRight], radius: 15))
                    
                    
                } .foregroundStyle (.primary)
                
            }
            .sheet(isPresented: $associatedActionPickerPresented) {
                ActionTypePickerView(action: $associatedAction)
            }
        }
    }
    
    var body: some View {
        VStack {
            switch appState.executorCreationModel.interactionType {
            case .button, .knob:
                ActionPickerView(label: "Action", associatedAction: $appState.executorCreationModel.action)
                
                if appState.executorCreationModel.interactionType == .knob {
                    ActionPickerView(label:"Secondary Action", associatedAction: $appState.executorCreationModel.secondaryAction)
                }
            case .gesture:
                ActionPickerView(label:"Up Action", associatedAction: $appState.executorCreationModel.upAction)
                ActionPickerView(label:"Down Action", associatedAction: $appState.executorCreationModel.downAction)
                ActionPickerView(label:"Left Action", associatedAction: $appState.executorCreationModel.leftAction)
                ActionPickerView(label:"Right Action", associatedAction: $appState.executorCreationModel.rightAction)
            case .display:
                Text("TEST")
            }
        }
    }
}

struct SubmitButton: View {
    @Binding var submissionAnimation: Bool
    var isEditing : Bool = false
    var onSubmit: () -> Void
    
    var body: some View {
        Button {
            onSubmit()
        } label: {
            Text(isEditing ? "Update" : "Create")
                .padding(.top)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial.opacity(1))
                .font(.system(size: 30, weight: .bold))
                .shadow(radius:10)
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


// MARK: - Executor Creation Row View Style
extension View {
    func creationRowViewStyle() -> some View {
        self
            .padding()
            .background(.thinMaterial)
            .scrollTransition(
                topLeading: .animated.threshold(.visible(1.0)),
                bottomTrailing: .identity,
                axis: .vertical
            ) { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.1)
                    .scaleEffect(phase.isIdentity ? 1 : 0.1)
                    .blur(radius: phase.isIdentity ? 0 : 10)
            }
    }
}

#Preview {
    ExecutorCreationSheetView()
        .environmentObject(AppState())
}
