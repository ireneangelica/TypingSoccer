//
//  Colors.swift
//  TypingSoccer
//
//  Created by Novia Rahman Nisa on 09/07/26.
//

import SwiftUI

/// Central color palette. Replaces scattered `Color(red:green:blue:)`
/// literals with named, reusable constants — makes future re-theming a
/// one-file change instead of a project-wide search.
extension Color {
 
    // MARK: Brand accents
 
//    /// Primary accent — titles, active states, button borders.
//    static let brandYellow = Color.yellow
 
    /// Secondary accent — icons, highlights (trophy, warning icon, etc).
    static let brandOrange = Color(red: 238/255, green: 170/255, blue: 82/255)
 
    /// Destructive / danger actions (e.g. confirming Exit).
    static let brandRed = Color(red: 0.85, green: 0.25, blue: 0.25)
 
    // MARK: Panels & backgrounds
 
    /// Muted gray panel background (top bar chip, settings — legacy).
    static let panelGray = Color(red: 109/255, green: 112/255, blue: 116/255)
 
    /// Near-black card background used by modal/overlay panels.
    static let panelDark = Color(red: 0.08, green: 0.09, blue: 0.11)
 
    // MARK: Text
 
    /// Muted light-gray text (e.g. profile chip label).
    static let textMuted = Color(red: 203/255, green: 197/255, blue: 197/255)
}
