//
//  InputViewController.swift
//  ContactEdit
//
//  Created by Roman Kozak on 4/29/18.
//  Copyright © 2018 Roman Kozak. All rights reserved.
//

import UIKit

class InputViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField?
    
    var actionItem: ActionItem? {
        didSet {
            navigationItem.title = actionItem?.title
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField?.becomeFirstResponder()
    }
    
    //////
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onComplete()
        return true
    }
    
    //////
    
    @IBAction func onComplete() {
        defer {
            navigationController?.popViewController(animated: true)
        }
        guard let text = textField?.text, let count = Int(text) else {
            return
        }
        
        actionItem?.handleInputAction?(count)
    }
}
