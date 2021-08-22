
import UIKit
import KeychainAccess

class PasswordController: UIViewController {
    
    private let keyChainProvider = KeyChainDataProvider()
    
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.blue.cgColor
            button.layer.borderWidth = 0.5
            button.setTitle("Создать аккаунт", for: .normal)
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
        default:
            break
        }
    }
    
    //Create textField
    @IBOutlet weak var password: UITextField!{
        didSet {
            password.placeholder = "Введите пароль"
            password.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        }
    }
    
    //Create textField
    @IBOutlet weak var account: UITextField! {
        didSet {
            account.placeholder = "Введите логин"
            account.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        }
    }
    
    func openController() {
        guard let vc = TabBarController.storyboardInstance() else { return }
        vc.navigationControllerProperty = navigationController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func callRepeatPassword() {
        let  alert = UIAlertController(title: "Хотите создать аккаунт?", message: "Повторите пароль", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
        }
        let actionContinue = UIAlertAction(title: "Создать", style: .default) { (_) in
            
            let textField = alert.textFields![0] as UITextField
            guard let text = textField.text else { return }
            
            guard let originAccount = self.account.text, let originPassword = self.password.text else { return }
            
            if text == originPassword {
                self.keyChainProvider.save(account: originAccount, password: originPassword)
            
            let models = self.keyChainProvider.obtains()
            if let savedAccount = models.last {
                self.account.text = savedAccount
                self.password.text = self.keyChainProvider.obtain(account: savedAccount)
                self.updateSaveButtonState()
            }
            } else {
               let alertError = UIAlertController(title: "Ошибка", message: "Пароли не соотвествуют", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "OK", style: .cancel) { (_) in }
                alertError.addAction(actionOk)
                self.present(alertError, animated: true, completion: nil)
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Не менее 4 символов"
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
            
            if ((models.first(where: { $0 == writtenAccount && keyChainProvider.obtain(account: $0) == writtenPassword })) != nil) {
                button.setTitle(" Войти ", for: .normal)
                button.tag = 2
            } else {
                button.setTitle("Создать аккаунт", for: .normal)
                button.tag = 1
            }
        }
        else {
            button?.isEnabled = false
            button.setTitle("Создать аккаунт", for: .normal)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if  keyChainProvider.obtains().count != 0 {
            let models = keyChainProvider.obtains()
            print(models)
            if let savedAccount = models.last {
                account.text = savedAccount
                password.text = keyChainProvider.obtain(account: savedAccount)
            }
        }
        updateSaveButtonState()
    }
}

