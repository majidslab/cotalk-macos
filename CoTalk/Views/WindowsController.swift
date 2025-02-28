//
//  WindowsController.swift
//
//  Created by Majid Jamali with ❤️ on 2/27/25.
//
//

import Cocoa
import AVFoundation
import Combine

final class MainWindowController: NSWindowController {
    
    internal var visualEffect: NSVisualEffectView = {
        let visualEffect = NSVisualEffectView()
        visualEffect.material = .windowBackground
        visualEffect.blendingMode = .withinWindow
        visualEffect.state = .followsWindowActiveState
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 12.0
        visualEffect.layer?.allowsGroupOpacity = true
        visualEffect.layer?.opacity = 0.9
        return visualEffect
    }()
    
    internal var statusTextView: NSTextField = {
        let statusTextView = NSTextField()
        statusTextView.backgroundColor = .clear
        statusTextView.isEditable = false
        statusTextView.maximumNumberOfLines = 1
        statusTextView.isBezeled = false
        statusTextView.isBordered = false
        statusTextView.isSelectable = false
        statusTextView.isAutomaticTextCompletionEnabled = false
        statusTextView.font = .systemFont(ofSize: 14.0, weight: .regular)
        statusTextView.textColor = .color2
        statusTextView.drawsBackground = false
        statusTextView.alphaValue = 0.4
        statusTextView.stringValue = "Click to Start"
        statusTextView.alignment = .center
        return statusTextView
    }()
    
    internal var siriAnimation: SwiftSiriWaveformView = {
        let siriAnimation = SwiftSiriWaveformView()
        siriAnimation.amplitude = 0.0
        siriAnimation.idleAmplitude = 0.0
        siriAnimation.waveColor = .cyan
        siriAnimation.density = 5.25
        return siriAnimation
    }()
    
