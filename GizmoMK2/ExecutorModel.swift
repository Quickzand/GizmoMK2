//
//  Executor.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation
import SwiftUI

struct ExecutorModel : Identifiable, Codable, Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: ExecutorModel.self, contentType: .json)
    }
    
    
    var id : String
    var label: String
    var actionID : String
    var labelHidden : Bool
    var icon : String
    var backgroundColor : String
    var backgroundOpacity : Double
    var iconHidden : Bool
    
    enum CodingKeys: String, CodingKey {
          case label
          case id
          case actionID
        case labelHidden
        case icon
        case iconHidden
        case backgroundColor
        case backgroundOpacity
        
      }

      public init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          label = try container.decodeIfPresent(String.self, forKey: .label) ?? "TestLabel"
          id = try container.decodeIfPresent(String.self, forKey: .id) ?? "DefaultID" // Provide a default or handle missing id
          actionID = try container.decodeIfPresent(String.self, forKey: .actionID) ?? ""
          labelHidden = try container.decodeIfPresent(Bool.self, forKey: .labelHidden) ?? false
          icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "bolt.fill"
          iconHidden = try container.decodeIfPresent(Bool.self, forKey: .iconHidden) ?? false
          backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor) ?? "#000000"
          backgroundOpacity = try container.decodeIfPresent(Double.self, forKey: .backgroundOpacity) ?? 1
          
      }

    public init(id: String = UUID().uuidString ,label: String = "TestLabel",  actionID: String = "", labelHidden: Bool = false, icon : String = "bolt.fill", backgroundColor : String = "#000000", backgroundOpacity : Double = 0.5, iconHidden : Bool = false) {
          self.label = label
          self.id = id
          self.actionID = actionID
        self.labelHidden = labelHidden
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.backgroundOpacity = backgroundOpacity
        self.iconHidden = iconHidden
      }
    
    static var defaultValue : ExecutorModel {
        ExecutorModel(id: UUID().uuidString, label: "", actionID: "")
    }
}
