//
//  AlternateIconsViewController.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 2/2/21.
//
import UIKit

fileprivate enum Icon: String, CaseIterable {

    case DefaultAppIcon,
         AppIconPurpule, AppIconOrange, AppIconRed, AppIconBlue

    var previewImage: UIImage? {
        switch self {
        case .DefaultAppIcon:
            return UIImage(named: "appIcon")
        case .AppIconPurpule:
            return UIImage(named: "Purpule-Icon-180.png")
        case .AppIconOrange:
            return UIImage(named: "Orange-Icon-180.png")
        case .AppIconRed:
            return UIImage(named: "Red-Icon-180.png")
        case .AppIconBlue:
            return UIImage(named: "Blue-Icon-180.png")
        }
    }

    var isSelected: Bool {
        if let alternateIconName = UIApplication.shared.alternateIconName {
            return self.rawValue == alternateIconName
        } else {
            return self == .DefaultAppIcon
        }
    }
}

final class AlternateIconsViewController: BasePopoverViewController {

    @IBOutlet fileprivate var defaultIcon: IconView!
    @IBOutlet fileprivate var purpuleIcon: IconView!
    @IBOutlet fileprivate var orangeIcon: IconView!
    @IBOutlet fileprivate var redIcon: IconView!
    @IBOutlet fileprivate var blueIcon: IconView!

    @IBOutlet weak var closeButton: UIButton!

    private var icons: [IconView] {
        return [defaultIcon,purpuleIcon,orangeIcon,redIcon,blueIcon]
    }

    @IBOutlet fileprivate var bgBlurView: UIVisualEffectView?

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.tintColor = Theme.buttonInactiveColor
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layer.borderWidth = 2
        view.layer.borderColor = Theme.buttonInactiveColor.withAlphaComponent(0.5).cgColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
    }

    private func reload() {
        for (index, icon) in Icon.allCases.enumerated() {
            icons[safe:index]?.icon = icon
        }
    }

    private func setAlternate(icon: Icon) {
        guard icon.isSelected == false,
              UIApplication.shared.supportsAlternateIcons else { return }
        let iconName: String? = icon == .DefaultAppIcon ? nil : icon.rawValue
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                presentError(error: error)
                return
            }
        }
        remove()
    }

    @IBAction func changeIconAction(sender: UIButton) {
        guard let iconView = sender.superview as? IconView,
              let icon = iconView.icon else { return }
        setAlternate(icon: icon)
    }

    @IBAction func closeAction(sender:UIButton) {
        remove()
    }
}

final class IconView: SpringView {

    @IBOutlet weak var checkmarkIcon: UIImageView!

    @IBOutlet weak var iconButton: UIButton!

    fileprivate var icon: Icon? {
        didSet {
            if let image = icon?.previewImage {
                iconButton.setBackgroundImage(image, for: .normal)
            }
            checkmarkIcon.isHidden = icon?.isSelected == false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkIcon.tintColor = Theme.buttonActiveColor
        checkmarkIcon.isHidden = true
    }

    @IBAction func buttonAction() {
        animate(name: "pop")
    }

}