    internal var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.documentView?.backgroundFilters = []
        scrollView.layer?.backgroundColor = CGColor.clear
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = true
        scrollView.horizontalScroller?.isHidden = true
        scrollView.scrollsDynamically = false
        scrollView.contentView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        scrollView.drawsBackground = false
        scrollView.scrollerInsets = NSEdgeInsets()
        scrollView.borderType = .noBorder
        scrollView.horizontalScroller?.alphaValue = 0.0
        scrollView.horizontalScroller?.frame = .zero
        return scrollView
    }()
    
    internal var scrollStackView: NSStackView = {
        let scrollStackView = NSStackView()
        scrollStackView.orientation = .horizontal
        scrollStackView.alignment = .centerY
        scrollStackView.edgeInsets = NSEdgeInsets()
        return scrollStackView
    }()
    
    internal var transcribtionLabelView: GradientMaskTextField = {
        let label = GradientMaskTextField()
        label.backgroundColor = .clear
        label.isEditable = false
        label.maximumNumberOfLines = 1
        label.isBezeled = false
        label.isBordered = false
        label.isSelectable = false
        label.isAutomaticTextCompletionEnabled = false
        label.font = .systemFont(ofSize: 24.0, weight: .black)
        label.textColor = .clear
        label.drawsBackground = false
        label.alphaValue = 0.4
        return label
    }()
    
    private var time = Timer.publish(every: 6.0 / 60.0, on: .main, in: .common)
    private var cancellables = Set<AnyCancellable>()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        setupWindow()
        addingConstraints()
        setupUtils()
        TranscribingLoop()
    }
    
    func TranscribingLoop() {
        
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        time.autoconnect().sink { [weak self] t in
            if delegate.speechRecognizer.isTranscribing {
                self?.transcribtionLabelView.stringValue = delegate.speechRecognizer.transcript
                self?.scrollStackView.scroll(.init(x: self?.scrollStackView.frame.width ?? 0.0, y: 0.0))
                self?.siriAnimation.amplitude = CGFloat(delegate.speechRecognizer.peak ?? 0.0)
                self?.transcribtionLabelView.updateLayer()
                self?.statusTextView.stringValue = "performing actions"
            } else {
                self?.statusTextView.stringValue = "contacting AI..."
            }
        }.store(in: &cancellables)
    }
    
    func setupWindow() {
        // Make the title bar transparent
        self.window?.titlebarAppearsTransparent = true
        
        // Hide the title bar
        self.window?.styleMask.remove(.titled)
        
        // Optionally, remove the toolbar
        self.window?.toolbar?.isVisible = false
        
        self.window?.level = .normal
        self.window?.orderedIndex = 0
        self.window?.isOpaque = false
        self.window?.backgroundColor = NSColor.clear
        self.window?.hasShadow = false
        self.window?.collectionBehavior = [.stationary, .transient, .canJoinAllSpaces]
        // fullScreenAllowsTiling
        //            .canJoinAllSpaces, .stationary, .fullScreenAllowsTiling
        
        // Set the window size to match the screen dimensions
        if let screen = NSScreen.main {
            let size = CGSize(width: 345, height: 100.0)
            let origin = CGPoint(x: screen.frame.maxX - size.width - 16.0, y: screen.frame.maxY - size.height - 40.0)
            let frame = NSRect(origin: origin, size: size)
            self.window?.setFrame(frame, display: true)
        }
        
        if let window = self.window {
            window.styleMask = [.borderless]
            window.isMovableByWindowBackground = false // Allow dragging the window by clicking anywhere
            window.standardWindowButton(.closeButton)?.isHidden = true // Hide close button
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true // Hide minimize button
            window.standardWindowButton(.zoomButton)?.isHidden = true // Hide zoom button
        }
    }
    
    func setupUtils() {
        if let contentView = self.window?.contentView {
            contentView.addTrackingRect(contentView.bounds, owner: self, userData: nil, assumeInside: false)
        }
    }
    
    func addingConstraints() {
        
        scrollView.documentView = scrollStackView
        
        guard let constraints = window?.contentView else { return }
        
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        window?.contentView?.addSubview(visualEffect)
        NSLayoutConstraint.activate([
            visualEffect.leadingAnchor.constraint(equalTo: constraints.leadingAnchor),
            visualEffect.trailingAnchor.constraint(equalTo: constraints.trailingAnchor),
            visualEffect.topAnchor.constraint(equalTo: constraints.topAnchor),
            visualEffect.bottomAnchor.constraint(equalTo: constraints.bottomAnchor)
        ])
        
        statusTextView.translatesAutoresizingMaskIntoConstraints = false
        window?.contentView?.addSubview(statusTextView, positioned: .above, relativeTo: visualEffect)
        NSLayoutConstraint.activate([
            statusTextView.leadingAnchor.constraint(equalTo: constraints.leadingAnchor),
            statusTextView.trailingAnchor.constraint(equalTo: constraints.trailingAnchor),
            statusTextView.centerXAnchor.constraint(equalTo: constraints.centerXAnchor),
            statusTextView.bottomAnchor.constraint(equalTo: constraints.bottomAnchor, constant: -8.0),
        ])
        
        siriAnimation.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.addSubview(siriAnimation)
        NSLayoutConstraint.activate([
            siriAnimation.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor),
            siriAnimation.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor),
            siriAnimation.heightAnchor.constraint(equalTo: visualEffect.heightAnchor, multiplier: 0.8),
            siriAnimation.centerXAnchor.constraint(equalTo: visualEffect.centerXAnchor),
            siriAnimation.centerYAnchor.constraint(equalTo: visualEffect.centerYAnchor),
        ])
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.addSubview(scrollView, positioned: .below, relativeTo: siriAnimation)
        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalTo: visualEffect.heightAnchor, multiplier: 0.4),
            scrollView.widthAnchor.constraint(equalTo: visualEffect.widthAnchor, multiplier: 0.65),
            scrollView.centerYAnchor.constraint(equalTo: visualEffect.centerYAnchor),
        ])
        
        scrollStackView.translatesAutoresizingMaskIntoConstraints = false
        
        transcribtionLabelView.translatesAutoresizingMaskIntoConstraints = false
        scrollStackView.addArrangedSubview(transcribtionLabelView)
        NSLayoutConstraint.activate([
            transcribtionLabelView.trailingAnchor.constraint(equalTo: scrollStackView.trailingAnchor),
            transcribtionLabelView.leadingAnchor.constraint(equalTo: scrollStackView.leadingAnchor),
            transcribtionLabelView.heightAnchor.constraint(equalTo: scrollStackView.heightAnchor),
            transcribtionLabelView.centerYAnchor.constraint(equalTo: scrollStackView.centerYAnchor),
        ])
        
    }
    
    override func mouseDown(with event: NSEvent) {
        guard event.clickCount == 1 else { return }
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        if delegate.speechRecognizer.isTranscribing {
            delegate.speechRecognizer.stopTranscribing()
            // request ai
        } else {
            delegate.speechRecognizer.startTranscribing()
            // stop speaking/requesting ai
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        print("mouse here!")
    }
    
    override func mouseExited(with event: NSEvent) {
        print("mouse gone!")
    }
}
