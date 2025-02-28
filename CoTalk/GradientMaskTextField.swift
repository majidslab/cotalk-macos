//
//  GradientMaskTextField.swift
//
//  Created by Majid Jamali with ❤️ on 2/28/25.
//
//

import Cocoa

class GradientMaskTextField: NSTextField {
    private var gradientLayer: CAGradientLayer!
    private var textLayer: CATextLayer!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupGradientMask()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientMask()
    }
    
    private func setupGradientMask() {
        // Enable layer-backed drawing
        self.wantsLayer = true
        
        // Create a gradient layer
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [
            NSColor.color1.withAlphaComponent(0.3).cgColor,
            NSColor.color1.withAlphaComponent(0.5).cgColor,
            NSColor.color1.cgColor,
            NSColor.color2.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Create a text layer for the mask
        textLayer = CATextLayer()
        textLayer.frame = self.bounds
        textLayer.string = self.stringValue
        textLayer.alignmentMode = .center
        textLayer.fontSize = self.font?.pointSize ?? 14
        textLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
        
        // Use the text layer as the mask for the gradient layer
        gradientLayer.mask = textLayer
        
        // Add the gradient layer to the view's layer
        self.layer?.addSublayer(gradientLayer)
        
    }
    
    override func layout() {
        super.layout()
        
        // Update the frames of the gradient and text layers when the view resizes
        gradientLayer.frame = self.bounds
        textLayer.frame = self.bounds
        textLayer.string = self.stringValue
        textLayer.font = NSFont.systemFont(ofSize: 24.0, weight: .black)
        textLayer.fontSize = 24.0
    }
}
