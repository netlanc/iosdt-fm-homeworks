//
//  TabBarController.swift
//  FileManager
//
//  Created by netlanc on 13.02.2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filesVC = FileManagerController(fileService: FileService())
        let settingsVC = SettingsViewController()
        
        filesVC.title = "Файлы"
        settingsVC.title = "Настройки"
        
        // Используем системные символы для иконок
        filesVC.tabBarItem = UITabBarItem(title: "Файлы", image: UIImage(systemName: "folder"), tag: 0)
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 1)
        
        let filesNav = UINavigationController(rootViewController: filesVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        
        setViewControllers([filesNav, settingsNav], animated: true)
    }
}

