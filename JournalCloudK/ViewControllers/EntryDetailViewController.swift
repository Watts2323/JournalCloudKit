//
//  EntryDetailViewController.swift
//  JournalCloudK
//
//  Created by Xavier on 11/6/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {

    @IBOutlet weak var entryTitleTextField: UITextField!
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var bodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewIfNeeded()
        updateViews()
    }
    //Landing Pad
    var entry: Entry? {
        didSet{
            updateViews()
        }
    }
    
    func updateViews() {
        guard let entry = entry else { return }
        entryTitleTextField.text = entry.title
        bodyTextView.text = entry.body
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = entryTitleTextField.text,
            let body = bodyTextView.text else { return }
        entryTitleTextField.resignFirstResponder()
        print("Save button tapped")
        if let entry = entry {
            EntryController.shared.update(entry: entry, title: title, body: body) { (success) in
                if success {
                    print("Updated Entry successfully")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Did not update Successfully 😡")
                }
            }
        } else {
            EntryController.shared.addEntryWith(title: title, body: body) { (success) in
                if success == true {
                    print("Added Entry successfully")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Sorry Couldn't add Entry Successfully 😔")
                }
            }
        }
    }
    @IBAction func clearButtonTapped(_ sender: Any) {
        entryTitleTextField.text = ""
        bodyTextView.text = ""
    }
    
}
