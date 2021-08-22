
enum Keys: String {
    case BoolAscending
    case BoolDescending
}

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var ascending: UISwitch!
    
    var updataInTableView: UpdaterData?
    
    @IBAction func sortAscending(_ sender: Any) {
        if ascending.isOn {
            descending.isEnabled = false
            UserDefaults.standard.setValue(true, forKey: Keys.BoolAscending.rawValue)
            updataInTableView?.updaterData()
        } else {
            descending.isEnabled = true
            UserDefaults.standard.setValue(false, forKey: Keys.BoolAscending.rawValue)
            updataInTableView?.updaterData()
        }
    }
    
    @IBOutlet weak var descending: UISwitch!
    
    @IBAction func sortDescending(_ sender: Any) {
        if descending.isOn {
            ascending.isEnabled = false
            UserDefaults.standard.setValue(true, forKey: Keys.BoolDescending.rawValue)
            updataInTableView?.updaterData()
        } else {
            ascending.isEnabled = true
            UserDefaults.standard.setValue(false, forKey: Keys.BoolDescending.rawValue)
            updataInTableView?.updaterData()
        }
    }
    
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.font = UIFont.systemFont(ofSize: 18)
        }
    }
    
    @IBOutlet weak var changePassword: UIButton! {
        didSet {
            changePassword.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            changePassword.contentHorizontalAlignment = .left
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
}
