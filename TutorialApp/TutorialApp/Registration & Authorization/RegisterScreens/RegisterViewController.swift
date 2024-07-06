//
//  RegisterView.swift
//  TutorialApp
//
//  Created by Илья on 01.07.2024.
//

import UIKit

// Протокол для обновления интерфейса и отображения результатов регистрации
protocol RegisterView: AnyObject {
    func updateView()
    func showRegistrationSuccess(token: String)
    func showRegistrationFailure(error: Error)
}

// Контроллер экрана регистрации
class RegisterViewController: UIViewController, RegisterView {
    // Модель данных для регистрации
    var model = RegisterModel()
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
    
    // Текстовое поле для ввода электронной почты
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
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
    
    // Кнопка для отправки данных регистрации
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
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
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(registerButton)
        
        // Добавляем действие на нажатие кнопки регистрации
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        // Настройка автолейаута для элементов интерфейса
        NSLayoutConstraint.activate([
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            usernameTextField.widthAnchor.constraint(equalToConstant: 250),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: 250),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            registerButton.widthAnchor.constraint(equalToConstant: 250),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Метод, вызываемый при нажатии кнопки регистрации
    @objc private func registerButtonTapped() {
        let username = usernameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        // Создаем запрос регистрации с введенными данными
        let registrationRequest = RegistrationRequest(username: username, password: password, email: email, secretResponse: "secret")
        
        // Отправляем запрос на регистрацию через сетевой сервис
        networkService.register(request: registrationRequest) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // Сохраняем токен в Keychain и отображаем сообщение об успешной регистрации
                    self?.keychainService.setData(Data(response.token.utf8), forKey: "authToken")
                    //self?.showRegistrationSuccess(token: response.token)
                    // Переход на экран со списком продуктов
                    self?.navigateToProducts()
                case .failure(let error):
                    // Отображаем сообщение об ошибке при регистрации
                    self?.showRegistrationFailure(error: error)
                }
            }
        }
    }
    
    // Метод перехода на экран со списком продуктов
    private func navigateToProducts() {
        // Создаем экземлпяр класса со списком продуктов
        let productsVC = ProductsViewController()
        // Переходим на экран со списком
        navigationController?.setViewControllers([productsVC], animated: true)
    }
    
    // Метод для обновления интерфейса в зависимости от состояния модели
    func updateView() {
        // Реализация обновления интерфейса
    }
    
    // Метод для отображения сообщения об успешной регистрации
    func showRegistrationSuccess(token: String) {
        let alert = UIAlertController(title: "Success", message: "Registration successful! Token: \(token)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Метод для отображения сообщения об ошибке регистрации
    func showRegistrationFailure(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
