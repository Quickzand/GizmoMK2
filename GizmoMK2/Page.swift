//
//  Page.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation


struct Page : Identifiable, Codable {
    var id: String
    var executors : [ExecutorModel?]
    let colCount = 3
    let rowCount = 7
    
//    Adjusts the executors count and makes sure that if the array is not colCount * rowCount length, the rest gets filled with nils
    static func adjustExecutors(page : Page) -> Page {
        var temp  = page
        while(temp.executors.count < temp.colCount * temp.rowCount) {
            temp.executors.append(nil)
        }
        return temp
    }
}
