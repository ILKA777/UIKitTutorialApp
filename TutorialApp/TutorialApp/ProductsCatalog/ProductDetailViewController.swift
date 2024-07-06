//
//  ProductDetailViewController.swift
//  TutorialApp
//
//  Created by Илья on 03.07.2024.
//

import UIKit

// Класс для отображения детальной информации о продукте
class ProductDetailViewController: UIViewController {
    // Идентификатор продукта, информация о котором будет отображаться
    var productId: Int!
    // Модель данных для продукта
    private var product: Product?
    // Сетевой сервис для получения данных о продукте
    private let networkService = NetworkService()

    // UI элементы для отображения информации о продукте
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()

    // Метод, вызываемый при загрузке представления
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Устанавливаем цвет фона белым
        setupUI() // Настраиваем пользовательский интерфейс
        fetchProductDetails() // Загружаем данные о продукте
    }

    // Метод для настройки пользовательского интерфейса
    private func setupUI() {
        // Устанавливаем автолейаут для элементов интерфейса
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0 // Разрешаем многострочное отображение для описания

        // Добавляем элементы на представление
        view.addSubview(nameLabel)
        view.addSubview(priceLabel)
        view.addSubview(descriptionLabel)

        // Устанавливаем ограничения для элементов интерфейса
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // Метод для получения данных о продукте с сервера
    private func fetchProductDetails() {
        // Вызываем метод сетевого сервиса для получения данных о продукте
        networkService.fetchProductDetails(productId: productId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let product):
                    // Если запрос успешен, сохраняем данные о продукте и обновляем UI
                    self?.product = product
                    self?.updateUI()
                case .failure(let error):
                    // Если запрос завершился ошибкой, отображаем сообщение об ошибке
                    self?.showError(error: error)
                }
            }
        }
    }

    // Метод для обновления интерфейса с данными о продукте
    private func updateUI() {
        guard let product = product else { return }
        nameLabel.text = product.name // Устанавливаем название продукта
        priceLabel.text = "$\(product.price)" // Устанавливаем цену продукта
        descriptionLabel.text = product.description // Устанавливаем описание продукта
    }

    // Метод для отображения сообщения об ошибке
    private func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
