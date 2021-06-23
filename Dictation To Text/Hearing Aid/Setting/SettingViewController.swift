//
//  SettingViewController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/20/21.
//

import UIKit

final class SoundSettingViewController: BaseViewController {
    
    @IBOutlet weak var powerButton: UISwitch!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tableView: UITableView!

    var compressor: Compressor?

    var reverb: Reverb?

    var limiter: Limiter?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setting".localized()
        powerButton.onTintColor = Theme.buttonActiveColor
        resetButton.setTitle("Reset".localized(), for: .normal)
        resetButton.setTitleColor(Theme.buttonInactiveColor, for: .normal)
        pickerView.delegate = self
        pickerView.dataSource = self
        tableView.dataSource = self
        tableView.delegate = self
    }

    @IBAction func powerAction(sender: UISwitch) {

    }

    @IBAction func resetAction(sender: UIButton) {

    }
}

extension SoundSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    }


}

extension SoundSettingViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }


    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {

    }

    func pickerView(_ pickerView: UIPickerView,
                    attributedTitleForRow row: Int,
                    forComponent component: Int) -> NSAttributedString? {
        
    }

}

