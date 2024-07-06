//
//  UserService.swift
//  TutorialApp
//
//  Created by Илья on 05.07.2024.
//

import CoreData

// Класс для управления данными пользователя с использованием Core Data
class UserService {
    // Создаем синглтон экземпляр класса
    static let shared = UserService()
    
    // Ленивая инициализация контейнера Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model") // Инициализация контейнера с именем "Model"
        container.loadPersistentStores { _, error in
            if let error = error {
                // Если произошла ошибка при загрузке контейнера, приложение завершится с ошибкой
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    // Контекст для работы с данными
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Метод для сохранения изменений в контексте
    func saveContext() {
        if context.hasChanges {
            do {
                // Пытаемся сохранить изменения в контексте
                try context.save()
            } catch {
                let nserror = error as NSError
                // Если произошла ошибка при сохранении, приложение завершится с ошибкой
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Метод для очистки данных пользователя
    func clearData() {
        // Создаем запрос на выборку всех данных сущности "User"
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        // Создаем запрос на удаление данных, соответствующих запросу выборки
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            // Пытаемся выполнить запрос на удаление данных
            try context.execute(deleteRequest)
            saveContext() // Сохраняем контекст после удаления данных
        } catch {
            let nserror = error as NSError
            // Если произошла ошибка при удалении данных, приложение завершится с ошибкой
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
