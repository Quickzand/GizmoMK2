//
//  Settings.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation

struct Settings: Codable {
    
    
    var backgroundEnabled: Bool {
        didSet { save() }
    }
    var previouslyConnectedHostName : String {
        didSet { save() }
    }

    // Default values for the settings
    init(backgroundEnabled: Bool = true, previouslyConnectedHostName: String = "") {
        self.backgroundEnabled = backgroundEnabled
        self.previouslyConnectedHostName = previouslyConnectedHostName
    }

    // Save settings to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "settings")
        }
    }

    // Load settings from UserDefaults
    static func load() -> Settings {
        if let savedData = UserDefaults.standard.data(forKey: "settings"),
           let decoded = try? JSONDecoder().decode(Settings.self, from: savedData) {
            return decoded
        }
        return Settings() // Return default settings if none are saved
    }
}
