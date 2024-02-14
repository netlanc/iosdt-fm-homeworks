//
//  SceneDelegate.swift
//  FileManager
//
//  Created by netlanc on 02.02.2024.
//
import UIKit
import KeychainSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let keychain = KeychainSwift()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)

        // Проверяем, установлен ли уже пароль
        if keychain.get("password") != nil {
            // Показываем экран для ввода пароля
            let passwordVC = PasswordViewController()
            window?.rootViewController = passwordVC
        } else {
            // Показываем экран логина
            let loginVC = LoginViewController()
            window?.rootViewController = loginVC
        }

        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // При выходе из приложения стираем данные о пароле
        //keychain.delete("password")
    }

}
