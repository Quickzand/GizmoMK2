//
//  PageView.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import SwiftUI

struct PageView: View {
    @EnvironmentObject var appState: AppState
    
    
    @State var newExecutor : ExecutorModel = ExecutorModel(label:"Default Label")
    
    var pageNum: Int
    
    // Layout customization variables
    let columnSpacing: CGFloat = 10
    let rowSpacing: CGFloat = 10
    let gridPadding: CGFloat = 50
    let cellCornerRadius: CGFloat = 8
    let emptyCellBackgroundOpacity: Double = 0.1
    let filledCellBackgroundOpacity: Double = 0.1
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate item width based on screen width and spacing
            let itemWidth = (geometry.size.width - (gridPadding * 2 + columnSpacing * CGFloat(columns.count - 1))) / CGFloat(columns.count)
            
            LazyVGrid(columns: columns, spacing: rowSpacing) {
                ForEach(Array(Page.adjustExecutors(page:appState.pages[pageNum]).executors.enumerated()), id: \.offset) { index, executor in
                    if let executor = executor {
                        ExecutorView(executor: executor, itemWidth: itemWidth, cellCornerRadius:cellCornerRadius )
                            .dropDestination(for: ExecutorModel.self) {executors, spatialPostion in
                                guard let executor = executors.first else { return false }
                                appState.swapExecutors(executorID: executor.id, pageID: appState.pages[pageNum].id, index: index)
                                return true
                            }
                    }
                    else
 {
                        Spacer()
                            .frame(width: itemWidth, height: itemWidth)
                            .background(appState.editMode ? Color.gray.opacity(emptyCellBackgroundOpacity) : Color.clear) // Light gray for empty cells
                            .cornerRadius(cellCornerRadius)
                            .dropDestination(for: ExecutorModel.self) {executors, spatialPostion in
                                guard let executor = executors.first else { return false }
                                appState.swapExecutors(executorID: executor.id, pageID: appState.pages[pageNum].id, index: index)
                                return true
                            }
                    }
                }
            }
            .padding(.horizontal, gridPadding) // Horizontal padding around the grid
        }
        .sheet(isPresented: $appState.executorCreationShown) {
            ExecutorCreationSheetView()
        }
    }
}

#Preview {
//    PageView(pageNum: 0).environmentObject(AppState())
}
