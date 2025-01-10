//
//  ActionCreationView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import SwiftUI

struct ActionCreationView: View {
    @EnvironmentObject var appState : AppState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var action = ActionModel(name: "New Action")
    var isEditing : Bool = false
    
    var body: some View {
        Form {
            Section {
                TextField("Action Name", text: $action.name)
            }
            Section(header:Text("Action Type")) {
                TypeSelectionView
            }
            switch action.type {
            case .keybind:
                KeybindingCustomizationView
            case .siriShortcut:
                shortcutCustomizationView
            case .core:
                EmptyView()
                
            }
        }
        Button(action:{
            if(isEditing) {
                appState.modifyAction(action:action)
            }
            else {
                appState.createAction(action: action)
            }
            self.presentationMode.wrappedValue.dismiss()
        }) {
            
            Text(isEditing ? "Update Action" :"Create Action")
                .font(.system(size: 30, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.top)
            .background(ReducedBackgroundView())
            
        }
        .foregroundStyle(.foreground)
    }
    
    
    var TypeSelectionView : some View {
        ScrollView([.horizontal]) {
            HStack {
                ActionTypeButtonView(displayedType: .keybind, selectedType: $action.type)
                ActionTypeButtonView(displayedType: .siriShortcut, selectedType: $action.type)
            }
        }
    }
    
    var KeybindingCustomizationView : some View {
        VStack {
            HStack {
                Grid {
                    GridRow {
                        ModifierButtonView(displayedModifier: .command, selectedModifiers: $action.modifiers)
                        ModifierButtonView(displayedModifier: .shift, selectedModifiers: $action.modifiers)
                    }
                    GridRow {
                        ModifierButtonView(displayedModifier: .control, selectedModifiers: $action.modifiers)
                        ModifierButtonView(displayedModifier: .option, selectedModifiers: $action.modifiers)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1.0, contentMode: .fit)
                VStack {
                    Spacer()
                    Text("Key")
                    Spacer()
                    TextField("", text: $action.key)
                        .aspectRatio(1, contentMode: .fit)
                        .padding()
                        .background(ReducedBackgroundView())
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(maxWidth: 100)
                        .multilineTextAlignment(.center)
                          
                          
                          
                    Spacer()
                }
                .font(.system(size: 20, weight:.bold))
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var shortcutCustomizationView : some View {
        Picker("Shortcut", selection: $action.shortcut) {
            ForEach(appState.shortcuts, id: \.self) { shortcut in
                Text(shortcut).tag(shortcut)
            }
        }
    }
}


struct ModifierButtonView : View {
    var displayedModifier : ModifierButton
    @Binding var selectedModifiers : [ModifierButton : Bool]
    
    func modifierString() -> String {
        switch displayedModifier {
        case .shift:
            return "Shift"
        case .command:
            return "Command"
        case .control:
            return "Control"
        case .option:
            return "Option"
        }
    }
    
    func modifierSystemImage() -> String {
        switch displayedModifier {
        case .shift:
            return "shift"
        case .command:
            return "command"
        case .control:
            return "control"
        case .option:
            return "option"
        }
    }
    
    var body : some View {
        Button(action:{
            withAnimation {
                selectedModifiers[displayedModifier]?.toggle()
                
                if(selectedModifiers[displayedModifier] == nil) {
                    selectedModifiers[displayedModifier] = true
                }
            }
        }) {
            VStack {
                Spacer()
                Image(systemName: modifierSystemImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                Text(modifierString())
                Spacer()
            }
            .font(.headline)
            .frame(maxWidth:.infinity)
            .foregroundStyle(
                (selectedModifiers[displayedModifier] ?? false) ? .primaryAccent : .secondary
            )
            
            
        }
    }
}

struct ActionTypeButtonView : View {
    var displayedType : ActionType
    @Binding var selectedType : ActionType
    
    
    func actionTypeString() -> String {
        switch displayedType {
        case .keybind:
            return "Keybinding"
        case .siriShortcut:
            return "Siri Shortcut"
        case .core:
            return "Null"
        }
    }

    
    var body : some View {
        Button(action:{
            withAnimation {
                selectedType = displayedType
            }
        }) {
            VStack {
                Image(systemName: displayedType.associatedIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text(actionTypeString())
            }
            .padding(5)
        }.foregroundStyle(
            selectedType == displayedType ? .primaryAccent : .secondary
        )
    }
}



#Preview {
    ActionCreationView().environmentObject(AppState())
}
