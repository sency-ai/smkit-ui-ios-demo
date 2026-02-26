//
//  SkeletonStylePreviewView.swift
//  SMKitUIDemoApp
//

import UIKit
import SMKitUI

/// Small preview of a skeleton style: one joint (dot) and optional limb segment.
/// Uses a local mirror of SDK preset styles for preview only.
final class SkeletonStylePreviewView: UIView {

    static let previewSize = CGSize(width: 52, height: 28)

    var preset: SMKitUI.SkeletonPreset = .default {
        didSet { updateLayers() }
    }
    var connectionStyle: SMKitUI.SkeletonConnectionStyle = .solid {
        didSet { updateLayers() }
    }
    var dotsOpacity: CGFloat = 1 {
        didSet { updateLayers() }
    }
    var connectionsOpacity: CGFloat = 1 {
        didSet { updateLayers() }
    }
    var dotsInnerColorOption: SkeletonColorOption? = nil {
        didSet { updateLayers() }
    }
    var dotsOuterColorOption: SkeletonColorOption? = nil {
        didSet { updateLayers() }
    }
    var connectionsInnerColorOption: SkeletonColorOption? = nil {
        didSet { updateLayers() }
    }
    var connectionsOuterColorOption: SkeletonColorOption? = nil {
        didSet { updateLayers() }
    }
    var dotsGlow: CGFloat = 0 {
        didSet { updateLayers() }
    }
    var connectionsGlow: CGFloat = 0 {
        didSet { updateLayers() }
    }
    var lineWidthScale: CGFloat = 1 {
        didSet { updateLayers() }
    }
    var outlineScale: CGFloat = 1 {
        didSet { updateLayers() }
    }
    var softness: CGFloat = 0 {
        didSet { updateLayers() }
    }
    var jointShape: SMKitUI.SkeletonJointShape = .circle {
        didSet { updateLayers() }
    }

    private let jointLayer = CAShapeLayer()
    private let limbLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 6
        jointLayer.contentsScale = UIScreen.main.scale
        limbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(jointLayer)
        layer.addSublayer(limbLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }

