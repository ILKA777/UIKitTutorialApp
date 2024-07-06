//
//  ProfileViewController.swift
//  TutorialApp
//
//  Created by Илья on 05.07.2024.
//

import UIKit
import CoreData

// Класс для отображения экрана профиля пользователя
class ProfileViewController: UIViewController {
    // UI элементы для отображения информации профиля
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let aboutButton = UIButton(type: .system) // Кнопка для перехода на экран About
    
    // Переменная для хранения информации о пользователе
    private var user: User?

    // Метод, вызываемый при загрузке представления
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Устанавливаем цвет фона
        setupUI() // Настраиваем пользовательский интерфейс
        setupNavigationBar() // Настраиваем навигационную панель
        fetchUserData() // Загружаем данные пользователя
    }
    
    // Метод для настройки навигационной панели
        private func setupNavigationBar() {
            // Устанавливаем заголовок
            title = "Profile"
            
            // Создаем кнопку выхода с изображением двери с выходом
            let logoutButton = UIBarButtonItem(image: UIImage(systemName: "door.right.hand.open"), style: .plain, target: self, action: #selector(logoutButtonTapped))
            
            // Устанавливаем кнопку на правую часть навигационной панели
            navigationItem.rightBarButtonItem = logoutButton
        }
    
    // Метод для настройки пользовательского интерфейса
    private func setupUI() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.image = UIImage(systemName: "person.circle")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.tintColor = .gray
        
        nameLabel.font = UIFont.systemFont(ofSize: 24)
        nameLabel.textAlignment = .center
        
        aboutButton.setTitle("About", for: .normal) // Настройка кнопки About
        aboutButton.setTitleColor(.blue, for: .normal)
        aboutButton.addTarget(self, action: #selector(aboutButtonTapped), for: .touchUpInside)
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(aboutButton) // Добавляем кнопку About
        
        NSLayoutConstraint.activate([
            // Устанавливаем ограничения для изображения профиля
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Устанавливаем ограничения для метки имени
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Устанавливаем ограничения для кнопки About
            aboutButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            aboutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // Метод для загрузки данных пользователя из Core Data
    private func fetchUserData() {
        let context = UserService.shared.context
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            // Выполняем запрос выборки данных пользователя
            let users = try context.fetch(request)
            if let user = users.first {
                // Если пользователь найден, отображаем его данные
                self.user = user
                nameLabel.text = user.name
            } else {
                // Если пользователь не найден, отображаем сообщение об этом
                nameLabel.text = "No user logged in"
            }
        } catch {
            // Обрабатываем ошибку при выборке данных
            print("Failed to fetch user data: \(error)")
        }
    }
    
    // Метод, вызываемый при нажатии на кнопку выхода
    @objc func logoutButtonTapped() {
        // Очищаем данные пользователя
        UserService.shared.clearData()
        
        // Получаем главное окно приложения
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        // Создаем новый корневой контроллер (экран входа)
        let rootViewController = StartViewController()
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        // Устанавливаем новый корневой контроллер
        window.rootViewController = navigationController
        
        // Анимация перехода
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
    }
    
    // Метод, вызываемый при нажатии на кнопку About
    @objc func aboutButtonTapped() {
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }
}
