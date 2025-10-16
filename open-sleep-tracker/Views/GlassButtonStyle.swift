//
//  GlassButtonStyle.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import SwiftUI

enum GlassButtonStyleType {
    case primary
    case secondary
    case destructive
}

struct GlassButtonStyle: ButtonStyle {
    let style: GlassButtonStyleType
    
    init(style: GlassButtonStyleType = .primary) {
        self.style = style
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(backgroundGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .primary
        case .destructive:
            return .white
        }
    }
    
    private var backgroundGradient: LinearGradient {
        switch style {
        case .primary:
            return LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return LinearGradient(
                colors: [.white.opacity(0.2), .white.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .destructive:
            return LinearGradient(
                colors: [.red, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return .blue.opacity(0.3)
        case .secondary:
            return .black.opacity(0.1)
        case .destructive:
            return .red.opacity(0.3)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Button("Primary Button") { }
            .buttonStyle(GlassButtonStyle(style: .primary))
        
        Button("Secondary Button") { }
            .buttonStyle(GlassButtonStyle(style: .secondary))
        
        Button("Destructive Button") { }
            .buttonStyle(GlassButtonStyle(style: .destructive))
    }
    .padding()
    .background(
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}