    private func previewParams(for preset: SMKitUI.SkeletonPreset) -> (jointRad: CGFloat, jointFill: UIColor, jointStroke: UIColor, limbLineWidth: CGFloat, limbStroke: UIColor, limbFill: UIColor) {
        switch preset {
        case .default:
            return (8, .black, .white, 7, .white, .white)
        case .minimalDots:
            return (5, .black, .white, 1.5, .white.withAlphaComponent(0.8), .white.withAlphaComponent(0.6))
        case .thinOutline:
            return (6, .black, .white, 3, .white, .white)
        case .monochromeClean:
            let g = UIColor(white: 0.92, alpha: 1), s = UIColor(white: 0.75, alpha: 1)
            return (7, g, s, 5, s, g)
        case .neonGlow:
            let accent = UIColor(red: 0.2, green: 0.85, blue: 0.95, alpha: 1)
            return (7, UIColor(white: 0.25, alpha: 1), .white, 4, accent.withAlphaComponent(0.9), accent.withAlphaComponent(0.5))
        case .boldHighlight:
            return (10, .black, .white, 10, .white, .white)
        case .softFill:
            return (8, .black, .white, 6, .white, .white.withAlphaComponent(0.85))
        case .wireframe:
            return (5, .black, .white, 2, .white.withAlphaComponent(0.9), .clear)
        case .highContrast:
            return (9, .black, .white, 8, .white, .white)
        case .pastel:
            let pale = UIColor(red: 0.95, green: 0.95, blue: 1, alpha: 1)
            return (7, UIColor(white: 0.4, alpha: 1), .white, 5, .white, pale)
        case .darkOutline:
            let dark = UIColor(white: 0.15, alpha: 1)
            return (7, dark, .white, 4, .white.withAlphaComponent(0.9), dark)
        case .minimalLine:
            return (5, .black, .white, 2, .white, .white.withAlphaComponent(0.7))
        case .doubleStroke:
            return (8, .black, .white, 5, .white, .white)
        case .gradientReady:
            return (7, UIColor(white: 0.2, alpha: 1), .white, 5, .white, .white.withAlphaComponent(0.9))
        case .subtleShadow:
            return (7, .black, .white, 5, .white, .white)
        case .classic:
            return (8, .black, .white, 6, .white, .white)
        case .athletic:
            return (10, .black, .white, 9, .white, .white)
        case .premium:
            let gold = UIColor(red: 0.85, green: 0.7, blue: 0.35, alpha: 1)
            let dark = UIColor(white: 0.12, alpha: 1)
            return (8, dark, gold, 5, gold.withAlphaComponent(0.9), dark)
        case .hologram:
            let cyan = UIColor(red: 0.4, green: 0.9, blue: 0.95, alpha: 1)
            return (6, .black, cyan, 3, cyan, cyan.withAlphaComponent(0.2))
        case .matte:
            let muted = UIColor(white: 0.5, alpha: 1)
            return (7, muted, .white.withAlphaComponent(0.8), 4, .white.withAlphaComponent(0.7), muted.withAlphaComponent(0.6))
        case .neonPulse:
            let bright = UIColor(red: 0.3, green: 1, blue: 0.6, alpha: 1)
            return (8, UIColor(white: 0.2, alpha: 1), .white, 5, bright, bright.withAlphaComponent(0.5))
        case .outlineOnly:
            return (7, .clear, .white, 3, .white.withAlphaComponent(0.95), .clear)
        case .slim:
            return (5, .black, .white, 1.5, .white, .white.withAlphaComponent(0.6))
        case .thick:
            return (12, .black, .white, 12, .white, .white)
        case .studio:
            let neutral = UIColor(white: 0.9, alpha: 1)
            let stroke = UIColor(white: 0.7, alpha: 1)
            return (7, neutral, stroke, 5, stroke, neutral)
        case .accessibility:
            return (10, .black, .white, 10, .white, .white)
        }
    }

