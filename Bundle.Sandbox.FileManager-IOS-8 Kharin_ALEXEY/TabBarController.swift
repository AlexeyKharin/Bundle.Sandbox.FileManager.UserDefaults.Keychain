//
//  TabBarController.swift
//  Bundle.Sandbox.FileManager-IOS-8 Kharin_ALEXEY
//
//  Created by Alexey Kharin on 11.08.2021.
//

import UIKit

class TabBarController: UITabBarController {
    
    static func storyboardInstance() -> TabBarController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc =  storyboard.instantiateViewController(withIdentifier: String(describing: TabBarController.self)) as? TabBarController
        return vc
    }
    
    var navigationControllerProperty: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let navigationFirst = viewControllers?.first as? UINavigationController, let viewController = navigationFirst.viewControllers.first as? ViewController else { return }
            viewController.navigationControllerProperty = navigationControllerProperty
        
        
        if let navigationLast = viewControllers?.last as? UINavigationController, let settingsViewController = navigationLast.viewControllers.last as? SettingsTableViewController {
            settingsViewController.updataInTableView = viewController
        }
        
    }
}
