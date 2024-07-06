//
//  AboutViewController.swift
//  TutorialApp
//
//  Created by Илья on 05.07.2024.
//

import UIKit
import MapKit

// Класс для отображения информации о приложении
class AboutViewController: UIViewController {
    
    // UI элементы для отображения информации
    private let mapView = MKMapView()
    private let appNameLabel = UILabel()
    private let versionLabel = UILabel()
    private let developerLabel = UILabel()
    private let addressLabel = UILabel()

    // Метод, вызываемый при загрузке представления
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Устанавливаем цвет фона
        setupUI() // Настраиваем пользовательский интерфейс
        setupMap() // Настраиваем карту и добавляем метку
    }
    
    // Метод для настройки пользовательского интерфейса
    private func setupUI() {
        // Отключаем автоматическое создание ограничений для элементов
        mapView.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        developerLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Настраиваем шрифт и выравнивание для метки названия приложения
        appNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        appNameLabel.textAlignment = .center
        
        // Получаем название приложения из информации о пакете
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            appNameLabel.text = appName
        }
        
        // Настраиваем шрифт и выравнивание для метки версии приложения
        versionLabel.font = UIFont.systemFont(ofSize: 18)
        versionLabel.textAlignment = .center
        
        // Получаем версию приложения из информации о пакете
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Версия: \(appVersion)"
        }
        
        // Настраиваем шрифт и выравнивание для метки разработчика
        developerLabel.font = UIFont.systemFont(ofSize: 18)
        developerLabel.textAlignment = .center
        developerLabel.text = "Разработчик: ilka"
        
        // Настраиваем шрифт и выравнивание для метки адреса
        addressLabel.font = UIFont.systemFont(ofSize: 18)
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0 // Разрешаем многострочный текст
        addressLabel.text = "Адрес: Покровский бульвар д.11с10,\nМосква, Россия"
        
        // Добавляем элементы на представление
        view.addSubview(mapView)
        view.addSubview(appNameLabel)
        view.addSubview(versionLabel)
        view.addSubview(developerLabel)
        view.addSubview(addressLabel)
        
        // Устанавливаем ограничения для элементов
        NSLayoutConstraint.activate([
            // Ограничения для карты
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            mapView.widthAnchor.constraint(equalToConstant: 200),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            
            // Ограничения для названия приложения
            appNameLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            appNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Ограничения для версии
            versionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 10),
            versionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Ограничения для разработчика
            developerLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 10),
            developerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            developerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Ограничения для адреса
            addressLabel.topAnchor.constraint(equalTo: developerLabel.bottomAnchor, constant: 10),
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Метод для настройки карты и добавления метки
    private func setupMap() {
        // Координаты для метки (пример: Москва, Россия)
        let coordinate = CLLocationCoordinate2D(latitude: 55.753448, longitude: 37.648232)
        
        // Создаем аннотацию (метку) и устанавливаем ее координаты и заголовок
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Адрес"
        
        // Добавляем метку на карту
        mapView.addAnnotation(annotation)
        
        // Устанавливаем регион карты с центром в указанных координатах
        mapView.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
        
        // Настраиваем карту как круг
        mapView.layer.cornerRadius = 100
        mapView.clipsToBounds = true
    }
}
