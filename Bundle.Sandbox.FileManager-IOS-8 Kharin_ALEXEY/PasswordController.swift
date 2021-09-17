
import UIKit
import KeychainAccess

class PasswordController: UIViewController {
    var checkPassword = String()
    private let keyChainProvider = KeyChainDataProvider()
    
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.blue.cgColor
            button.layer.borderWidth = 0.5
            button.setTitle("Войти", for: .normal)
        }
    }
    
    @IBAction func createOrLogInButton(_ sender: UIButton) {
        let tag = button.tag
        switch tag {
        case 1:
            callRepeatPassword()
        case 2:
            openController()
            let models = keyChainProvider.obtains()
            if let writtenAccount = account.text, let writtenPassword = password.text {
                keyChainProvider.remove(object: writtenAccount)
                keyChainProvider.save(account: writtenAccount, password: writtenPassword)
                print(models)
            }
        case 3:
            guard let writtenPassword = password.text else { return }
            checkWrittenPassword(password: writtenPassword)
        default:
            break
        }
    }
    
    func checkWrittenPassword(password: String) {
        if password == checkPassword {
            openController()
            button.tag = 4
            button.setTitle("Войти", for: .normal)
            if let writtenAccount = account.text {
                keyChainProvider.save(account: writtenAccount, password: password)
            }
        } else {
            let  alert = UIAlertController(title: "Ошибка", message: "Пароли не соотвествуют", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
                self?.button.tag = 4
                self?.password.text = ""
                self?.button.setTitle("Войти", for: .normal)
                
            }
            alert.addAction(actionOk)
            present(alert, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateSaveButtonState()
    }
    
    
    //Create textField
    @IBOutlet weak var password: UITextField!{
        didSet {
            password.placeholder = "Введите пароль не менее 3 символов"
            password.isSecureTextEntry = true
            password.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        }
    }
    
    //Create textField
    @IBOutlet weak var account: UITextField! {
        didSet {
            account.placeholder = "Введите логин"
            account.autocorrectionType = .no
            account.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        }
    }
    
    func openController() {
        guard let vc = TabBarController.storyboardInstance() else { return }
        vc.navigationControllerProperty = navigationController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func callRepeatPassword() {
        let  alert = UIAlertController(title: "По данному логину аккаунт не создан", message: "Если хотите создать аккаунт, повторите пароль", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel) { _ in
        }
        let actionContinue = UIAlertAction(title: "Создать", style: .default) {  [weak self] _ in
            if let writtenPassword = self?.password.text {
                self?.checkPassword = writtenPassword
                self?.button.tag = 3
                self?.button.setTitle("Повторите пароль", for: .normal)
                self?.password.text = ""
            }
        }
        alert.addAction(actionContinue)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    //Reaction to editing in textField
    @objc func updateSaveButtonState() {
        guard isViewLoaded else { return }
        
        if let writtenAccount = account.text, let writtenPassword = password.text, writtenAccount.count > 3 && writtenPassword.count > 3 {
            
            button?.isEnabled = true
            
            let models = keyChainProvider.obtains()
            if button.tag != 3 {
                if ((models.first(where: { $0 == writtenAccount && keyChainProvider.obtain(account: $0) == writtenPassword })) != nil) {
                    button.tag = 2
                } else {
                    button.tag = 1
                }
            }
        } else {
            button?.isEnabled = false
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButtonState()
    }
}

