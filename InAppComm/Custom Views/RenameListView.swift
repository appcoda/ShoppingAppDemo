//
//  RenameListView.swift
//  InAppComm
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class RenameListView: UIView {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var textField: UITextField!
    
    
    // MARK: - Properties
    
    var cancelHandler: (() -> Void)?
    
    var renameHandler: ((_ name: String) -> Void)?
    

    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        loadContent()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    // MARK: - Custom Methods
    
    fileprivate func loadContent() {
        if let nibContents = Bundle.main.loadNibNamed("RenameListView", owner: self, options: nil) {
            if let view = nibContents[0] as? UIView {
                self.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
                view.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
                view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            }
        }
    }
    
    
    
    func handleCancelRenaming(handler: @escaping () -> Void) {
        cancelHandler = handler
    }
    
    
    func handleRenaming(handler: @escaping (_ name: String) -> Void) {
        renameHandler = handler
    }
    
    
    
    
    // MARK: - IBAction Methods
    
    @IBAction func rename(_ sender: Any) {
        guard let text = textField.text else { return }
        if text != "" {
            if let handler = renameHandler {
                handler(text)
            }
        }
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        if let handler = cancelHandler {
            handler()
        }
    }
    
    
    
}

