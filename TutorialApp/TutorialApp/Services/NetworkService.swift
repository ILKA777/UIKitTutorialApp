//
//  NetworkService.swift
//  TutorialApp
//
//  Created by Илья on 02.07.2024.
//

import Foundation

// Класс для выполнения сетевых запросов
class NetworkService {
    
    // Метод для выполнения запроса входа пользователя
    func login(request: LoginRequest, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        // Проверяем, что URL для входа правильный
        guard let url = URL(string: "http://127.0.0.1:8080/api/auth/signin") else { return }
        
        // Создаем объект URLRequest с указанным URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST" // Устанавливаем HTTP-метод POST
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // Устанавливаем заголовок Content-Type как application/json
        
        // Кодируем объект LoginRequest в JSON и устанавливаем его как тело запроса
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            // Если кодирование не удалось, вызываем completion с ошибкой и выходим
            completion(.failure(error))
            return
        }
        
        // Создаем задачу URLSession для отправки запроса
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Если возникла ошибка при отправке запроса, вызываем completion с ошибкой и выходим
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем, что ответ имеет статус 200 OK и содержит данные
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            // Декодируем JSON-ответ в объект LoginResponse
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                // Если декодирование успешно, вызываем completion с результатом успеха
                
                let context = UserService.shared.context
                let user = User(context: context)
                user.id = Int64(loginResponse.id)
                user.name = request.username
                UserService.shared.saveContext()
                
