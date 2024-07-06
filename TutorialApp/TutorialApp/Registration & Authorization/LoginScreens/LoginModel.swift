//
//  LoginModel.swift
//  TutorialApp
//
//  Created by Илья on 01.07.2024.
//

import Foundation

struct LoginModel {
    var username: String?
    var password: String?
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let id: Int
    let token: String
}
