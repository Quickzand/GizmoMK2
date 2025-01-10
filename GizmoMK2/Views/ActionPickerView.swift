//
//  ActionPickerView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 12/27/24.
//

import SwiftUI

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
    let actionType: ActionType
    let isSelected: Bool
    let label: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: actionType.associatedIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text(label)
            }
            .padding()
            .background(
                isSelected
                    ? actionType.associatedColor.opacity(0.2)
                    : Color.clear
            )
            .cornerRadius(20)
            .foregroundColor(.primary)
        }
    }
}

// MARK: - ActionRow
struct ActionRow: View {
    let action: ActionModel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                IconView(systemName: action.type.associatedIcon,
                         color: action.type.associatedColor)
                Text(action.name)
                Spacer()
            }
        }
        .buttonStyle(BorderedButtonStyle())
        .foregroundStyle(.primary)
        .padding(.horizontal)
        .shadow(color: isSelected ? action.type.associatedColor : .clear,
                radius: 3)
    }
}

// MARK: - ActionPickerView
struct ActionPickerView: View {
    @EnvironmentObject var appState: AppState
    
    @Binding var selectedActionId: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedFilter: ActionType? = nil
    
    var filteredActions: [ActionModel] {
        var filtered = appState.actions.filter { action in
            let matchesSearch = searchText.isEmpty
                || action.name.lowercased().contains(searchText.lowercased())
            let matchesFilter = selectedFilter == nil
                || action.type == selectedFilter
            return matchesSearch && matchesFilter
        }
        
        return filtered.sorted { $0.name < $1.name }
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
                    ScrollView(.horizontal) { HStack {
                        FilterButton(
                            actionType: .keybind,
                            isSelected: selectedFilter == .keybind,
                            label: "Keybinds"
                        ) {
                            // Toggle the selected filter
                            selectedFilter = (selectedFilter == .keybind) ? nil : .keybind
                        }
                        
                        FilterButton(
                            actionType: .core,
                            isSelected: selectedFilter == .core,
                            label: "Core"
                        ) {
                            selectedFilter = (selectedFilter == .core) ? nil : .core
                        }
                        
                        FilterButton(
                            actionType: .siriShortcut,
                            isSelected: selectedFilter == .siriShortcut,
                            label: "Siri Shortcuts"
                        ) {
                            selectedFilter = (selectedFilter == .siriShortcut) ? nil : .siriShortcut
                        }
                    }
                      
                        
                    }
                    
                    // MARK: Filtered list
                    ScrollView {
                        ForEach(filteredActions) { action in
                            ActionRow(
                                action: action,
                                isSelected: selectedActionId == action.id,
                                onTap: {
                                    selectedActionId = action.id
                                    dismiss()
                                }
                            )
                            .scrollTransition(.animated.threshold(.visible(0.9))) { view, transition in
                                view.opacity(transition.isIdentity ? 1 : 0.3)
                                    .scaleEffect(transition.isIdentity ? 1 : 0.3)
                                    .blur(radius: transition.isIdentity ? 0 : 10)
                            }
                        }
                        .onDelete {indexSet in
                            print("TEST")
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
                        ToolbarItem(placement: .primaryAction) {
                            NavigationLink(destination: ActionCreationView()) {
                                Image(systemName: "square.and.pencil")
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
    ActionPickerView(selectedActionId: .constant(""))
        .environmentObject(appState)
        .onAppear {
            appState.actions.append(ActionModel(name: "TEST"))
        }
}
