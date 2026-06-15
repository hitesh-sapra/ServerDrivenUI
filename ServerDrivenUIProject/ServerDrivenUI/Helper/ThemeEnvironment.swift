//
//  ThemeEnvironment.swift
//  ServerDrivenUIDemo
//

import SwiftUI


struct AppThemeKey: EnvironmentKey {
    static let defaultValue: Theme = Theme(
        backgroundColor: "#FFFFFF",
        textColor: "#111827",
        borderColor: "#D1D5DB",
        errorColor: "#B91C1C"
    )
}
 
extension EnvironmentValues {
    var appTheme: Theme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
