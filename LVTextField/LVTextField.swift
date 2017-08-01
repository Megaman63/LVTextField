//
//  LVTextField.swift
//  6DegreesApp
//
//  Created by Сергей on 06.11.16.
//  Copyright © 2016 LindenValley. All rights reserved.
//

import UIKit

@IBDesignable class LVTextField: UITextField {

    //you can add line to the bottom of the textField (if you add, turn off border style)
    @IBInspectable var addLine : Bool = true {
        didSet {
            if !addLine {
                line?.removeFromSuperview()
            }
        }
    }

    // upperPlaceholder like in Android, 
    @IBInspectable var upperPlaceholder : Bool = true {
        didSet {
            if upperPlaceholder {
                minimumAlpha = 0.3
                minimumScale = 0.8
                maximumAlpha = 0.6
                positionRemoved = -frame.height * 0.5
                clipsToBounds = false
            } else {
                minimumAlpha = 0
                minimumScale = 0.8
                maximumAlpha = 0.5
                positionRemoved = frame.height
                clipsToBounds = true
            }
        }
    }
    
    @IBInspectable var selectedLineColor : UIColor? = UIColor.blue {
        didSet {
            selectedLine?.backgroundColor = selectedLineColor
        }
    }
    
    @IBInspectable var lineColor : UIColor? = UIColor.lightGray {
        didSet {
            line?.backgroundColor = lineColor
       }
    }
    
    @IBInspectable var wrongLineColor : UIColor? = UIColor.red {
        didSet {
            wrongLine?.backgroundColor = wrongLineColor
        }
    }
    
    override public var text: String? {
        willSet {
            if newValue == "" {
                addCustomPlaceholder()
            } else {
                removeCustomPlaceholder()
            }
        }
    }
    
    override var placeholder : String? {
        get {
            if super.placeholder != "" {
                return super.placeholder
            }
            if customPlaceholder == nil {
                return customPlaceholderText
            } else {
                return customPlaceholder.text
            }
        }
        set {
            if customPlaceholder == nil {
                createPlaceHolderLabel()
            }
            customPlaceholderText = newValue ?? ""
            customPlaceholder.text = customPlaceholderText
            super.placeholder = ""
        }
    }
    
    private var customPlaceholderText : String = ""
    
    private var minimumAlpha = CGFloat(0)
    private var maximumAlpha = CGFloat(0.5)
    private var minimumScale = CGFloat(0.8)
    private var positionRemoved = CGFloat(30)
    
    private var selectedLine : UIImageView? = nil
    private var wrongLine : UIImageView? = nil
    private var line : UIImageView? = nil
    
    private var customPlaceholder : UILabel!
    
    private var animatingDisappear = false
    private var beginAnimateAppearAfterDisappear = false
    
    private var currentScale : CGFloat = 1
    private var justAppear = true
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func awakeFromNib() {
        setup()
    }
    
    private func setup () {

        if upperPlaceholder {
            minimumAlpha = 0.3
            minimumScale = 0.8
            maximumAlpha = 0.6
            positionRemoved = -frame.height * 0.5
            clipsToBounds = false
        } else {
            minimumAlpha = 0
            minimumScale = 0.8
            maximumAlpha = 0.5
            positionRemoved = frame.height
            clipsToBounds = true
        }
        if let pl = placeholder { //dirty
            placeholder = pl
        }

        if addLine {
            line = UIImageView(frame: CGRect(x: 0, y: frame.size.height - 2 , width: frame.size.width, height: 1.5))
            line!.backgroundColor = lineColor
            addSubview(line!)
            animateLine()
        }
    }
    
    private func createPlaceHolderLabel() {
        customPlaceholder = UILabel(frame: frame)
        customPlaceholder.font = font
        customPlaceholder.textColor = textColor
        customPlaceholder.transform = customPlaceholder.transform.scaledBy(x:minimumScale, y: minimumScale)
        currentScale = minimumScale
        customPlaceholder.text = customPlaceholderText
        addSubview(customPlaceholder)
        addCustomPlaceholder()
    }
    
