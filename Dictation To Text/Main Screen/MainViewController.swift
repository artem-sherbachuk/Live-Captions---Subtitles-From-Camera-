//
//  MainViewController.swift
//  Dictation To Text
//
//  Created by Artem Sherbachuk on 6/21/21.
//

import UIKit

final class MainViewController: BaseViewController {

    @IBOutlet weak var topMenu: TopMenuView!

    @IBOutlet weak var menuView: MainMenuView!

    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var subtitlesView: UIView!

    private var cameraVC: CameraViewController?

    private var videoPlayerVC: VideoPlayerViewController?

    private var subtitlesVC:SubtitlesViewController = SubtitlesViewController.instantiate()

    private var isRecording = false {
        didSet {
            isFullScreen = isRecording
            menuView.isRecordingButtonSelected = isRecording
        }
    }

    private var isFullScreen: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.4) {
                self.topMenu.isHidden = self.isFullScreen
                self.menuView.isHidden = self.isFullScreen
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCamera()
        addSubtitles()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SpeechRecognition.requestAuthorization()
    }

    private func addCamera() {
        removeCameraAndVideoPlayer()
        cameraVC = CameraViewController()
        addChildController(cameraVC!, inView: videoView)
    }

    private func addSubtitles() {
        addChildController(subtitlesVC, inView: subtitlesView)
        subtitlesVC.delegate = self
    }

    @IBAction func exportAction(sender:UIButton) {

    }

    @IBAction func languageAction(sender:UIButton) {
        let localeSelection = SpeechRecognitionLocaleSelectionViewController()
        localeSelection.selectionDelegate = self
        presentAsPopover(vc: localeSelection, sourceView: sender)
    }

    @IBAction func settingsAction(sender:UIButton) {

    }

    @IBAction func deleteAction(sender:UIButton) {
        let title = "Delete".localized()
        let message = "Are you sure you want to delete this recording?"
        let left = "No".localized()
        let right = "Yes".localized()
        presentAlert(controller: self, title: title, message: message, leftActionTitle: left, rightActionTitle: right,
                     leftActionStyle: .default, rightActionStyle: .destructive,
                     leftActionCompletion: nil) { [weak self] in
            self?.videoPlayerVC?.deleteAction()
            self?.subtitlesVC.deleteSubtitles()
            TapticEngine.notification.feedback(.success)
        }
    }

    @IBAction func subtitleAction(sender:UIButton) {
        
    }

    @IBAction func recordAction(sender:UIButton) {
        if !user.isPremium {
            presentSubscriptionViewController()
            return
        }

        if isRecording {
            subtitlesVC.stop()
            cameraVC?.stop { [weak self] url in
                self?.addVideoPlayer(url: url)
            }
            TapticEngine.customHaptic.playOff()
        } else {
            cameraVC?.record()
            subtitlesVC.record()
            TapticEngine.customHaptic.playOn()
        }

        isRecording = !isRecording
    }

    @IBAction func filtersAction(sender:UIButton) {
        cameraVC?.filterAction(sender: sender)
    }

    @IBAction func switchCameraAction(sender:UIButton) {
        guard let cameraVC = cameraVC else { return }
        cameraVC.switchCamera()
        let title = cameraVC.camera.position == .front ? "Back".localized() : "Front".localized()
        menuView.switchCameraButton.title?.text = title
    }

    private func addVideoPlayer(url: URL) {
        removeCameraAndVideoPlayer()
        let player = VideoPlayerViewController(url: url)
        addChildController(player, inView: videoView)
        videoPlayerVC = player
    }

    private func removeCameraAndVideoPlayer() {
        if let cameraVC = cameraVC {
            removeChildController(cameraVC)
            self.cameraVC = nil
        }

        if let videoPlayerVC = videoPlayerVC {
            removeChildController(videoPlayerVC)
            self.videoPlayerVC = nil
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isRecording {
            isFullScreen = !isFullScreen
        }
    }
}

extension MainViewController: SpeechRecognitionLocaleSelectionDelegate {
    func didSelectLocale(_ locale: Locale) {
        subtitlesVC.speech.setLocale(locale)
        topMenu.updateLanguageButtonTitle()
    }
}

extension MainViewController: SubtitlesViewControllerDelegate {
    func didSelectSubtitle(_ subtitle: SubtitleTranscription) {
        videoPlayerVC?.seekTo(time: subtitle.timestamp)
    }
}

final class MainMenuView: UIStackView {
    @IBOutlet weak var recordButton: ButtonView!
    @IBOutlet weak var filtersButton: ButtonView!
    @IBOutlet weak var switchCameraButton: ButtonView!


    override func awakeFromNib() {
        super.awakeFromNib()
        isRecordingButtonSelected = false
    }

    var isRecordingButtonSelected: Bool = false {
        didSet {
            recordButton.isSelected = isRecordingButtonSelected
            if isRecordingButtonSelected {
                recordButton.animate(name:"flash", repeatCount:.infinity)
            } else {
                recordButton.layer.removeAllAnimations()
            }
        }
    }
}


final class TopMenuView: UIStackView {

    @IBOutlet weak var exportButton: ButtonView!
    @IBOutlet weak var languageButton: ButtonView!
    @IBOutlet weak var settingsButton: ButtonView!

    override func awakeFromNib() {
        super.awakeFromNib()
        updateLanguageButtonTitle()
    }

    func updateLanguageButtonTitle() {
        let language = SpeechRecognition.localizedSelectedLanguage()
        languageButton.title?.text = language
    }
}
