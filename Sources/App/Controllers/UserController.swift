//
//  File.swift
//  
//
//  Created by Tanish Bhowmick on 5/28/24.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        usersRoute.post("signup", use: createHandler)
        usersRoute.post("login", use: loginHandler)
//        usersRoute.get("me", use: getUserHandler)
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        do {
            let user = try req.content.decode(User.self)
            user.passwordHash = try Bcrypt.hash(user.passwordHash)
            if user.role == .therapist {
                user.referenceCode = generateReferenceCode(for: user.name)
            }
            
            return user.save(on: req.db).map { user }
        } catch {
            req.logger.error("Failed to create user: \(error.localizedDescription)")
            throw Abort(.badRequest, reason: "Invalid request data.")
        }
    }
    
    func loginHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        return User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                do {
                    if try Bcrypt.verify(loginRequest.password, created: user.passwordHash) {
                        // Generate a token or session here if needed
                        return req.eventLoop.makeSucceededFuture(user)
                    } else {
                        return req.eventLoop.makeFailedFuture(Abort(.unauthorized))
                    }
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
            }
    }
    
    func getUserHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.auth.require(User.self)
        return req.db.query(User.self)
            .filter(\.$id == user.id!)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    private func generateReferenceCode(for username: String) -> String {
        let randomNumbers = String(format: "%06d", Int.random(in: 0..<1000000))
        let sanitizedUsername = username.replacingOccurrences(of: " ", with: "").lowercased()
        return "\(sanitizedUsername)\(randomNumbers)"
    }
}
