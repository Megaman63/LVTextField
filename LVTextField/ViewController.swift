//
//  ViewController.swift
//  LVTextField
//
//  Created by Сергей on 24.01.17.
//  Copyright © 2017 LindenValley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var textF : LVTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let textField = LVTextField(frame: CGRect(x: 16, y: 225, width: 343, height: 30))
        textField.upperPlaceholder = false
        textField.placeholder = "Init from code"
        view.addSubview(textField)
    }
    
    @IBAction func closeKeyboard () {
        for subview in view.subviews {
            if let textField = subview as? UITextField {
                _ = textField.resignFirstResponder()
            }
        }
    }
    
    
}

