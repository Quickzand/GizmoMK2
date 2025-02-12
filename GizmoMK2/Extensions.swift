//
//  Extensions.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 10/27/24.
//

import Foundation
import SwiftUI

extension View {
    func innerShadow(color: Color, radius: CGFloat = 0.1) -> some View {
        modifier(InnerShadow(color: color, radius: min(max(0, radius), 1)))
    }
}

private struct InnerShadow: ViewModifier {
    var color: Color = .gray
    var radius: CGFloat = 0.1
    
    private var colors: [Color] {
        [color.opacity(0.75), color.opacity(0.0), .clear]
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .overlay(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .top, endPoint: .bottom)
                    .frame(height: self.radius * self.minSide(geo)),
                         alignment: .top)
                .overlay(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .bottom, endPoint: .top)
                    .frame(height: self.radius * self.minSide(geo)),
                         alignment: .bottom)
                .overlay(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .leading, endPoint: .trailing)
                    .frame(width: self.radius * self.minSide(geo)),
                         alignment: .leading)
                .overlay(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .trailing, endPoint: .leading)
                    .frame(width: self.radius * self.minSide(geo)),
                         alignment: .trailing)
        }
    }
    
    func minSide(_ geo: GeometryProxy) -> CGFloat {
        CGFloat(3) * min(geo.size.width, geo.size.height) / 2
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
         // Convert to UIColor and get RGB components
         let uiColor = UIColor(self)
         var red: CGFloat = 0
         var green: CGFloat = 0
         var blue: CGFloat = 0
         var alpha: CGFloat = 0
         
         uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
         
         // Ensure the components are in a valid range
         guard (0...1).contains(red), (0...1).contains(green), (0...1).contains(blue) else {
             return nil
         }
         
         // Convert to hex and return formatted string
         let r = Int(red * 255)
         let g = Int(green * 255)
         let b = Int(blue * 255)
         
         return String(format: "#%02X%02X%02X", r, g, b)
     }
}


struct CustomCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
