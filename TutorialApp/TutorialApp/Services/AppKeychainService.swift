//
//  AppKeychainService.swift
//  TutorialApp
//
//  Created by Илья on 02.07.2024.
//

import Foundation

// Протокол для сервиса работы с Keychain
protocol KeychainService {
    func setData(_ data: Data, forKey key: String)
    func getData(forKey key: String) -> Data?
    func removeData(forKey key: String)
    func clearKeychain()
}

import Security
import Foundation

// Реализация сервиса работы с Keychain
final class AppKeychainService: KeychainService {
    // MARK: - Properties

    private let service: String // Название сервиса

    // MARK: - Initialization
    // Инициализация с указанием названия сервиса
    init(service: String = "ru.ilka.TutorialApp") {
        self.service = service
    }

    // MARK: - Keychain Access
    // Сохранение данных в Keychain
    func setData(_ data: Data, forKey key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String : Any]

        // Добавление данных в Keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            // Если элемент уже существует, обновляем его
            let updateQuery = [
                kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
            ] as [String : Any]

            let attributesToUpdate = [
                kSecValueData as String: data
            ] as [String : Any]

            SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
        } else if status != errSecSuccess {
            print("Failed to set data in Keychain. Status: \(status)")
        }
    }

    // Получение данных из Keychain
    func getData(forKey key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ] as [String : Any]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        } else if status != errSecItemNotFound {
            print("Failed to get data from Keychain. Status: \(status)")
        }

        return nil
    }

    // Удаление данных из Keychain
    func removeData(forKey key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ] as [String : Any]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            print("Failed to remove data from Keychain. Status: \(status)")
        }
    }
    
    // Очистка всех данных из Keychain для данного сервиса
    func clearKeychain() {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: service
        ] as [String: Any]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            print("Failed to clear Keychain. Status: \(status)")
        }
    }
}
