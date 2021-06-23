//
//  ButtonView.swift
//  Notes
//
//  Created by Artem Sherbachuk on 6/18/21.
//

import UIKit

class ButtonView: SpringView {
    @IBOutlet weak var button: SpringButton!
    @IBOutlet weak var title: UILabel?

    var isSelected: Bool = false {
        didSet {
            setupUIColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(setupUIColor), name: ThemeDidChangeNotificationName, object: nil)

        alpha = 0
        animate(name:"pop")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func setupUIColor() {
        button.isSelected = isSelected
        title?.textColor = isSelected ? Theme.buttonActiveColor : Theme.buttonInactiveColor
    }
}
