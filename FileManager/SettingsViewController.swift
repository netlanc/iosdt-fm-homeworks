//
//  SettingsViewController.swift
//  FileManager
//
//  Created by netlanc on 05.02.2024.
//
import UIKit
import KeychainSwift

class SettingsViewController: UIViewController {
    
    let keychain = KeychainSwift()
    let defaults = UserDefaults.standard
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    let options = ["Сортировка", "Изменить пароль"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = options[indexPath.row]
        
        if indexPath.row == 0 {
            let sortingEnabled = defaults.bool(forKey: "sortingEnabled")
            cell.detailTextLabel?.text = sortingEnabled ? "Я-А" : "А-Я"
            cell.imageView?.image = UIImage(systemName: sortingEnabled ? "arrow.up" : "arrow.down")
        } else if indexPath.row == 1 {
            cell.imageView?.image = UIImage(systemName: "lock.fill")
        }
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            
            let sortingEnabled = defaults.bool(forKey: "sortingEnabled")
            defaults.set(!sortingEnabled, forKey: "sortingEnabled")
            
            print("sortingEnabled", sortingEnabled)
            // Save sorting direction
            let sortingDirection = sortingEnabled ? true : false
            defaults.set(sortingDirection, forKey: "sortingDirection")
            print("sortingDirection", sortingDirection)
            
            // Notify FileManagerController about the sorting change
            NotificationCenter.default.post(name: Notification.Name("SortingChanged"), object: sortingDirection)
            
            tableView.reloadData()
        } else if indexPath.row == 1 {
            showChangePasswordAlert()
        }
    }
    
    private func showChangePasswordAlert() {
        let alertController = UIAlertController(title: "Изменение пароля", message: "Введите новый пароль", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Новый пароль"
            textField.isSecureTextEntry = true
        }
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { _ in
            guard let newPassword = alertController.textFields?.first?.text, newPassword.count >= 4 else {
                self.showAlert(message: "Пароль должен состоять не менее чем из 4 символов")
                return
            }
            
            let currentPassword = self.keychain.get("password")
            
            if newPassword == currentPassword {
                self.showAlert(message: "Ваш пароль совпадает со текущим паролем, нужно ввести новый")
            } else {
                self.keychain.set(newPassword, forKey: "password")
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Сообщение", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Закрыть", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
