//
//  VideoPlayerViewController.swift
//  Dictation To Text
//
//  Created by Artem Sherbachuk on 6/21/21.
//

import AVKit

final class VideoPlayerViewController: AVPlayerViewController {

    private let url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoGravity = .resizeAspectFill
        player = AVPlayer(url: url)
        showsPlaybackControls = false
    }

    func play() {
        player?.play()
    }

    func seekTo(time: TimeInterval) {
        let time = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        play()
    }

    func stop() {
        player?.pause()
    }

    func deleteAction() {
        try? FileManager.default.removeItem(at: url)
    }
}
