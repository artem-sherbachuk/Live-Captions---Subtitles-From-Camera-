//
//  SettingsViewController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/9/21.
//

import UIKit

final class EQViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        gradientLayer.removeFromSuperlayer()
        particle.removeFromSuperview()
    }
}

extension EQViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EQTableViewCell") as! EQTableViewCell
        return cell
    }
}

final class EQTableViewCell: SpringTableViewCell {

}
