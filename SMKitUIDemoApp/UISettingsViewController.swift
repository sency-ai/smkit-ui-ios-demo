//
//  UISettingsViewController.swift
//  SMKitUIDemoApp
//

import UIKit
import SMKitUI

final class UISettingsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let rowHeight: CGFloat = 44
    private let sectionHeaderHeight: CGFloat = 32
    private let previewWidth: CGFloat = 52
    private let previewHeight: CGFloat = 28
    private let colorChipSize: CGFloat = 36

    private var skeletonHiddenSwitch: UISwitch!
    private var presetRows: [(view: UIView, preset: SMKitUI.SkeletonPreset)] = []
    private var connectionRows: [(view: UIView, style: SMKitUI.SkeletonConnectionStyle)] = []
    private var jointShapeRows: [(view: UIView, shape: SMKitUI.SkeletonJointShape)] = []
    private var dotsOpacitySlider: UISlider!
    private var connectionsOpacitySlider: UISlider!
    private var dotsGlowSlider: UISlider!
    private var connectionsGlowSlider: UISlider!
    private var lineWidthScaleSlider: UISlider!
    private var outlineScaleSlider: UISlider!
    private var softnessSlider: UISlider!
    private var dotsInnerChips: [UIView] = []
    private var dotsOuterChips: [UIView] = []
    private var connectionsInnerChips: [UIView] = []
    private var connectionsOuterChips: [UIView] = []
    private var livePreview: SkeletonStylePreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UI Settings"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        contentStack.axis = .vertical
        contentStack.spacing = 4
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
        ])

        addLivePreview()
        addSkeletonHiddenToggle()
        addSectionHeader("Dots (preset)")
        addPresetRows()
        addSectionHeader("Connections (style)")
        addConnectionRows()
        addSectionHeader("Joint shape")
        addJointShapeRows()
        addSectionHeader("Dots glow")
        addDotsGlowRow()
        addSectionHeader("Connections glow")
        addConnectionsGlowRow()
        addSectionHeader("Line width scale")
        addLineWidthScaleRow()
        addSectionHeader("Outline scale")
        addOutlineScaleRow()
        addSectionHeader("Softness")
        addSoftnessRow()
        addSectionHeader("Dots opacity")
        addDotsOpacityRow()
        addSectionHeader("Dots inner color")
        addColorChipsRow(isDotsInner: true)
        addSectionHeader("Dots outer color")
        addColorChipsRow(isDotsOuter: true)
        addSectionHeader("Connections opacity")
        addConnectionsOpacityRow()
        addSectionHeader("Connections inner color")
        addColorChipsRow(isConnectionsInner: true)
        addSectionHeader("Connections outer color")
        addColorChipsRow(isConnectionsOuter: true)
        addSessionBehaviorSection()

        refreshSelection()
    }

    private func addSkeletonHiddenToggle() {
        let row = UIView()
        let lab = UILabel()
        lab.text = "Hide skeleton"
        lab.font = .systemFont(ofSize: 15, weight: .semibold)
        lab.translatesAutoresizingMaskIntoConstraints = false
        skeletonHiddenSwitch = UISwitch()
        skeletonHiddenSwitch.isOn = SMKitUIModel.skeletonHidden
        skeletonHiddenSwitch.translatesAutoresizingMaskIntoConstraints = false
        skeletonHiddenSwitch.addTarget(self, action: #selector(skeletonHiddenChanged(_:)), for: .valueChanged)
        row.addSubview(lab)
        row.addSubview(skeletonHiddenSwitch)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 44),
            lab.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            skeletonHiddenSwitch.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            skeletonHiddenSwitch.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(16, after: row)
    }

    private func addLivePreview() {
        let label = UILabel()
        label.text = "Preview"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        contentStack.addArrangedSubview(label)
        livePreview = SkeletonStylePreviewView()
        livePreview.translatesAutoresizingMaskIntoConstraints = false
        livePreview.backgroundColor = UIColor.systemGray6
        livePreview.layer.cornerRadius = 8
        contentStack.addArrangedSubview(livePreview)
        NSLayoutConstraint.activate([
            livePreview.heightAnchor.constraint(equalToConstant: 56),
        ])
        contentStack.setCustomSpacing(20, after: livePreview)
    }

    private func addSectionHeader(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        contentStack.addArrangedSubview(label)
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: sectionHeaderHeight),
        ])
    }

    private func addPresetRows() {
        let presets: [SMKitUI.SkeletonPreset] = [
            .default, .minimalDots, .thinOutline, .monochromeClean, .neonGlow, .boldHighlight,
            .softFill, .wireframe, .highContrast, .pastel, .darkOutline, .minimalLine,
            .doubleStroke, .gradientReady, .subtleShadow, .classic,
            .athletic, .premium, .hologram, .matte, .neonPulse, .outlineOnly, .slim, .thick, .studio, .accessibility
        ]
        for preset in presets {
            let row = makeRow(
                preset: preset,
                connectionStyle: SMKitUIModel.skeletonConnectionStyle,
                label: Self.presetDisplayName(preset),
                tag: presets.firstIndex(of: preset) ?? 0
            )
            let tap = UITapGestureRecognizer(target: self, action: #selector(presetRowTapped(_:)))
            row.addGestureRecognizer(tap)
            row.isUserInteractionEnabled = true
            contentStack.addArrangedSubview(row)
            NSLayoutConstraint.activate([row.heightAnchor.constraint(equalToConstant: rowHeight)])
            presetRows.append((row, preset))
        }
        contentStack.setCustomSpacing(16, after: contentStack.arrangedSubviews.last!)
    }

    private func addConnectionRows() {
        let styles: [SMKitUI.SkeletonConnectionStyle] = [.none, .dotted, .dashed, .solid, .longDashed, .thinDots, .dotDashed, .rounded]
        for style in styles {
            let row = makeRow(
                preset: SMKitUIModel.skeletonPreset,
                connectionStyle: style,
                label: Self.connectionStyleDisplayName(style),
                tag: styles.firstIndex(of: style) ?? 0
            )
            let tap = UITapGestureRecognizer(target: self, action: #selector(connectionRowTapped(_:)))
            row.addGestureRecognizer(tap)
            row.isUserInteractionEnabled = true
            contentStack.addArrangedSubview(row)
            NSLayoutConstraint.activate([row.heightAnchor.constraint(equalToConstant: rowHeight)])
            connectionRows.append((row, style))
        }
        contentStack.setCustomSpacing(16, after: contentStack.arrangedSubviews.last!)
    }

    private func addJointShapeRows() {
        let shapes: [SMKitUI.SkeletonJointShape] = [.circle, .square, .triangle, .diamond, .star, .hexagon]
        for (idx, shape) in shapes.enumerated() {
            let row = makeRow(
                preset: SMKitUIModel.skeletonPreset,
                connectionStyle: SMKitUIModel.skeletonConnectionStyle,
                label: SMKitUI.SkeletonJointShape.displayName(for: shape),
                tag: idx,
                jointShape: shape
            )
            let tap = UITapGestureRecognizer(target: self, action: #selector(jointShapeRowTapped(_:)))
            row.addGestureRecognizer(tap)
            row.isUserInteractionEnabled = true
            contentStack.addArrangedSubview(row)
            NSLayoutConstraint.activate([row.heightAnchor.constraint(equalToConstant: rowHeight)])
            jointShapeRows.append((row, shape))
        }
        contentStack.setCustomSpacing(16, after: contentStack.arrangedSubviews.last!)
    }

    private func makeRow(preset: SMKitUI.SkeletonPreset, connectionStyle: SMKitUI.SkeletonConnectionStyle, label: String, tag: Int, jointShape: SMKitUI.SkeletonJointShape? = nil) -> UIView {
        let row = UIView()
        row.tag = tag
        let preview = SkeletonStylePreviewView()
        preview.preset = preset
        preview.connectionStyle = connectionStyle
        preview.jointShape = jointShape ?? SMKitUIModel.skeletonJointShape
        preview.dotsOpacity = SMKitUIModel.skeletonDotsOpacity
        preview.connectionsOpacity = SMKitUIModel.skeletonConnectionsOpacity
        preview.dotsInnerColorOption = SMKitUIModel.skeletonDotsInnerColorOption
        preview.dotsOuterColorOption = SMKitUIModel.skeletonDotsOuterColorOption
        preview.connectionsInnerColorOption = SMKitUIModel.skeletonConnectionsInnerColorOption
        preview.connectionsOuterColorOption = SMKitUIModel.skeletonConnectionsOuterColorOption
        preview.dotsGlow = SMKitUIModel.skeletonDotsGlow
        preview.connectionsGlow = SMKitUIModel.skeletonConnectionsGlow
        preview.lineWidthScale = SMKitUIModel.skeletonLineWidthScale
        preview.outlineScale = SMKitUIModel.skeletonOutlineScale
        preview.softness = SMKitUIModel.skeletonSoftness
        preview.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(preview)
        let lab = UILabel()
        lab.text = label
        lab.font = .systemFont(ofSize: 15)
        lab.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(lab)
        NSLayoutConstraint.activate([
            preview.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            preview.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            preview.widthAnchor.constraint(equalToConstant: previewWidth),
            preview.heightAnchor.constraint(equalToConstant: previewHeight),
            lab.leadingAnchor.constraint(equalTo: preview.trailingAnchor, constant: 12),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    private func addDotsOpacityRow() {
        let row = UIView()
        let lab = UILabel()
        lab.text = "0 — 1"
        lab.font = .systemFont(ofSize: 13)
        lab.translatesAutoresizingMaskIntoConstraints = false
        dotsOpacitySlider = UISlider()
        dotsOpacitySlider.minimumValue = 0
        dotsOpacitySlider.maximumValue = 1
        dotsOpacitySlider.value = Float(SMKitUIModel.skeletonDotsOpacity)
        dotsOpacitySlider.translatesAutoresizingMaskIntoConstraints = false
        dotsOpacitySlider.addTarget(self, action: #selector(dotsOpacityChanged(_:)), for: .valueChanged)
        row.addSubview(lab)
        row.addSubview(dotsOpacitySlider)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: rowHeight),
            lab.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dotsOpacitySlider.leadingAnchor.constraint(equalTo: lab.trailingAnchor, constant: 12),
            dotsOpacitySlider.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            dotsOpacitySlider.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(12, after: row)
    }

    private func addDotsGlowRow() {
        let row = UIView()
        let lab = UILabel()
        lab.text = "0 — 1"
        lab.font = .systemFont(ofSize: 13)
        lab.translatesAutoresizingMaskIntoConstraints = false
        dotsGlowSlider = UISlider()
        dotsGlowSlider.minimumValue = 0
        dotsGlowSlider.maximumValue = 1
        dotsGlowSlider.value = Float(SMKitUIModel.skeletonDotsGlow)
        dotsGlowSlider.translatesAutoresizingMaskIntoConstraints = false
        dotsGlowSlider.addTarget(self, action: #selector(dotsGlowChanged(_:)), for: .valueChanged)
        row.addSubview(lab)
        row.addSubview(dotsGlowSlider)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: rowHeight),
            lab.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dotsGlowSlider.leadingAnchor.constraint(equalTo: lab.trailingAnchor, constant: 12),
            dotsGlowSlider.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            dotsGlowSlider.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(12, after: row)
    }

    private func addConnectionsGlowRow() {
        let row = UIView()
        let lab = UILabel()
        lab.text = "0 — 1"
        lab.font = .systemFont(ofSize: 13)
        lab.translatesAutoresizingMaskIntoConstraints = false
        connectionsGlowSlider = UISlider()
        connectionsGlowSlider.minimumValue = 0
        connectionsGlowSlider.maximumValue = 1
        connectionsGlowSlider.value = Float(SMKitUIModel.skeletonConnectionsGlow)
        connectionsGlowSlider.translatesAutoresizingMaskIntoConstraints = false
        connectionsGlowSlider.addTarget(self, action: #selector(connectionsGlowChanged(_:)), for: .valueChanged)
        row.addSubview(lab)
        row.addSubview(connectionsGlowSlider)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: rowHeight),
            lab.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            connectionsGlowSlider.leadingAnchor.constraint(equalTo: lab.trailingAnchor, constant: 12),
            connectionsGlowSlider.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            connectionsGlowSlider.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(12, after: row)
    }

    private func addLineWidthScaleRow() {
        let row = UIView()
        let lab = UILabel()
        lab.text = "0.5 — 2"
        lab.font = .systemFont(ofSize: 13)
        lab.translatesAutoresizingMaskIntoConstraints = false
        lineWidthScaleSlider = UISlider()
        lineWidthScaleSlider.minimumValue = 0.5
        lineWidthScaleSlider.maximumValue = 2
        lineWidthScaleSlider.value = Float(SMKitUIModel.skeletonLineWidthScale)
        lineWidthScaleSlider.translatesAutoresizingMaskIntoConstraints = false
        lineWidthScaleSlider.addTarget(self, action: #selector(lineWidthScaleChanged(_:)), for: .valueChanged)
        row.addSubview(lab)
        row.addSubview(lineWidthScaleSlider)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: rowHeight),
            lab.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            lineWidthScaleSlider.leadingAnchor.constraint(equalTo: lab.trailingAnchor, constant: 12),
            lineWidthScaleSlider.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            lineWidthScaleSlider.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(12, after: row)
    }

    private func addOutlineScaleRow() {
        let row = UIView()
        let lab = UILabel()
        lab.text = "0.5 — 2"
        lab.font = .systemFont(ofSize: 13)
        lab.translatesAutoresizingMaskIntoConstraints = false
        outlineScaleSlider = UISlider()
        outlineScaleSlider.minimumValue = 0.5
        outlineScaleSlider.maximumValue = 2
        outlineScaleSlider.value = Float(SMKitUIModel.skeletonOutlineScale)
        outlineScaleSlider.translatesAutoresizingMaskIntoConstraints = false
        outlineScaleSlider.addTarget(self, action: #selector(outlineScaleChanged(_:)), for: .valueChanged)
        row.addSubview(lab)
        row.addSubview(outlineScaleSlider)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: rowHeight),
            lab.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            outlineScaleSlider.leadingAnchor.constraint(equalTo: lab.trailingAnchor, constant: 12),
            outlineScaleSlider.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            outlineScaleSlider.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(12, after: row)
    }

    private func addSoftnessRow() {
        let row = UIView()
        let lab = UILabel()
        lab.text = "0 — 1"
        lab.font = .systemFont(ofSize: 13)
        lab.translatesAutoresizingMaskIntoConstraints = false
        softnessSlider = UISlider()
        softnessSlider.minimumValue = 0
        softnessSlider.maximumValue = 1
        softnessSlider.value = Float(SMKitUIModel.skeletonSoftness)
        softnessSlider.translatesAutoresizingMaskIntoConstraints = false
        softnessSlider.addTarget(self, action: #selector(softnessChanged(_:)), for: .valueChanged)
        row.addSubview(lab)
        row.addSubview(softnessSlider)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: rowHeight),
            lab.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            softnessSlider.leadingAnchor.constraint(equalTo: lab.trailingAnchor, constant: 12),
            softnessSlider.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            softnessSlider.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(12, after: row)
    }

    private func addConnectionsOpacityRow() {
        let row = UIView()
        let lab = UILabel()
        lab.text = "0 — 1"
        lab.font = .systemFont(ofSize: 13)
        lab.translatesAutoresizingMaskIntoConstraints = false
        connectionsOpacitySlider = UISlider()
        connectionsOpacitySlider.minimumValue = 0
        connectionsOpacitySlider.maximumValue = 1
        connectionsOpacitySlider.value = Float(SMKitUIModel.skeletonConnectionsOpacity)
        connectionsOpacitySlider.translatesAutoresizingMaskIntoConstraints = false
        connectionsOpacitySlider.addTarget(self, action: #selector(connectionsOpacityChanged(_:)), for: .valueChanged)
        row.addSubview(lab)
        row.addSubview(connectionsOpacitySlider)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: rowHeight),
            lab.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            connectionsOpacitySlider.leadingAnchor.constraint(equalTo: lab.trailingAnchor, constant: 12),
            connectionsOpacitySlider.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            connectionsOpacitySlider.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(12, after: row)
    }

    private func addColorChipsRow(isDotsInner: Bool = false, isDotsOuter: Bool = false, isConnectionsInner: Bool = false, isConnectionsOuter: Bool = false) {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        let chipCount = SkeletonColorOption.allCases.count + 1
        for tag in 0..<chipCount {
            let chip = makeColorChip(tag: tag)
            if isDotsInner {
                let t = UITapGestureRecognizer(target: self, action: #selector(dotsInnerChipTapped(_:)))
                chip.addGestureRecognizer(t)
                dotsInnerChips.append(chip)
            } else if isDotsOuter {
                let t = UITapGestureRecognizer(target: self, action: #selector(dotsOuterChipTapped(_:)))
                chip.addGestureRecognizer(t)
                dotsOuterChips.append(chip)
            } else if isConnectionsInner {
                let t = UITapGestureRecognizer(target: self, action: #selector(connectionsInnerChipTapped(_:)))
                chip.addGestureRecognizer(t)
                connectionsInnerChips.append(chip)
            } else if isConnectionsOuter {
                let t = UITapGestureRecognizer(target: self, action: #selector(connectionsOuterChipTapped(_:)))
                chip.addGestureRecognizer(t)
                connectionsOuterChips.append(chip)
            }
            chip.isUserInteractionEnabled = true
            chip.tag = tag
            stack.addArrangedSubview(chip)
        }
        let row = UIView()
        let horizontalScroll = UIScrollView()
        horizontalScroll.showsHorizontalScrollIndicator = true
        horizontalScroll.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(horizontalScroll)
        horizontalScroll.addSubview(stack)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: colorChipSize + 8),
            horizontalScroll.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            horizontalScroll.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            horizontalScroll.topAnchor.constraint(equalTo: row.topAnchor),
            horizontalScroll.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: horizontalScroll.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: horizontalScroll.contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: horizontalScroll.contentLayoutGuide.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: horizontalScroll.contentLayoutGuide.bottomAnchor, constant: -4),
            stack.heightAnchor.constraint(equalToConstant: colorChipSize),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(12, after: row)
    }

    private func makeColorChip(tag: Int) -> UIView {
        let isPreset = (tag == 0)
        let color: UIColor? = isPreset ? nil : SkeletonColorOption(rawValue: tag - 1)?.uiColor
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.tag = tag
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = colorChipSize / 2
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor.separator.cgColor
        if isPreset {
            circle.backgroundColor = .systemGray5
            let lab = UILabel()
            lab.text = "P"
            lab.font = .systemFont(ofSize: 12, weight: .bold)
            lab.textColor = .secondaryLabel
            lab.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(circle)
            container.addSubview(lab)
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: colorChipSize),
                circle.heightAnchor.constraint(equalToConstant: colorChipSize),
                lab.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                lab.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            ])
        } else {
            circle.backgroundColor = color ?? .gray
            container.addSubview(circle)
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: colorChipSize),
                circle.heightAnchor.constraint(equalToConstant: colorChipSize),
            ])
        }
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: colorChipSize),
            container.heightAnchor.constraint(equalToConstant: colorChipSize),
            circle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
        return container
    }

    private func refreshSelection() {
        let preset = SMKitUIModel.skeletonPreset
        let connection = SMKitUIModel.skeletonConnectionStyle
        presetRows.forEach { row, p in
            row.backgroundColor = (p == preset) ? UIColor.systemBlue.withAlphaComponent(0.2) : .clear
        }
        connectionRows.forEach { row, s in
            row.backgroundColor = (s == connection) ? UIColor.systemBlue.withAlphaComponent(0.2) : .clear
        }
        let currentJointShape = SMKitUIModel.skeletonJointShape
        jointShapeRows.forEach { row, shape in
            row.backgroundColor = (shape == currentJointShape) ? UIColor.systemBlue.withAlphaComponent(0.2) : .clear
        }
        dotsOpacitySlider?.value = Float(SMKitUIModel.skeletonDotsOpacity)
        connectionsOpacitySlider?.value = Float(SMKitUIModel.skeletonConnectionsOpacity)
        dotsGlowSlider?.value = Float(SMKitUIModel.skeletonDotsGlow)
        connectionsGlowSlider?.value = Float(SMKitUIModel.skeletonConnectionsGlow)
        lineWidthScaleSlider?.value = Float(SMKitUIModel.skeletonLineWidthScale)
        outlineScaleSlider?.value = Float(SMKitUIModel.skeletonOutlineScale)
        softnessSlider?.value = Float(SMKitUIModel.skeletonSoftness)
        updateChipBorders(dotsInnerChips, selected: SMKitUIModel.skeletonDotsInnerColorOption == nil ? 0 : SMKitUIModel.skeletonDotsInnerColorOption!.rawValue + 1)
        updateChipBorders(dotsOuterChips, selected: SMKitUIModel.skeletonDotsOuterColorOption == nil ? 0 : SMKitUIModel.skeletonDotsOuterColorOption!.rawValue + 1)
        updateChipBorders(connectionsInnerChips, selected: SMKitUIModel.skeletonConnectionsInnerColorOption == nil ? 0 : SMKitUIModel.skeletonConnectionsInnerColorOption!.rawValue + 1)
        updateChipBorders(connectionsOuterChips, selected: SMKitUIModel.skeletonConnectionsOuterColorOption == nil ? 0 : SMKitUIModel.skeletonConnectionsOuterColorOption!.rawValue + 1)
        updateLivePreview()
        presetRows.forEach { row, _ in
            let pv = row.subviews.compactMap { $0 as? SkeletonStylePreviewView }.first
            pv?.jointShape = SMKitUIModel.skeletonJointShape
            pv?.dotsOpacity = SMKitUIModel.skeletonDotsOpacity
            pv?.connectionsOpacity = SMKitUIModel.skeletonConnectionsOpacity
            pv?.dotsInnerColorOption = SMKitUIModel.skeletonDotsInnerColorOption
            pv?.dotsOuterColorOption = SMKitUIModel.skeletonDotsOuterColorOption
            pv?.connectionsInnerColorOption = SMKitUIModel.skeletonConnectionsInnerColorOption
            pv?.connectionsOuterColorOption = SMKitUIModel.skeletonConnectionsOuterColorOption
            pv?.dotsGlow = SMKitUIModel.skeletonDotsGlow
            pv?.connectionsGlow = SMKitUIModel.skeletonConnectionsGlow
            pv?.lineWidthScale = SMKitUIModel.skeletonLineWidthScale
            pv?.outlineScale = SMKitUIModel.skeletonOutlineScale
            pv?.softness = SMKitUIModel.skeletonSoftness
        }
        connectionRows.forEach { row, _ in
            let pv = row.subviews.compactMap { $0 as? SkeletonStylePreviewView }.first
            pv?.jointShape = SMKitUIModel.skeletonJointShape
            pv?.dotsOpacity = SMKitUIModel.skeletonDotsOpacity
            pv?.connectionsOpacity = SMKitUIModel.skeletonConnectionsOpacity
            pv?.dotsInnerColorOption = SMKitUIModel.skeletonDotsInnerColorOption
            pv?.dotsOuterColorOption = SMKitUIModel.skeletonDotsOuterColorOption
            pv?.connectionsInnerColorOption = SMKitUIModel.skeletonConnectionsInnerColorOption
            pv?.connectionsOuterColorOption = SMKitUIModel.skeletonConnectionsOuterColorOption
            pv?.dotsGlow = SMKitUIModel.skeletonDotsGlow
            pv?.connectionsGlow = SMKitUIModel.skeletonConnectionsGlow
            pv?.lineWidthScale = SMKitUIModel.skeletonLineWidthScale
            pv?.outlineScale = SMKitUIModel.skeletonOutlineScale
            pv?.softness = SMKitUIModel.skeletonSoftness
        }
        jointShapeRows.forEach { row, shape in
            let pv = row.subviews.compactMap { $0 as? SkeletonStylePreviewView }.first
            pv?.jointShape = shape
            pv?.dotsOpacity = SMKitUIModel.skeletonDotsOpacity
            pv?.connectionsOpacity = SMKitUIModel.skeletonConnectionsOpacity
            pv?.dotsInnerColorOption = SMKitUIModel.skeletonDotsInnerColorOption
            pv?.dotsOuterColorOption = SMKitUIModel.skeletonDotsOuterColorOption
            pv?.connectionsInnerColorOption = SMKitUIModel.skeletonConnectionsInnerColorOption
            pv?.connectionsOuterColorOption = SMKitUIModel.skeletonConnectionsOuterColorOption
            pv?.dotsGlow = SMKitUIModel.skeletonDotsGlow
            pv?.connectionsGlow = SMKitUIModel.skeletonConnectionsGlow
            pv?.lineWidthScale = SMKitUIModel.skeletonLineWidthScale
            pv?.outlineScale = SMKitUIModel.skeletonOutlineScale
            pv?.softness = SMKitUIModel.skeletonSoftness
        }
    }

    private func updateChipBorders(_ chips: [UIView], selected: Int) {
        chips.enumerated().forEach { idx, container in
            let circle = container.subviews.first
            circle?.layer.borderWidth = (idx == selected) ? 3 : 2
            circle?.layer.borderColor = (idx == selected) ? UIColor.systemBlue.cgColor : UIColor.separator.cgColor
        }
    }

    private func updateLivePreview() {
        livePreview?.preset = SMKitUIModel.skeletonPreset
        livePreview?.connectionStyle = SMKitUIModel.skeletonConnectionStyle
        livePreview?.dotsOpacity = SMKitUIModel.skeletonDotsOpacity
        livePreview?.connectionsOpacity = SMKitUIModel.skeletonConnectionsOpacity
        livePreview?.dotsInnerColorOption = SMKitUIModel.skeletonDotsInnerColorOption
        livePreview?.dotsOuterColorOption = SMKitUIModel.skeletonDotsOuterColorOption
        livePreview?.connectionsInnerColorOption = SMKitUIModel.skeletonConnectionsInnerColorOption
        livePreview?.connectionsOuterColorOption = SMKitUIModel.skeletonConnectionsOuterColorOption
        livePreview?.dotsGlow = SMKitUIModel.skeletonDotsGlow
        livePreview?.connectionsGlow = SMKitUIModel.skeletonConnectionsGlow
        livePreview?.lineWidthScale = SMKitUIModel.skeletonLineWidthScale
        livePreview?.outlineScale = SMKitUIModel.skeletonOutlineScale
        livePreview?.softness = SMKitUIModel.skeletonSoftness
        livePreview?.jointShape = SMKitUIModel.skeletonJointShape
    }

    private static func presetDisplayName(_ p: SMKitUI.SkeletonPreset) -> String {
        switch p {
        case .default: return "Default"
        case .minimalDots: return "Minimal Dots"
        case .thinOutline: return "Thin Outline"
        case .monochromeClean: return "Monochrome Clean"
        case .neonGlow: return "Neon Glow"
        case .boldHighlight: return "Bold Highlight"
        case .softFill: return "Soft Fill"
        case .wireframe: return "Wireframe"
        case .highContrast: return "High Contrast"
        case .pastel: return "Pastel"
        case .darkOutline: return "Dark Outline"
        case .minimalLine: return "Minimal Line"
        case .doubleStroke: return "Double Stroke"
        case .gradientReady: return "Gradient Ready"
        case .subtleShadow: return "Subtle Shadow"
        case .classic: return "Classic"
        case .athletic: return "Athletic"
        case .premium: return "Premium"
        case .hologram: return "Hologram"
        case .matte: return "Matte"
        case .neonPulse: return "Neon Pulse"
        case .outlineOnly: return "Outline Only"
        case .slim: return "Slim"
        case .thick: return "Thick"
        case .studio: return "Studio"
        case .accessibility: return "Accessibility"
        }
    }

    private static func connectionStyleDisplayName(_ s: SMKitUI.SkeletonConnectionStyle) -> String {
        switch s {
        case .none: return "None"
        case .dotted: return "Dotted"
        case .dashed: return "Dashed"
        case .solid: return "Solid"
        case .longDashed: return "Long Dashed"
        case .thinDots: return "Thin Dots"
        case .dotDashed: return "Dot Dashed"
        case .rounded: return "Rounded"
        }
    }

    @objc private func skeletonHiddenChanged(_ sender: UISwitch) {
        SMKitUIModel.skeletonHidden = sender.isOn
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }

    @objc private func presetRowTapped(_ g: UITapGestureRecognizer) {
        guard let row = g.view, let idx = presetRows.firstIndex(where: { $0.view === row }) else { return }
        SMKitUIModel.skeletonPreset = presetRows[idx].preset
        refreshSelection()
    }

    @objc private func connectionRowTapped(_ g: UITapGestureRecognizer) {
        guard let row = g.view, let idx = connectionRows.firstIndex(where: { $0.view === row }) else { return }
        SMKitUIModel.skeletonConnectionStyle = connectionRows[idx].style
        refreshSelection()
    }

    @objc private func jointShapeRowTapped(_ g: UITapGestureRecognizer) {
        guard let row = g.view, let idx = jointShapeRows.firstIndex(where: { $0.view === row }) else { return }
        SMKitUIModel.skeletonJointShape = jointShapeRows[idx].shape
        refreshSelection()
    }

    @objc private func dotsOpacityChanged(_ sender: UISlider) {
        SMKitUIModel.skeletonDotsOpacity = CGFloat(sender.value)
        refreshSelection()
    }

    @objc private func connectionsOpacityChanged(_ sender: UISlider) {
        SMKitUIModel.skeletonConnectionsOpacity = CGFloat(sender.value)
        refreshSelection()
    }

    @objc private func dotsGlowChanged(_ sender: UISlider) {
        SMKitUIModel.skeletonDotsGlow = CGFloat(sender.value)
        refreshSelection()
    }

    @objc private func connectionsGlowChanged(_ sender: UISlider) {
        SMKitUIModel.skeletonConnectionsGlow = CGFloat(sender.value)
        refreshSelection()
    }

    @objc private func lineWidthScaleChanged(_ sender: UISlider) {
        SMKitUIModel.skeletonLineWidthScale = CGFloat(sender.value)
        refreshSelection()
    }

    @objc private func outlineScaleChanged(_ sender: UISlider) {
        SMKitUIModel.skeletonOutlineScale = CGFloat(sender.value)
        refreshSelection()
    }

    @objc private func softnessChanged(_ sender: UISlider) {
        SMKitUIModel.skeletonSoftness = CGFloat(sender.value)
        refreshSelection()
    }

    @objc private func dotsInnerChipTapped(_ g: UITapGestureRecognizer) {
        guard let v = g.view else { return }
        SMKitUIModel.skeletonDotsInnerColorOption = (v.tag == 0) ? nil : SkeletonColorOption(rawValue: v.tag - 1)
        refreshSelection()
    }

    @objc private func dotsOuterChipTapped(_ g: UITapGestureRecognizer) {
        guard let v = g.view else { return }
        SMKitUIModel.skeletonDotsOuterColorOption = (v.tag == 0) ? nil : SkeletonColorOption(rawValue: v.tag - 1)
        refreshSelection()
    }

    @objc private func connectionsInnerChipTapped(_ g: UITapGestureRecognizer) {
        guard let v = g.view else { return }
        SMKitUIModel.skeletonConnectionsInnerColorOption = (v.tag == 0) ? nil : SkeletonColorOption(rawValue: v.tag - 1)
        refreshSelection()
    }

    @objc private func connectionsOuterChipTapped(_ g: UITapGestureRecognizer) {
        guard let v = g.view else { return }
        SMKitUIModel.skeletonConnectionsOuterColorOption = (v.tag == 0) ? nil : SkeletonColorOption(rawValue: v.tag - 1)
        refreshSelection()
    }

    private func addSessionBehaviorSection() {
        addSectionHeader("Session behavior")
        addToggleRow(title: "Play phone calibration audio",
                     isOn: SMKitUIModel.playPhoneCalibrationAudio,
                     selector: #selector(playPhoneCalibrationAudioChanged(_:)))
        addToggleRow(title: "Play body calibration audio",
                     isOn: SMKitUIModel.playBodyCalibrationAudio,
                     selector: #selector(playBodyCalibrationAudioChanged(_:)))
        addToggleRow(title: "Start timer on first activity",
                     isOn: SMKitUIModel.startTimerOnFirstActivity,
                     selector: #selector(startTimerOnFirstActivityChanged(_:)))
        addToggleRow(title: "Prevent rep count while phone moves",
                     isOn: SMKitUIModel.enablePhoneMovementCountPrevention,
                     selector: #selector(enablePhoneMovementCountPreventionChanged(_:)))
    }

    private func addToggleRow(title: String, isOn: Bool, selector: Selector) {
        let row = UIView()
        let lab = UILabel()
        lab.text = title
        lab.font = .systemFont(ofSize: 15, weight: .semibold)
        lab.translatesAutoresizingMaskIntoConstraints = false
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: selector, for: .valueChanged)
        row.addSubview(lab)
        row.addSubview(toggle)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: rowHeight),
            lab.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lab.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            lab.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -12),
            toggle.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(12, after: row)
    }

    @objc private func playPhoneCalibrationAudioChanged(_ sender: UISwitch) {
        SMKitUIModel.playPhoneCalibrationAudio = sender.isOn
    }

    @objc private func playBodyCalibrationAudioChanged(_ sender: UISwitch) {
        SMKitUIModel.playBodyCalibrationAudio = sender.isOn
    }

    @objc private func startTimerOnFirstActivityChanged(_ sender: UISwitch) {
        SMKitUIModel.startTimerOnFirstActivity = sender.isOn
    }

    @objc private func enablePhoneMovementCountPreventionChanged(_ sender: UISwitch) {
        SMKitUIModel.enablePhoneMovementCountPrevention = sender.isOn
    }
}
