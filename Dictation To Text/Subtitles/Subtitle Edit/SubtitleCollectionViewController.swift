//
//  SubtitleEditViewController.swift
//  Dictation To Text
//
//  Created by Artem Sherbachuk on 6/22/21.
//

import UIKit
import Speech

final class SubtitleCollectionViewController: BaseViewController {

    var transcription: TranscriptionSession? {
        didSet {
            updateSubtitles()
        }   
    }

    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: SubtitlesViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        view.layer.cornerRadius = 10
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
    }

    private func updateSubtitles() {
        collectionView.reloadData()
        scrollToBottom()
    }

    func scrollToBottom() {
        if collectionView.contentSize.height > view.bounds.height {
            let point = CGPoint(x: 0.0, y: (collectionView.contentSize.height - view.bounds.height))
            collectionView.setContentOffset(point, animated: true)
        }
    }
}

extension SubtitleCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transcription?.segments.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubtitleCell.id, for: indexPath) as! SubtitleCell
        let subtitle = transcription?.segments[indexPath.row]
        let text = subtitle?.substring ?? ""
        cell.subtitleLabel.text = text
        //let timestamp = TimestampTimeFormatter.string(from: subtitle.timestamp)
        return cell
    }
}

extension SubtitleCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let subtitle = transcription?.segments[indexPath.row] else { return }
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectSubtitle(subtitle)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! SubtitleCell
        let subtitlesCount = transcription?.segments.count ?? 0
        let isLastRow = indexPath.row == subtitlesCount - 1

        if isLastRow {
            cell.animateAppearance()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
}


final class SubtitleCell: SpringCollectionViewCell {
    static let id = "SubtitleCell"
    @IBOutlet weak var subtitleLabel: UILabel!

    func animateAppearance() {
        animate(name:"zoomIn", duration: 0.4)
        subtitleLabel.textColor = UIColor.yellow
        UIView.animate(withDuration: 0.4) {
            self.subtitleLabel.textColor = UIColor.white
        }
    }
}

var TimestampTimeFormatter: DateComponentsFormatter = {
    let formatter =  DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [ .minute, .second]
    formatter.zeroFormattingBehavior = [ .pad ]
    return formatter
}()
