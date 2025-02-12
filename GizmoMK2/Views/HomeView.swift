//
//  HomeView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 12/27/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState : AppState
    
    
    // Use a local state to track which page is selected in the TabView.
    // This prevents direct binding to appState.currentPageID mid-swipe.
    @State private var localPageID: String = ""
    
    // Animation & editing
    @State private var animatePageName = false
    @State private var editPageNameText = ""
    
    // Layout constants
    private let buttonSize = 20.0
    private let buttonPadding = 10.0
    
    
    
    var body: some View {
        ZStack {
            VStack {
                let validPages = getValidPages()
                
                // MARK: - TabView
                TabView(selection: $localPageID) {
                    ForEach(validPages, id: \.id) { page in
                        PageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page)
                // Whenever localPageID changes (user finishes swiping),
                // sync it back to appState.currentPageID.
                .onChange(of: localPageID) { newValue in
                    if newValue != appState.currentPageID {
                        withAnimation(.easeInOut(duration: 0.3)) { // Add animation here
                              appState.currentPageID = newValue
                          }
                    }
                }
                // Also, whenever appState.currentPageID changes (via code),
                // update localPageID so TabView stays in sync.
                .onChange(of: appState.currentPageID) { newValue in
                    if newValue != localPageID {
                        localPageID = newValue
                    }
                }
                
                
                // Page title (hidden in landscape)
                if appState.deviceOrientation != .landscapeLeft &&
                    appState.deviceOrientation != .landscapeRight {
                    pageTitle
                }
            }
            
            // Floating Buttons (plus, edit, gear)
            navigationButtons
            
            // Floating page customization button
            if let currentPage = appState.pages.first(where: { $0.id == appState.currentPageID }) {
                if appState.editMode {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Button {
                                appState.pageCreationModel = currentPage
                                appState.pageCreationShown = true
                            } label: {
                                Image(systemName: "paintbrush.fill")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .padding(buttonPadding)
                            }
                            .circularButtonStyle(appState.getCurrentRotation())
                            .padding()
                        }
                    }
                }
            }
            
            if appState.deviceOrientation == .landscapeLeft ||
                appState.deviceOrientation == .landscapeRight {
                            pageTitle
                                .fixedSize()
                                .background(.blue)
                                .position(x: 10, y: UIScreen.main.bounds.height - 50)
                                .rotationEffect(appState.getCurrentRotation())
                                
                                
                    
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Group {
                if let currentPage = appState.pages.first(where: { $0.id == appState.currentPageID }) {
                    switch currentPage.backgroundType {
                    case .color:
                        Color(hex: currentPage.backgroundColor)
                    case .mesh:
                        BackgroundView()
                    default:
                        EmptyView()
                        
                    }
                } else {
                    EmptyView()
                }
            }
                .ignoresSafeArea()
        )
        .onAppear {
            // Initialize localPageID so it shows the right tab from the start
            localPageID = appState.currentPageID
        }
        // If the focusedApp changes, re-validate which pages should be visible
        .onChange(of: appState.focusedApp) { _ in
            let validPages = getValidPages()
            validateCurrentPageID(validPages: validPages)
            // Make sure localPageID also stays valid
            localPageID = appState.currentPageID
        }
    }
}

// MARK: - Subviews
extension HomeView {
    private var navigationButtons: some View {
        HStack {
            VStack(alignment: .leading) {
                // “+” Button: show Executor creation sheet
                Menu {
                    Button("New Executor") {
                        appState.executorCreationModel = ExecutorModel(label: "Default Label")
                        appState.executorCreationShown = true
                    }
                    
                    
                    Button("New Page") {
                        appState.pageCreationModel = PageModel()
                        appState.pageCreationShown = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: buttonSize, height: buttonSize)
                        .padding(buttonPadding)
                }
                .circularButtonStyle(appState.getCurrentRotation())
                
                // Pencil / Checkmark: toggles Edit mode
                Button {
                    withAnimation {
                        appState.editMode.toggle()
                    }
                } label: {
                    Image(systemName: appState.editMode ? "checkmark" : "pencil")
                        .resizable()
                        .frame(width: buttonSize, height: buttonSize)
                        .padding(buttonPadding)
                }
                .circularButtonStyle(appState.getCurrentRotation())
                
                // Gear: show Settings view
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .resizable()
                        .frame(width: buttonSize, height: buttonSize)
                        .padding(buttonPadding)
                }
                .circularButtonStyle(appState.getCurrentRotation())
            }
            .padding(.leading, 5)
            
            Spacer()
        }
        .sheet(isPresented: $appState.executorCreationShown) {
            ExecutorCreationSheetView()
        }
        .sheet(isPresented: $appState.pageCreationShown) {
            PageCreationSheetView()
        }
        .onChange(of: appState.currentlyDisplayedPageID) {
            if appState.currentlyDisplayedPageID == "" {
                return
            }
            withAnimation {
                appState.currentPageID = appState.currentlyDisplayedPageID
                localPageID = appState.currentPageID
                appState.currentlyDisplayedPageID = ""
            }
        }
    }
    
    @ViewBuilder
    private var pageTitle: some View {
        if appState.editMode {
            TextField("", text: $editPageNameText)
                .textFieldStyle(.plain)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .edgesIgnoringSafeArea(.vertical)
                .onAppear {
                    editPageNameText = currentPageName
                }
                .onChange(of: appState.currentPageID) { _ in
                    editPageNameText = currentPageName
                }
                .frame(maxWidth: .infinity, minHeight: 20, maxHeight: 20)
            
        } else {
            Text(currentPageName)
                .font(.headline)
                .foregroundColor(.primary)
                .scaleEffect(animatePageName ? 1.1 : 1)
                .animation(.bouncy(duration: 0.3), value: animatePageName)
                .onChange(of: appState.currentPageID) { _ in
                    animatePageName = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        animatePageName = false
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 20, maxHeight: 20)
                .opacity(appState.pages.first(where: { $0.id == appState.currentPageID })?.nameVisible == true ? 1 : 0)
        }
    }
}

// MARK: - Helpers
extension HomeView {
    private var currentPageName: String {
        appState.pages.first(where: { $0.id == appState.currentPageID })?.name
        ?? "No Page Selected"
    }
    
    private func getValidPages() -> [PageModel] {
        return appState.pages.filter { page in
            // If the focused app doesn’t limit pages, all pages are valid
            if appState.focusedApp.associatedPageIDs.isEmpty || appState.currentlyDisplayedPageID != "" {
                return true
            }
            
            // Otherwise, is this page included in the app’s associated pages?
            return appState.focusedApp.associatedPageIDs[page.id] ?? false
        }
        
        
    }
    
    private func validateCurrentPageID(validPages: [PageModel]) {
        // If the currentPageID isn’t in validPages, fall back to the first
        if !validPages.contains(where: { $0.id == appState.currentPageID }) {
            appState.currentPageID = validPages.first?.id ?? ""
        }
    }
}

// MARK: - Button Style
extension View {
    func circularButtonStyle(_ rotation: Angle) -> some View {
        self
            .background(.ultraThinMaterial)
            .foregroundStyle(.primary)
            .cornerRadius(500)
            .rotationEffect(rotation)
    }
}

// MARK: - LazyView
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    var body: some View {
        build()
    }
}

// MARK: - Preview
#Preview {
    HomeView().environmentObject(AppState())
}