                completion(.success(loginResponse))
            } catch {
                // Если декодирование не удалось, вызываем completion с ошибкой
                completion(.failure(error))
            }
        }
        
        // Запускаем задачу
        task.resume()
    }
    
    // Метод для выполнения запроса регистрации пользователя
    func register(request: RegistrationRequest, completion: @escaping (Result<RegistrationResponse, Error>) -> Void) {
        // Проверяем, что URL для регистрации правильный
        guard let url = URL(string: "http://localhost:8080/api/auth/signup") else { return }
        
        // Создаем объект URLRequest с указанным URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST" // Устанавливаем HTTP-метод POST
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // Устанавливаем заголовок Content-Type как application/json
        
        // Кодируем объект RegistrationRequest в JSON и устанавливаем его как тело запроса
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            // Если кодирование не удалось, вызываем completion с ошибкой и выходим
            completion(.failure(error))
            return
        }
        
        // Создаем задачу URLSession для отправки запроса
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Если возникла ошибка при отправке запроса, вызываем completion с ошибкой и выходим
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем, что ответ имеет статус 200 OK и содержит данные
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            // Декодируем JSON-ответ в объект RegistrationResponse
            do {
                let registrationResponse = try JSONDecoder().decode(RegistrationResponse.self, from: data)
                
                let context = UserService.shared.context
                let user = User(context: context)
                user.id = Int64(registrationResponse.id)
                user.name = request.username
                UserService.shared.saveContext()
                
                // Если декодирование успешно, вызываем completion с результатом успеха
                completion(.success(registrationResponse))
            } catch {
                // Если декодирование не удалось, вызываем completion с ошибкой
                completion(.failure(error))
            }
        }
        
        // Запускаем задачу
        task.resume()
    }
    
    // Функция для получения списка продуктов с сервера
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        // Проверяем, что URL для получения продуктов правильный
        guard let url = URL(string: "http://localhost:8080/api/products") else { return }
        
        // Создаем объект URLRequest с указанным URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET" // Устанавливаем HTTP-метод GET
        
        // Получаем токен из Keychain
        if let tokenData = AppKeychainService().getData(forKey: "authToken"),
           let token = String(data: tokenData, encoding: .utf8) {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Устанавливаем заголовок Authorization с токеном
        }
        
        // Создаем задачу URLSession для отправки запроса
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Если возникла ошибка при отправке запроса, вызываем completion с ошибкой и выходим
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем, что ответ имеет статус 200 OK и содержит данные
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            // Декодируем JSON-ответ в объект Product
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                // Если декодирование успешно, вызываем completion с результатом успеха
                completion(.success(products))
            } catch {
                // Если декодирование не удалось, вызываем completion с ошибкой
                completion(.failure(error))
            }
        }
        
        // Запускаем задачу
        task.resume()
    }
    
    // Функция для получения детальной информации о продукте с сервера по его идентификатору
    func fetchProductDetails(productId: Int, completion: @escaping (Result<Product, Error>) -> Void) {
        // Проверяем, что URL для получения информации о продукте правильный
        guard let url = URL(string: "http://127.0.0.1:8080/api/products/\(productId)") else { return }
        
        // Создаем объект URLRequest с указанным URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET" // Устанавливаем HTTP-метод GET
        
        // Получаем токен из Keychain
        if let tokenData = AppKeychainService().getData(forKey: "authToken"),
           let token = String(data: tokenData, encoding: .utf8) {
            // Устанавливаем заголовок Authorization с токеном
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Создаем задачу URLSession для отправки запроса
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Если возникла ошибка при отправке запроса, вызываем completion с ошибкой и выходим
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем, что ответ имеет статус 200 OK и содержит данные
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                // Если ответ не соответствует ожиданиям, создаем и возвращаем ошибку
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            // Декодируем JSON-ответ в объект Product
            do {
                let product = try JSONDecoder().decode(Product.self, from: data)
                // Если декодирование успешно, вызываем completion с результатом успеха
                completion(.success(product))
            } catch {
                // Если декодирование не удалось, вызываем completion с ошибкой
                completion(.failure(error))
            }
        }
        
        // Запускаем задачу
        task.resume()
    }
    
    // Метод для создания нового продукта
    func createProduct(_ product: Product, completion: @escaping (Result<Product, Error>) -> Void) {
        // Проверяем, что URL для создания продукта правильный
        guard let url = URL(string: "http://127.0.0.1:8080/api/products") else { return }
        
        // Создаем объект URLRequest с указанным URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST" // Устанавливаем HTTP-метод POST
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // Устанавливаем заголовок Content-Type как application/json
        
        // Получаем токен из Keychain
        if let tokenData = AppKeychainService().getData(forKey: "authToken"),
           let token = String(data: tokenData, encoding: .utf8) {
            // Устанавливаем заголовок Authorization с токеном
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Создаем словарь с данными продукта без ID
        let productData: [String: Any] = [
            "name": product.name,
            "price": product.price,
            "description": product.description
        ]
        
        // Кодируем объект Product в JSON и устанавливаем его как тело запроса
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: productData, options: [])
            urlRequest.httpBody = jsonData
        } catch {
            // Если кодирование не удалось, вызываем completion с ошибкой и выходим
            completion(.failure(error))
            return
        }
        
        // Создаем задачу URLSession для отправки запроса
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Если возникла ошибка при отправке запроса, вызываем completion с ошибкой и выходим
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем, что ответ имеет статус 201 Created и содержит данные
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201, let data = data else {
                // Если ответ не соответствует ожиданиям, создаем и возвращаем ошибку
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            // Декодируем JSON-ответ в объект Product
            do {
                let createdProduct = try JSONDecoder().decode(Product.self, from: data)
                // Если декодирование успешно, вызываем completion с результатом успеха
                completion(.success(createdProduct))
            } catch {
                // Если декодирование не удалось, вызываем completion с ошибкой
                completion(.failure(error))
            }
        }
        
        // Запускаем задачу
        task.resume()
    }
    
    // Метод для обновления продукта
    func updateProduct(_ product: Product, completion: @escaping (Result<Product, Error>) -> Void) {
        // Проверяем, что URL для обновления продукта правильный
        guard let url = URL(string: "http://127.0.0.1:8080/api/products/\(product.id)") else { return }
        
        // Создаем объект URLRequest с указанным URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT" // Устанавливаем HTTP-метод PUT
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // Устанавливаем заголовок Content-Type как application/json
        
        // Получаем токен из Keychain
        if let tokenData = AppKeychainService().getData(forKey: "authToken"),
           let token = String(data: tokenData, encoding: .utf8) {
            // Устанавливаем заголовок Authorization с токеном
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Создаем JSON без ID
        let updateProductData: [String: Any] = [
            "name": product.name,
            "price": product.price,
            "description": product.description
        ]
        
        // Кодируем объект Product в JSON и устанавливаем его как тело запроса
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updateProductData, options: [])
            urlRequest.httpBody = jsonData
        } catch {
            // Если кодирование не удалось, вызываем completion с ошибкой и выходим
            completion(.failure(error))
            return
        }
        
        // Создаем задачу URLSession для отправки запроса
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Если возникла ошибка при отправке запроса, вызываем completion с ошибкой и выходим
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем, что ответ имеет статус 200 OK или 204 No Content
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
                // Если ответ не соответствует ожиданиям, создаем и возвращаем ошибку
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            // Если сервер не возвращает данные, вызываем успех без декодирования данных
            completion(.success(product))
        }
        
        // Запускаем задачу
        task.resume()
    }
    
    
    // Метод для удаления продукта
    func deleteProduct(productId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        // Проверяем, что URL для удаления продукта правильный
        guard let url = URL(string: "http://127.0.0.1:8080/api/products/\(productId)") else { return }
        
        // Создаем объект URLRequest с указанным URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE" // Устанавливаем HTTP-метод DELETE
        
        // Получаем токен из Keychain
        if let tokenData = AppKeychainService().getData(forKey: "authToken"),
           let token = String(data: tokenData, encoding: .utf8) {
            // Устанавливаем заголовок Authorization с токеном
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Создаем задачу URLSession для отправки запроса
        let task = URLSession.shared.dataTask(with: urlRequest) { _, response, error in
            // Если возникла ошибка при отправке запроса, вызываем completion с ошибкой и выходим
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем, что ответ имеет статус 200 OK или 204 No Content
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
                // Если ответ не соответствует ожиданиям, создаем и возвращаем ошибку
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            // Если удаление успешно, вызываем completion с результатом успеха
            completion(.success(()))
        }
        
        // Запускаем задачу
        task.resume()
    }
}
