//
//  ActionPickerView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 12/27/24.
//

import SwiftUI



struct AbstractedActionTypeDescriptor : Hashable {
    
    var actionType : ActionType
    var siriShortcut : String = ""
    
   
}


// MARK: - Background Layer
struct ActionPickerBackgroundLayer: View {
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

// MARK: - IconView
struct IconView: View {
    let systemName: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(4)
        }
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - FilterButton
struct FilterButton: View {
    let actionCategory: ActionCategory
    let isSelected: Bool
    let label: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: actionCategory.associatedIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text(label)
            }
            .padding()
            .background(
                isSelected
                    ? actionCategory.associatedColor.opacity(0.2)
                    : Color.clear
            )
            .cornerRadius(20)
            .foregroundColor(.primary)
        }
    }
}

// MARK: - ActionRow
struct ActionTypeRow: View {
    let actionTypeDescriptor: AbstractedActionTypeDescriptor
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                IconView(systemName: actionTypeDescriptor.actionType.category.associatedIcon,
                         color: actionTypeDescriptor.actionType.category.associatedColor)
                if actionTypeDescriptor.actionType == .siriShortcut {
                    Text(actionTypeDescriptor.siriShortcut)
                }
                else {
                    Text(actionTypeDescriptor.actionType.rawValue)
                }
                Spacer()
            }
        }
        .buttonStyle(BorderedButtonStyle())
        .foregroundStyle(.primary)
        .padding(.horizontal)
        .shadow(color: isSelected ? actionTypeDescriptor.actionType.category.associatedColor : .clear,
                radius: 3)
    }
}

// MARK: - ActionPickerView
struct ActionTypePickerView: View {
    @EnvironmentObject var appState: AppState
    
    @Binding var action: ActionModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedFilter: ActionCategory? = nil
    
    
    var filteredTypes : [AbstractedActionTypeDescriptor] {
        var descriptiveTypes : [AbstractedActionTypeDescriptor] = []
        let allTypes : [ActionType] = ActionType.allCases.filter {$0 != .siriShortcut}
        for type in allTypes {
            descriptiveTypes.append(.init(actionType: type))
        }
//        Add on extra ones for all siri shortcuts
        for shortcut in appState.shortcuts {
            descriptiveTypes.append(.init(actionType: .siriShortcut, siriShortcut: shortcut))
        }
        let filtered = descriptiveTypes.filter {descriptor in
            let matchesSearch = searchText.isEmpty || descriptor.actionType.rawValue.lowercased().contains(searchText.lowercased()) || descriptor.siriShortcut.lowercased().contains(searchText.lowercased())
            let matchesFilter = selectedFilter == nil
            || descriptor.actionType.category == selectedFilter
            return matchesSearch && matchesFilter
        }
        return filtered.sorted {
            $0.actionType.rawValue < $1.actionType.rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Attach our custom background
                ActionPickerBackgroundLayer()
                    .ignoresSafeArea()
                VStack {
                    // MARK: Search bar
                    TextField("Search actions...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    // MARK: Filter buttons
                    ScrollView(.horizontal) {
                        HStack {
                        FilterButton(
                            actionCategory: .system,
                            isSelected: selectedFilter == .system,
                            label: "System"
                        ) {
                            withAnimation {
                                // Toggle the selected filter
                                selectedFilter = (selectedFilter == .system) ? nil : .system
                            }
                        }
                        
                        FilterButton(
                            actionCategory: .core,
                            isSelected: selectedFilter == .core,
                            label: "Core"
                        ) {
                            withAnimation {
                                selectedFilter = (selectedFilter == .core) ? nil : .core
                            }
                        }
                        
                        FilterButton(
                            actionCategory: .siriShortcut,
                            isSelected: selectedFilter == .siriShortcut,
                            label: "Siri Shortcuts"
                        ) {
                            withAnimation {
                                selectedFilter = (selectedFilter == .siriShortcut) ? nil : .siriShortcut
                            }
                        }
                    }
                      
                        
                    }
                    
                    // MARK: Filtered list
                    ScrollView {
                        ForEach(filteredTypes, id: \.self) { actionTypeDescriptor in
                            ActionTypeRow(
                                actionTypeDescriptor: actionTypeDescriptor,
                                isSelected: actionTypeDescriptor.actionType == .siriShortcut ? actionTypeDescriptor.siriShortcut == action.shortcut : action.type == actionTypeDescriptor.actionType
                                ,
                                onTap: {
                                    if actionTypeDescriptor.actionType == .siriShortcut {
                                        action.shortcut = actionTypeDescriptor.siriShortcut
                                    }
                                    action.type = actionTypeDescriptor.actionType
                                    dismiss()
                                }
                            
                            )
                            .scrollTransition(.animated.threshold(.visible(0.9))) { view, transition in
                                view.opacity(transition.isIdentity ? 1 : 0.3)
                                    .scaleEffect(transition.isIdentity ? 1 : 0.3)
                                    .blur(radius: transition.isIdentity ? 0 : 10)
                            }
                        }
                    }
                }
                .navigationTitle("Select Action")
                .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let appState = AppState()
    ActionTypePickerView(action: .constant(ActionModel()) )
        .environmentObject(appState)
        .onAppear {
            appState.actions.append(ActionModel(name: "TEST"))
        }
}
