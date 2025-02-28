//
//  SpeechToTextView.swift
//
//  Created by Majid Jamali with ❤️ on 2/27/25.
//  
//  

import AppKit

public class SpeechToTextView: NSTextView {
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
