//
//  ChagePasswordTableViewController.swift
//  Bundle.Sandbox.FileManager-IOS-8 Kharin_ALEXEY
//
//  Created by Alexey Kharin on 11.08.2021.
//

import UIKit

class ChagePasswordTableViewController: UITableViewController {
    
    private let keyChainProvider = KeyChainDataProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let models = keyChainProvider.obtains()
        guard let model = models.last else { return }
        accountNameField.text = model
        passwordField.text = keyChainProvider.obtain(account: model)
        updateSaveButtonState()
    }
    
    @IBOutlet var accountNameField: UITextField! {
        didSet {
            accountNameField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        }
    }
    
    @IBOutlet var passwordField: UITextField! {
        didSet {
            passwordField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        }
    }
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet var clearTextSwitch: UISwitch!
    
    @IBAction func toggleClearText(_ sender: Any) {
        passwordField.isSecureTextEntry = !clearTextSwitch.isOn
    }
    @IBOutlet var saveButton: UIBarButtonItem!
 
    @IBAction func save(_ sender: Any) {
        if let writtenAccount = accountNameField.text, let writtenPassword = passwordField.text {
            let models = keyChainProvider.obtains()
            guard let model = models.last else { return }
            keyChainProvider.remove(object: model)
            keyChainProvider.save(account: writtenAccount, password: writtenPassword)
            updateSaveButtonState()
            dismiss(animated: true, completion: nil)
    }
    }

    
    @objc func updateSaveButtonState() {
        guard isViewLoaded else { return }
        
        if let newAccount = accountNameField.text, let newPassword = passwordField.text, newAccount.count > 3 && newPassword.count > 3 {
            saveButton?.isEnabled = true
        }
        else {
            saveButton?.isEnabled = false
        }
    }
}
