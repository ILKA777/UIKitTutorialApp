//
//  LoginView.swift
//  TutorialApp
//
//  Created by Илья on 01.07.2024.
//

import UIKit

// Протокол для обновления интерфейса и отображения результатов входа
protocol LoginView: AnyObject {
    func updateView()
    func showLoginSuccess(token: String)
    func showLoginFailure(error: Error)
}

// Контроллер экрана входа
class LoginViewController: UIViewController, LoginView {
    // Модель данных для входа
    var model = LoginModel()
    // Сетевой сервис для отправки данных на сервер
    var networkService = NetworkService()
    // Сервис для работы с Keychain для безопасного хранения данных
    var keychainService = AppKeychainService()
    
    // Текстовое поле для ввода имени пользователя
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Текстовое поле для ввода пароля
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Кнопка для отправки данных входа
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    // Метод, вызываемый при загрузке представления
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Устанавливаем цвет фона белым
        setupUI() // Настраиваем пользовательский интерфейс
    }
    
    // Метод для настройки пользовательского интерфейса
    private func setupUI() {
        // Добавляем текстовые поля и кнопку на представление
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        // Добавляем действие на нажатие кнопки входа
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // Настройка автолейаута для элементов интерфейса
        NSLayoutConstraint.activate([
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            usernameTextField.widthAnchor.constraint(equalToConstant: 250),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.widthAnchor.constraint(equalToConstant: 250),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Метод, вызываемый при нажатии кнопки входа
    @objc private func loginButtonTapped() {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        // Создаем запрос входа с введенными данными
        let loginRequest = LoginRequest(username: username, password: password)
        
        // Отправляем запрос на вход через сетевой сервис
        networkService.login(request: loginRequest) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // Сохраняем токен в Keychain и отображаем сообщение об успешном входе
                    self?.keychainService.setData(Data(response.token.utf8), forKey: "authToken")
                    //self?.showLoginSuccess(token: response.token)
                    // Переход на экран со списком продуктов
                    self?.navigateToProducts()
                case .failure(let error):
                    // Отображаем сообщение об ошибке при входе
                    self?.showLoginFailure(error: error)
                }
            }
        }
    }
    
    // Функция перехода на список продуктов
    private func navigateToProducts() {
        // Создаем объект ProductsViewController
        let productsVC = ProductsViewController()
        // Переходим на этот экран
        navigationController?.setViewControllers([productsVC], animated: true)
    }
    
    // Метод для обновления интерфейса в зависимости от состояния модели
    func updateView() {
        // Реализация обновления интерфейса
    }
    
    // Метод для отображения сообщения об успешном входе
    func showLoginSuccess(token: String) {
        let alert = UIAlertController(title: "Success", message: "Login successful! Token: \(token)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Метод для отображения сообщения об ошибке входа
    func showLoginFailure(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
