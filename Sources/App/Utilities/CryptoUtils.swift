//
//  File.swift
//  
//
//  Created by Tanish Bhowmick on 5/27/24.
//

import Vapor

struct CryptoUtils {
    static func hashPassword(_ password: String) throws -> String {
        try Bcrypt.hash(password)
    }
    
    static func verifyPassword(_ password: String, hash: String) throws -> Bool {
        try Bcrypt.verify(password, created: hash)
    }
}
