//
//  ViewController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/7/21.
//

import UIKit

class HearingAidViewController: BaseViewController {
    @IBOutlet weak var settingsButton: SpringButton!
    @IBOutlet weak var balanceView: BalanceView!
    @IBOutlet weak var micSelectionView: MicSelectionView!
    @IBOutlet weak var waveView: UIView!

    var volumeController: VolumeViewController {
        return children.compactMap({$0 as? VolumeViewController}).first!
    }

    let hearingAid = HearingAid()

    override func viewDidLoad() {
        super.viewDidLoad()
        volumeController.delegate = self
        micSelectionView.hearingAid = hearingAid
        let micPlot = hearingAid.micOutputPlot
        waveView.addSubview(micPlot)
        micPlot.constraintsToParent(view: waveView)
    }

    @IBAction func settingsAction(sender: SpringButton) {
        let vc: EQViewController = EQViewController.instantiate()
        vc.hearingAid = hearingAid
        present(vc, animated: true, completion: nil)
    }

    @IBAction func micAction(sender: SpringButton) {
        micSelectionView.isVisible = !micSelectionView.isVisible
        balanceView.isVisible =  false
    }

    @IBAction func balanceAction(sender: SpringButton) {
        balanceView.isVisible = !balanceView.isVisible
        micSelectionView.isVisible = false
    }
}

extension HearingAidViewController: VolumeViewControllerDelegate {
    func didChange(volume: CGFloat) {
        hearingAid.setMic(volume: Double(volume))
    }
}

final class BalanceView: SpringStackView {
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var rightIcon: UIImageView!

    var isVisible: Bool = false {
        didSet {
            isVisible ? show() : hide()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isHidden = true
    }

    func show() {
        isHidden = false
        animate(name:"fadeIn")
    }

    func hide() {
        animate(name:"fadeOut")
    }

    @IBAction func balanceAction(sender: UISlider) {

    }
}


final class MicSelectionView: SpringStackView {
    @IBOutlet weak var rearMicButton: MicButtonView!
    @IBOutlet weak var frontMicButton: MicButtonView!
    @IBOutlet weak var bottomMicButton: MicButtonView!

    var hearingAid: HearingAid? {
        didSet {
            guard let hearingAid = hearingAid else { return }
            rearMicButton.isHidden = hearingAid.backMic == nil
            frontMicButton.isHidden = hearingAid.frontMic == nil
            bottomMicButton.isHidden = hearingAid.bottomMic == nil
            bottomMicButton.isSelected = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isHidden = true
        rearMicButton.isSelected = false
        frontMicButton.isSelected = false
        bottomMicButton.isSelected = false
    }

    @IBAction func rearMicAction(sender: UIButton) {
        rearMicButton.isSelected = true
        frontMicButton.isSelected = false
        bottomMicButton.isSelected = false
        hearingAid?.setMicDevice(device: hearingAid?.backMic)
    }

    @IBAction func frontMicAction(sender: UIButton) {
        rearMicButton.isSelected = false
        frontMicButton.isSelected = true
        bottomMicButton.isSelected = false
        hearingAid?.setMicDevice(device: hearingAid?.frontMic)
    }

    @IBAction func bottomMicAction(sender: UIButton) {
        rearMicButton.isSelected = false
        frontMicButton.isSelected = false
        bottomMicButton.isSelected = true
        hearingAid?.setMicDevice(device: hearingAid?.bottomMic)
    }

    var isVisible: Bool = false {
        didSet {
            isVisible ? show() : hide()
        }
    }

    func show() {
        self.isHidden = false
        frontMicButton.alpha = 1
        rearMicButton.alpha = 1
        bottomMicButton.alpha = 1
        frontMicButton.animate(name:"squeezeRight", duration: 0.7)
        rearMicButton.animate(name:"squeezeRight", delay: 0.2, duration: 0.7)
        bottomMicButton.animate(name:"squeezeRight", delay: 0.35, duration: 0.7)
    }

    func hide() {
        frontMicButton.animate(name:"zoomOut")
        rearMicButton.animate(name:"zoomOut", delay: 0.2)
        bottomMicButton.animate(name:"zoomOut", delay: 0.35)
    }
}

final class MicButtonView: SpringView {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var title: UILabel!

    var isSelected: Bool = false {
        didSet {
            button.tintColor = isSelected ? #colorLiteral(red: 0.4901960784, green: 0.2470588235, blue: 0.8, alpha: 1) : #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
            title.textColor = isSelected ? #colorLiteral(red: 0.4901960784, green: 0.2470588235, blue: 0.8, alpha: 1) : #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        }
    }
}
