//
//  LoginRequest.swift
//
//
//  Created by Tanish Bhowmick on 5/28/24.
//

import Vapor

struct LoginRequest: Content {
    var email: String
    var passwordHash: String
}

struct CreateUserRequest: Content {
    var name: String
    var email: String
    var passwordHash: String
    var role: UserRole
    var referenceCode: String?
}

struct PatientRegistrationRequest: Content {
    var name: String
    var email: String
    var passwordHash: String
    var referenceCode: String
}

struct LinkRequest: Content {
    var referenceCode: String
}
