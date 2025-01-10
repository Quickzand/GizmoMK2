//
//  Page.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation

let colCount = 3
let rowCount = 7


struct PageModel : Identifiable, Codable {
    var id: String
    var executors : [ExecutorModel?]
    var name : String
    
    
 
    enum CodingKeys: String, CodingKey {
     case id
    case executors
    case name
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "DefaultID" // Provide a default or handle missing id
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "DefaultName"
        executors = try container.decodeIfPresent([ExecutorModel?].self, forKey: .executors) ?? []
    }
    
    public init(name : String = "DefaultName", executors : [ExecutorModel?] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.executors = executors
    }
    
    
//    Adjusts the executors count and makes sure that if the array is not colCount * rowCount length, the rest gets filled with nils
    static func adjustExecutors(page : PageModel) -> PageModel {
        var temp  = page
        while(temp.executors.count < colCount * rowCount) {
            temp.executors.append(nil)
        }
        return temp
    }
}
