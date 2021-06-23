//
//  ParticleView.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 11/14/20.
//

import SpriteKit

class ParticleView: SKView {

    private(set) var particle: SKEmitterNode?

    var particleColor: UIColor = Theme.buttonActiveColor

    var particleImage: UIImage?

    var particleName: String = "" {
        didSet {
            particle?.removeFromParent()
            particle = nil
            commonInit()
        }
    }

    init(frame: CGRect, fileNamed: String) {
        particleName = fileNamed
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    internal func commonInit() {
        backgroundColor = .clear
        if particleName.isEmpty == false,
           let emitter = SKEmitterNode(fileNamed: particleName) {
            emitter.position = CGPoint(x: frame.midX, y: frame.midY)
            let scene = SKScene(size: frame.size)
            scene.backgroundColor = .clear
            scene.addChild(emitter)
            presentScene(scene)
            particle = emitter

            endUpdate()
        }
    }

    public func endUpdate() {
        particle?.isHidden = true
        particle?.isPaused = true
    }

    public func beginUpdate() {
        if let particleImage = particleImage {
            particle?.particleTexture = SKTexture(image: particleImage)
        }
        particle?.isHidden = false
        particle?.isPaused = false
        particle?.particlePositionRange = CGVector(dx: frame.width,
                                                   dy: frame.height)
        particle?.particleColor = particleColor
        particle?.particleColorBlendFactor = 1.0
    }

    public func update(average: Float,
                       yAcceleration: CGFloat = 0,
                       xAcceleration: CGFloat = 0) {
        particle?.particleScaleSpeed = CGFloat(abs(average))
        particle?.particleScaleRange = CGFloat(abs(average))
        particle?.particleScale = CGFloat(average)
        particle?.yAcceleration = yAcceleration
        particle?.xAcceleration = xAcceleration
    }
}