    private func applyOpacity(_ color: UIColor, _ op: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return color.withAlphaComponent(a * op)
        }
        return color.withAlphaComponent(op)
    }

    private static func path(for shape: SMKitUI.SkeletonJointShape, pointRad: CGFloat) -> UIBezierPath {
        switch shape {
        case .circle:
            return UIBezierPath(arcCenter: .zero, radius: pointRad, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        case .square:
            return UIBezierPath(rect: CGRect(x: -pointRad, y: -pointRad, width: pointRad * 2, height: pointRad * 2))
        case .triangle:
            let h = pointRad * 2
            let halfSide = h / CGFloat(3).squareRoot()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: -pointRad))
            path.addLine(to: CGPoint(x: halfSide, y: pointRad))
            path.addLine(to: CGPoint(x: -halfSide, y: pointRad))
            path.close()
            return path
        case .diamond:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: -pointRad))
            path.addLine(to: CGPoint(x: pointRad, y: 0))
            path.addLine(to: CGPoint(x: 0, y: pointRad))
            path.addLine(to: CGPoint(x: -pointRad, y: 0))
            path.close()
            return path
        case .star:
            let path = UIBezierPath()
            let outerR = pointRad
            let innerR = pointRad * 0.4
            for i in 0..<10 {
                let angle = (CGFloat(i) * .pi / 5) - .pi / 2
                let r = i.isMultiple(of: 2) ? outerR : innerR
                let p = CGPoint(x: r * cos(angle), y: r * sin(angle))
                if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            path.close()
            return path
        case .hexagon:
            let path = UIBezierPath()
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3 - .pi / 6
                let p = CGPoint(x: pointRad * cos(angle), y: pointRad * sin(angle))
                if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            path.close()
            return path
        }
    }

    private func updateLayers() {
        let params = previewParams(for: preset)
        let dotsOp = min(1, max(0, dotsOpacity))
        let connOp = min(1, max(0, connectionsOpacity))
        let jointFill: UIColor = {
            let base = dotsInnerColorOption?.uiColor ?? params.jointFill
            return applyOpacity(base, dotsOp)
        }()
        let jointStroke: UIColor = {
            let base = dotsOuterColorOption?.uiColor ?? params.jointStroke
            return applyOpacity(base, dotsOp)
        }()
        let limbStroke: UIColor = {
            let base = connectionsOuterColorOption?.uiColor ?? params.limbStroke
            return applyOpacity(base, connOp)
        }()
        let b = bounds
        let scale: CGFloat = min(b.width / 52, b.height / 28, 1)
        let jointCenter = CGPoint(x: 16 * scale, y: b.midY)
        let jointRad = min(params.jointRad * 0.5 * scale, 8)
        let jointPath = Self.path(for: jointShape, pointRad: jointRad)
        let pathBounds = jointPath.bounds
        let lineStart = CGPoint(x: jointCenter.x + pathBounds.maxX + 2, y: b.midY)
        let lineEnd = CGPoint(x: b.maxX - 4, y: b.midY)

        jointLayer.path = jointPath.cgPath
        jointLayer.position = jointCenter
        jointLayer.fillColor = jointFill.cgColor
        jointLayer.strokeColor = jointStroke.cgColor
        jointLayer.lineWidth = max(1, 2 * scale * outlineScale)
        let jointGlow = min(1, max(0, dotsGlow))
        if jointGlow > 0 {
            jointLayer.shadowColor = (jointStroke.cgColor)
            jointLayer.shadowOffset = .zero
            jointLayer.shadowRadius = jointRad * 0.8 * jointGlow * (1 + softness)
            jointLayer.shadowOpacity = Float(0.6 * jointGlow)
        } else {
            jointLayer.shadowRadius = 0
            jointLayer.shadowOpacity = 0
        }

        if connectionStyle != .none {
            let path = UIBezierPath()
            path.move(to: lineStart)
            path.addLine(to: lineEnd)
            limbLayer.path = path.cgPath
            limbLayer.fillColor = nil
            limbLayer.strokeColor = limbStroke.cgColor
            limbLayer.lineWidth = max(1, params.limbLineWidth * 0.4 * scale * lineWidthScale * outlineScale)
            limbLayer.isHidden = false
            let connGlow = min(1, max(0, connectionsGlow))
            if connGlow > 0 {
                limbLayer.shadowColor = limbStroke.cgColor
                limbLayer.shadowOffset = .zero
                limbLayer.shadowRadius = params.limbLineWidth * 0.3 * connGlow * (1 + softness)
                limbLayer.shadowOpacity = Float(0.7 * connGlow)
            } else {
                limbLayer.shadowRadius = 0
                limbLayer.shadowOpacity = 0
            }
            switch connectionStyle {
            case .dotted:
                limbLayer.lineDashPattern = [2, 3] as [NSNumber]
                limbLayer.lineCap = .round
                limbLayer.lineJoin = .miter
            case .dashed:
                limbLayer.lineDashPattern = [4, 3] as [NSNumber]
                limbLayer.lineCap = .butt
                limbLayer.lineJoin = .miter
            case .longDashed:
                limbLayer.lineDashPattern = [12, 6] as [NSNumber]
                limbLayer.lineCap = .butt
                limbLayer.lineJoin = .miter
            case .thinDots:
                limbLayer.lineDashPattern = [1, 3] as [NSNumber]
                limbLayer.lineCap = .round
                limbLayer.lineJoin = .miter
            case .dotDashed:
                limbLayer.lineDashPattern = [2, 2, 8, 2] as [NSNumber]
                limbLayer.lineCap = .round
                limbLayer.lineJoin = .miter
            case .rounded:
                limbLayer.lineDashPattern = nil
                limbLayer.lineCap = .round
                limbLayer.lineJoin = .round
            case .solid, .none:
                limbLayer.lineDashPattern = nil
                limbLayer.lineCap = .butt
                limbLayer.lineJoin = .miter
            }
        } else {
            limbLayer.isHidden = true
        }
    }
}
