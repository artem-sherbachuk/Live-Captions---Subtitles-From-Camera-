//
//  Theme.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/12/21.
//

import UIKit

let ThemeDidChangeNotificationName = Notification.Name.init("ThemeDidChangeColor")

struct Theme {
    private init() {}

    enum Color: Int {
        case white,orange,red,blue,green

        var color: UIColor {
            switch self {
            case .white:
                return #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            case .orange:
                return #colorLiteral(red: 1, green: 0.5137254902, blue: 0, alpha: 1)
            case .red:
                return #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            case .blue:
                return #colorLiteral(red: 0, green: 0.4731103778, blue: 1, alpha: 1)
            case .green:
                return #colorLiteral(red: 0, green: 0.8917200565, blue: 0, alpha: 1)
            }
        }

        var gradientColors: [UIColor] {
            switch self {
            case .white:
                return [#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)]
            case .orange:
                return [#colorLiteral(red: 1, green: 0.7803921569, blue: 0, alpha: 1), #colorLiteral(red: 0.9294117647, green: 0.1019607843, blue: 0.1019607843, alpha: 1)]
            case .red:
                return [#colorLiteral(red: 1, green: 0.5137254902, blue: 0, alpha: 1), #colorLiteral(red: 0.9294117647, green: 0.1019607843, blue: 0.1019607843, alpha: 1)]
            case .blue:
                return [#colorLiteral(red: 0, green: 1, blue: 0.8784313725, alpha: 1), #colorLiteral(red: 0, green: 0.4, blue: 1, alpha: 1)]
            case .green:
                return [#colorLiteral(red: 0.8588235294, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 0.07843137255, green: 0.8117647059, blue: 0.1529411765, alpha: 1)]
            }
        }

        var gradientInactiveColors: [UIColor] {
            return [buttonInactiveColor, buttonInactiveColor]
        }
    }

    static var current: Color = .red

    static func setupAppearance() {
        let theme = (Color(rawValue: ThemeSettingsRow.ControlsColor.value as? Int ?? 0) ?? .white)
        current = theme
        buttonActiveColor = theme.color

        UITabBar.appearance().tintColor = Theme.buttonActiveColor
        UITabBar.appearance().unselectedItemTintColor = Theme.buttonInactiveColor
        UIButton.appearance().tintColor = Theme.buttonActiveColor
    }

    static private(set) var buttonActiveColor = current.color

    static let buttonInactiveColor: UIColor = UIColor(named: "textColor") ?? UIColor.systemGray

    static var enableDarkMode: Bool = false {
        didSet {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = enableDarkMode ? .dark : .light
                window.subviews.forEach({ $0.overrideUserInterfaceStyle = enableDarkMode ? .dark : .light })
            }
            ThemeSettingsRow.DarkMode.setValue(enableDarkMode)
        }
    }

    static func setControlsColor(_ color: Color) {
        current = color
        ThemeSettingsRow.ControlsColor.setValue(color.rawValue)
        buttonActiveColor = color.color
        setupAppearance()
        NotificationCenter.default.post(name: ThemeDidChangeNotificationName,
                                        object: nil)
    }
}
