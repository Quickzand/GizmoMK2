//
//  PageView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import SwiftUI

struct PageView: View {
    @EnvironmentObject var appState: AppState
    
    var page : PageModel
    
    // Layout customization variables
    private let columnSpacing: CGFloat = 10
    private let rowSpacing: CGFloat = 10
    private let gridPadding: CGFloat = 50
    private let cellCornerRadius: CGFloat = 8
    private let emptyCellBackgroundOpacity: Double = 0.1
    
    // Grid configuration
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: columnSpacing), count: 3)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let itemWidth = calculateItemWidth(for: geometry.size.width)
            let pageIndex = appState.pages.firstIndex(where: { $0.id == page.id }) ?? 0
            
            LazyVGrid(columns: columns, spacing: rowSpacing) {
                let executors = PageModel.adjustExecutors(page: page).executors
                ForEach(Array(executors.enumerated()), id: \.offset) { index, executor in
                    Group {
                        if let executor = executor {
                            ExecutorView(executor: executor, itemWidth: itemWidth, cellCornerRadius: cellCornerRadius)
                        } else {
                            emptyCellView(itemWidth: itemWidth)
                        }
                    }
                    .dropDestination(for: ExecutorModel.self) { executors, _ in
                        handleDrop(executors: executors, pageID: page.id, index: index)
                    }
                }
            }
            .padding(.horizontal, gridPadding)
        }

    }
    
    // MARK: - Helper Methods
    
    private func calculateItemWidth(for totalWidth: CGFloat) -> CGFloat {
        (totalWidth - (gridPadding * 2 + columnSpacing * CGFloat(columns.count - 1))) / CGFloat(columns.count)
    }
    
    private func emptyCellView(itemWidth: CGFloat) -> some View {
        Spacer()
            .frame(width: itemWidth, height: itemWidth)
            .background(appState.editMode ? Color.gray.opacity(emptyCellBackgroundOpacity) : Color.clear)
            .cornerRadius(cellCornerRadius)
    }
    
    private func handleDrop(executors: [ExecutorModel], pageID: String, index: Int) -> Bool {
        guard let executor = executors.first else { return false }
        appState.swapExecutors(executorID: executor.id, pageID: pageID, index: index)
        return true
    }
}

#Preview {
//    PageView().environmentObject(AppState())
}
