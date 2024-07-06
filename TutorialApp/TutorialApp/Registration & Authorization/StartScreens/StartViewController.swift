//
//  AuthView.swift
//  TutorialApp
//
//  Created by Илья on 01.07.2024.
//

import UIKit

// Контроллер начального экрана
class StartViewController: UIViewController {
    // Модель данных для контроллера
    var model: StartModel!
    
    // Кнопка "Авторизация"
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Авторизация", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    // Кнопка "Регистрация"
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Регистрация", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    // Метод, вызываемый при загрузке представления
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // Устанавливаем фон представления черным
        setupUI() // Настраиваем интерфейс
    }
    
    // Метод для настройки пользовательского интерфейса
    private func setupUI() {
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        
        // Добавляем действия на нажатие кнопок
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        // Параметры высоты и ширины кнопок
        let buttonWidth: CGFloat = 250
        let buttonHeight: CGFloat = 50
        
        // Настройка автолейаута для кнопок
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            loginButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            loginButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            registerButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            registerButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    }
    
    // Метод, вызываемый при нажатии кнопки "Авторизация"
    @objc private func loginButtonTapped() {
        let loginVC = LoginViewController() // Создаем экземпляр LoginViewController
        navigationController?.pushViewController(loginVC, animated: true) // Переходим на экран авторизации
    }
    
    // Метод, вызываемый при нажатии кнопки "Регистрация"
    @objc private func registerButtonTapped() {
        let registerVC = RegisterViewController() // Создаем экземпляр RegisterViewController
        navigationController?.pushViewController(registerVC, animated: true) // Переходим на экран регистрации
    }
}
