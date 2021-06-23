import UIKit
import AVFoundation

class CameraViewController: BaseViewController {

    private(set) var camera: BBMetalCamera!

    private var metalView: BBMetalView!

    private var videoWriter: BBMetalVideoWriter!

    private var filePath = NSTemporaryDirectory() + "test.mp4"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        metalView = BBMetalView(frame: view.bounds)
        view.addSubview(metalView)

        let url = URL(fileURLWithPath: filePath)
        videoWriter = BBMetalVideoWriter(url: url, frameSize: BBMetalIntSize(width: 1080, height: 1920))
        
        camera = BBMetalCamera(sessionPreset: .hd1920x1080)
        camera.audioConsumer = videoWriter
        camera.add(consumer: metalView)
        camera.add(consumer: videoWriter)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        metalView.frame = view.bounds
        camera.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        camera.stop()
    }

    func filterAction(sender: UIButton) {
        let vc = CameraFilterViewController()
        vc.selectionDelegate = self
        presentAsPopover(vc: vc, sourceView: sender)
    }
    
    func switchCamera() {
        camera.switchCameraPosition()
    }

    func record() {
        try? FileManager.default.removeItem(at: videoWriter.url)
        videoWriter.start()
    }

    func stop(completion: @escaping (URL) -> Void) {
        let url = videoWriter.url
        videoWriter.finish {
            DispatchQueue.main.async {
                completion(url)
            }
        }
    }
}

extension CameraViewController: CameraFilterViewControllerDelegate {
    func didSelectFilter(_ filterType: FilterType) {
        camera.removeAllConsumers()

        if let filter = filterType.filter {
            camera.add(consumer: filter).add(consumer: metalView)
            filter.add(consumer: videoWriter)
        } else {
            camera.add(consumer: metalView)
            camera.willTransmitTexture = nil
            camera.add(consumer: videoWriter)
        }
    }
}
