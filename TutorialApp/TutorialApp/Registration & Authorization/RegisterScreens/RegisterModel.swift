//
//  RegisterModel.swift
//  TutorialApp
//
//  Created by Илья on 01.07.2024.
//

import Foundation

struct RegisterModel {
    var username: String?
    var email: String?
    var password: String?
}

struct RegistrationRequest: Codable {
    let username: String
    let password: String
    let email: String
    let secretResponse: String
}

struct RegistrationResponse: Codable {
    let id: Int
    let token: String
}
