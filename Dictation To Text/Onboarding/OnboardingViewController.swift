//
//  OnboardingViewController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/28/21.
//

import UIKit

var isOnboardingPresented: Bool {
    get { UserDefaults.standard.bool(forKey: "isOnboardingPresented") }
    set { UserDefaults.standard.setValue(newValue, forKey: "isOnboardingPresented") }
}

final class OnboardingViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var nextButton: SubscriptionButtonView!

    var completion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Please Allow Microphone Usage".localized()
        descriptionLabel.text = "Dear User, for proper work with speech recognition & hearing aid, we need your microphone usage permission. Thank You!".localized()
        nextButton.button.setTitle("Next".localized(), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.fadeIn(from: 0, to: 1, duration: 1.0)
        descriptionLabel.fadeIn(from: 0, to: 1, duration: 1.0)
    }

    @IBAction func next(sender: UIButton) {
        if #available(iOS 14.5, *) {
            titleLabel.text = "Please Allow Tracking Permission".localized()
            descriptionLabel.text = "Dear User, we use your data only for analytics purpose. To improve the app and help you get better product. We don't share this data to any third party. Thank you!".localized()
            titleLabel.fadeIn(from: 0, to: 1, duration: 1.0)
            descriptionLabel.fadeIn(from: 0, to: 1, duration: 1.0)
            checkIfShouldRequestIDFA { [weak self] in
                self?.dismiss()
            }
        } else {
            dismiss()
        }
    }

    private func dismiss() {
        dismiss(animated: false) { [weak self] in
            self?.completion?()
        }
    }
}