    override open func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        if resignFirstResponder {
            removeSelected()
            if text == "" {
                addCustomPlaceholder()
            } else {
                removeCustomPlaceholder()
            }
        }
        return resignFirstResponder
    }
    
    override open func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        if becomeFirstResponder {
            if addLine {
                animateSelected()
                wrongLine?.removeFromSuperview()
            }
            removeCustomPlaceholder()
        }
        return becomeFirstResponder
    }
    
    
    func animateTextFieldAppear() {
        if text == "" {
            addCustomPlaceholder()
        } else {
            removeCustomPlaceholder()
        }
    }
    
    internal func addCustomPlaceholder () {
        if animatingDisappear {
            beginAnimateAppearAfterDisappear = true
        } else {
            animatePlaceholderAppear()
        }
    }

    private func animatePlaceholderAppear() {
        
        var alpha = minimumAlpha
        if justAppear {
            clipsToBounds = true
            alpha = 0
        }
        
        beginAnimateAppearAfterDisappear = false
        customPlaceholder.alpha = alpha
        
        let bigScale = 1 / currentScale
        UIView.animate(withDuration: 0.4, animations: {
            self.customPlaceholder.alpha = self.maximumAlpha
            self.customPlaceholder.transform = self.customPlaceholder.transform.scaledBy(x: bigScale, y: bigScale)
            self.currentScale = 1
            self.customPlaceholder.frame = self.bounds
            }) { (_) in
                self.justAppear = false
                self.clipsToBounds = !self.upperPlaceholder
        }
    }
    
    internal func removeCustomPlaceholder () {
        if animatingDisappear  {
            return
        }
        animatingDisappear = true
        let lowScale = minimumScale / currentScale
        
        UIView.animate(withDuration: 0.4, animations: {
            self.customPlaceholder.alpha = self.minimumAlpha
            
            self.customPlaceholder.transform = self.customPlaceholder.transform.scaledBy(x:lowScale, y: lowScale)
            self.currentScale = self.minimumScale
            self.customPlaceholder.frame = rectWithReplace(rect: self.bounds, y: self.positionRemoved)

            
            }) { (_) in
                self.animatingDisappear = false
                if self.beginAnimateAppearAfterDisappear {
                   self.animatePlaceholderAppear()
                }
                self.justAppear = false
        }
    }
    
    
    //MARK: - lines appear
    func animateLine () {
        line!.frame = rectWithReplace(rect: line!.frame, width: 0)
        UIView.animate(withDuration: 0.4) {
            self.line!.frame = rectWithReplace(rect: self.line!.frame, width: self.frame.size.width)
        }
    }
    
    func animateSelected() {
        if selectedLine == nil {
            selectedLine = UIImageView()
        }
        selectedLine!.frame = CGRect(x: 0, y: frame.size.height - 2 , width: frame.size.width, height: 1.5)
        selectedLine!.backgroundColor = selectedLineColor
        
        addSubview(selectedLine!)
        
        selectedLine!.frame = rectWithReplace(rect: selectedLine!.frame, width: 0)
        UIView.animate(withDuration: 0.3) {
            self.selectedLine!.frame = rectWithReplace(rect: self.selectedLine!.frame, width: self.frame.size.width)
        }
    }
    
    
    // you can yous this to show wrong value
    public func animateWrongValue() {
        if wrongLine == nil {
            wrongLine = UIImageView(frame: CGRect(x: 0, y: frame.size.height - 2 , width: frame.size.width, height: 1.5))
            wrongLine!.backgroundColor = wrongLineColor
        }
        addSubview(wrongLine!)
        wrongLine!.frame = rectWithReplace(rect: wrongLine!.frame, width: 50)
        UIView.animate(withDuration: 0.2) {
            self.wrongLine!.frame = rectWithReplace(rect: self.wrongLine!.frame, width: self.frame.size.width)
        }
    }
    
    
    //MARK: - lines disappear
    
    // you can yous this to delete wrong value
    public func removeWrongBackground() {
        if wrongLine != nil {
            wrongLine?.removeFromSuperview()
        }
    }
    
    public func removeSelected (){
        if selectedLine == nil {
            return
        }
        UIView.animate(withDuration: 0.9) {
            self.selectedLine!.frame = rectWithReplace(rect: self.selectedLine!.frame, width: 0)
        }
    }
}




func rectWithReplace(rect : CGRect, y : CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: y, width: rect.size.width, height: rect.size.height)
}

func rectWithReplace(rect : CGRect, width : CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: width, height: rect.size.height)
}



