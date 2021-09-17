import UIKit

class ChagePasswordTableViewController: UITableViewController {
    
    private let keyChainProvider = KeyChainDataProvider()
    var firstLogin = String()
    var firstPassword = String()
    var checkPassword = String()
    var checkLogin = String()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let models = keyChainProvider.obtains()
        guard let model = models.last else { return }
        firstLogin = model
        firstPassword = keyChainProvider.obtain(account: model)
    }
    
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
    @IBOutlet var saveButton: UIBarButtonItem! {
        didSet {
            
        }
    }
 
    @IBAction func save(_ sender: Any) {
            let tag = saveButton.tag
            switch tag {
            case 1:
                callRepeatPassword()
            case 2:
                dismiss(animated: true, completion: nil)
            case 3:
           
                guard  let newAccount = self.accountNameField.text, let newPassword = self.passwordField.text else { return }
                checkWrittenPassword(logIn: newAccount, password: newPassword)
            default:
                break
            }
    
    }
    func callRepeatPassword() {
        let  alert = UIAlertController(title: "Перед сохранением, повторите введенные данные", message: nil, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel) { [weak self] _ in
            self?.accountNameField.text = self?.firstLogin
            self?.passwordField.text = self?.firstPassword
        }
        let actionContinue = UIAlertAction(title: "Создать", style: .default) {  [weak self] _ in
            if let newAccount = self?.accountNameField.text, let newPassword = self?.passwordField.text {
                self?.checkPassword = newPassword
                self?.checkLogin = newAccount
                self?.saveButton.tag = 3
                self?.accountNameField.text = ""
                self?.passwordField.text = ""
            }
        }
        alert.addAction(actionContinue)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    func checkWrittenPassword(logIn: String, password: String) {
        if password == checkPassword && logIn == checkLogin {
            let models = keyChainProvider.obtains()
            guard let model = models.last else { return }
            keyChainProvider.remove(object: model)
            keyChainProvider.save(account: logIn, password: password)
            updateSaveButtonState()
            dismiss(animated: true, completion: nil)
        } else {
            let  alert = UIAlertController(title: "Ошибка", message: "Пароли не соотвествуют", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
                self?.saveButton.tag = 4
                self?.accountNameField.text = self?.firstLogin
                self?.passwordField.text = self?.firstPassword
                self?.updateSaveButtonState()
                
            }
            alert.addAction(actionOk)
            present(alert, animated: true, completion: nil)
        }
    }

    
    @objc func updateSaveButtonState() {
        guard isViewLoaded else { return }
        
        if let newAccount = accountNameField.text, let newPassword = passwordField.text, newAccount.count > 3 && newPassword.count > 3 {
            saveButton?.isEnabled = true
            if saveButton.tag != 3 {
            let models = keyChainProvider.obtains()
            if ((models.first(where: { $0 == newAccount && keyChainProvider.obtain(account: $0) == newPassword })) != nil) {
                saveButton.tag = 2
            } else {
                saveButton.tag = 1
            }
        }
        }
        else {
            saveButton?.isEnabled = false
        }
    }
}
