//
//  NoteEditorViewController.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

class NoteEditorViewController: UIViewController {
    @IBOutlet weak var textView:UITextView?
    @IBOutlet weak var saveItem:UIBarButtonItem?
    
    var completionHandler:((NoteEditorViewController, Bool) -> Void) = {(_,_) in}
    var text:String?
    
    @IBAction func cancelItemDidTouch(sender: UIBarButtonItem) {
        completionHandler(self, false)
    }
    
    @IBAction func saveItemDidTouch(sender: UIBarButtonItem) {
        completionHandler(self, true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let textView = textView {
            textViewDidChange(textView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView?.text = text
        textView?.becomeFirstResponder()
    }
}

extension NoteEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        saveItem?.isEnabled = textView.text.count > 0
    }
}
