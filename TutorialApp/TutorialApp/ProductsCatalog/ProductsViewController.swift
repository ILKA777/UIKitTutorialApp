//
//  ProductsViewController.swift
//  TutorialApp
//
//  Created by Илья on 03.07.2024.
//

import UIKit

// Класс для отображения списка продуктов
class ProductsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Массив продуктов
    private var products: [Product] = []
    // Сетевой сервис для получения данных о продуктах
    private let networkService = NetworkService()
    // Табличное представление для отображения продуктов
    private let tableView = UITableView()
    // Контроллер обновления для pull-to-refresh
    private let refreshControl = UIRefreshControl()

    // Метод, вызываемый при загрузке представления
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Устанавливаем цвет фона белым
        setupNavigationBar() // Настраиваем навигационную панель
        setupTableView() // Настраиваем табличное представление
        fetchProducts() // Загружаем продукты
    }

    // Метод для настройки навигационной панели
    private func setupNavigationBar() {
        // Убираем кнопку назад и добавляем кнопку для добавления продуктов и кнопку профиля
        navigationItem.hidesBackButton = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProduct))
        let profileButton = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(viewProfile))
        
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = profileButton
    }

    // Метод для настройки табличного представления
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
        view.addSubview(tableView)
        
        // Настройка RefreshControl для обновления списка
        refreshControl.addTarget(self, action: #selector(refreshProducts), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    // Метод для обновления списка продуктов с помощью pull-to-refresh
    @objc private func refreshProducts() {
        fetchProducts()
    }

    // Метод для загрузки продуктов с сервера
    private func fetchProducts() {
        networkService.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                // Останавливаем анимацию обновления
                self?.refreshControl.endRefreshing()
                switch result {
                case .success(let products):
                    self?.products = products
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showError(error: error)
                }
            }
        }
    }

    // Метод для добавления продукта
    @objc private func addProduct() {
        showProductAlert(product: nil)
    }

    // Метод для редактирования продукта
    private func editProduct(_ product: Product) {
        showProductAlert(product: product)
    }

    // Метод для отображения алерт контроллера для добавления/редактирования продукта
    private func showProductAlert(product: Product?) {
        let alertController = UIAlertController(title: product == nil ? "Add Product" : "Edit Product", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = product?.name
        }
        alertController.addTextField { textField in
            textField.placeholder = "Price"
            textField.keyboardType = .numberPad
            if let price = product?.price {
                textField.text = "\(price)"
            }
        }
        alertController.addTextField { textField in
            textField.placeholder = "Description"
            textField.text = product?.description
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textFields = alertController.textFields,
                  textFields.count == 3,
                  let name = textFields[0].text, !name.isEmpty,
                  let priceText = textFields[1].text, let price = Int(priceText),
                  let description = textFields[2].text, !description.isEmpty else {
                self?.showError(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid input"]))
                return
            }
            
            let newProduct = Product(id: product?.id ?? 0, name: name, price: price, description: description)
            
            if product == nil {
                self?.createProduct(newProduct)
            } else {
                self?.updateProduct(newProduct)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    // Метод для создания продукта
    private func createProduct(_ product: Product) {
        networkService.createProduct(product) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let product):
                    self?.products.append(product)
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showError(error: error)
                }
            }
        }
    }

    // Метод для обновления продукта
    private func updateProduct(_ product: Product) {
        networkService.updateProduct(product) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedProduct):
                    if let index = self?.products.firstIndex(where: { $0.id == updatedProduct.id }) {
                        self?.products[index] = updatedProduct
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    self?.showError(error: error)
                }
            }
        }
    }

    // Метод для удаления продукта
    private func deleteProduct(_ product: Product) {
        // Вызываем сетевой метод для удаления продукта с сервера
        networkService.deleteProduct(productId: product.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    // Если результат запроса успешен, удаляем из своего списка продукт и обновляем список
                case .success:
                    if let index = self?.products.firstIndex(where: { $0.id == product.id }) {
                        self?.products.remove(at: index)
                        self?.tableView.reloadData()
                    }
                    // Если что-то пошло не так - отображаем ошибку
                case .failure(let error):
                    self?.showError(error: error)
                }
            }
        }
    }

    // Метод для отображения профиля
    @objc private func viewProfile() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    // Метод для отображения ошибки в виде алерта
    private func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource

    // Метод для указания количества строк в секции таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    // Метод для настройки ячейки таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = "\(product.name) - $\(product.price)"
        return cell
    }

    // MARK: - UITableViewDelegate

    // Метод, вызываемый при нажатии на ячейку таблицы
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        let productDetailVC = ProductDetailViewController()
        productDetailVC.productId = product.id
        navigationController?.pushViewController(productDetailVC, animated: true)
    }

    // Метод, вызываемый при свайпе ячейки влево
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let product = products[indexPath.row]
        
        // Действие для редактирования продукта
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            self?.editProduct(product)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        // Действие для удаления продукта
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.deleteProduct(product)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
}
