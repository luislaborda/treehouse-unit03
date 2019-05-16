//
//  ArrowButton.swift
//  BoutTime
//
//  Created by Luis Laborda on 5/6/19.
//  Copyright © 2019 Luis Laborda. All rights reserved.
//
// Code From: https://blog.supereasyapps.com/how-to-create-round-buttons-using-ibdesignable-on-ios-11/

import UIKit

@IBDesignable class Button: UIButton {
    
    /// Programmatically create buttons
    override init(frame: CGRect) {
        super.init(frame: frame)
        shareInit()
    }
    
    ///  Storyboard/.xib create buttons
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    /// Called within the Storyboard editor itself for rendering @IBDesignable controls
    override func prepareForInterfaceBuilder() {
        shareInit()
    }
    
    func shareInit() {
        refreshCorners(_value: cornerRadius)
    }
    
    // Mark: - Helper Methods
    
    /// Round corner
    func refreshCorners(_value: CGFloat) {
        layer.cornerRadius = _value
    }
    
    
    // Mark: - Exposed to the Storyboard UI
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCorners(_value: cornerRadius)
        }
    }
}
