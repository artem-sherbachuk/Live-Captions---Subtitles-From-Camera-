//
//  SpeechRecognitionViewController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/12/21.
//

import UIKit

protocol SubtitlesViewControllerDelegate: AnyObject {
    func didSelectSubtitle(_ subtitle: SubtitleTranscription)
}


final class SubtitlesViewController: BaseViewController {

    let speech = SpeechRecognition()

    @IBOutlet weak var subtitleView: UIView!

    private var subtitleVC: SubtitleCollectionViewController {
        return children.compactMap({ $0 as? SubtitleCollectionViewController }).first!
    }

    weak var delegate: SubtitlesViewControllerDelegate? {
        didSet {
            subtitleVC.delegate = delegate
        }
    }

    private lazy var translator = MLTranslator()

    private var isLandscape: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveView(g:)))
        view.addGestureRecognizer(pan)
    }

    @objc private func moveView(g: UIPanGestureRecognizer) {
        let location = g.location(in: view)
        subtitleView.center = location
    }

    func deleteSubtitles() {
        speech.deleteSessionData()
    }

    @IBAction func rotate(sender: UIButton) {
        isLandscape = !isLandscape

        if isLandscape {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }

    func record() {
        speech.stopRecognition()
        UIApplication.shared.isIdleTimerDisabled = true
        speech.startRecognition { [weak self] session in
            guard let `self` = self else { return }
            self.subtitleVC.transcription = session
        }
    }

    func stop() {
        UIApplication.shared.isIdleTimerDisabled = false
        speech.stopRecognition()
    }
}
