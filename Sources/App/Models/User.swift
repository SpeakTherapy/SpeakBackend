//
//  User.swift
//
//
//  Created by Tanish Bhowmick on 5/28/24.
//

import Foundation
import Fluent
import Vapor

final class User: Model, Content, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "passwordHash")
    var passwordHash: String
    
    @Field(key: "role")
    var role: UserRole
    
    @OptionalField(key: "referenceCode")
    var referenceCode: String?
    
    @Children(for: \.$therapist)
    var patients: [Patient]
    
    init() { }

    init(id: UUID? = nil, name: String, email: String, passwordHash: String, role: UserRole, referenceCode: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
        self.referenceCode = referenceCode
    }
}

extension User {
    // Public user data
    struct Public: Content {
        var id: UUID?
        var name: String
        var email: String
        var role: UserRole
        var referenceCode: String?
    }
    
    func convertToPublic() -> Public {
        return Public(id: id, name: name, email: email, role: role, referenceCode: referenceCode)
    }
}



