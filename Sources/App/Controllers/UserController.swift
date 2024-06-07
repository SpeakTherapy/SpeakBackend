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
        usersRoute.put(":userID", "link", use: linkToTherapistHandler)
        usersRoute.get(":userID", use: getUserHandler)
        usersRoute.get("therapist", ":referenceCode", use: getTherapistHandler)
//        usersRoute.get("me", use: getUserHandler)
    }
    
    @Sendable
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let userRequest = try req.content.decode(CreateUserRequest.self)
        let user = User(name: userRequest.name, email: userRequest.email, passwordHash: try Bcrypt.hash(userRequest.passwordHash), role: userRequest.role)

        if user.role == .therapist {
            user.referenceCode = generateReferenceCode(for: user.name)
        }

        return user.save(on: req.db).flatMap {
            if user.role == .patient {
                let patient = Patient(userID: user.id!, referenceCode: userRequest.referenceCode ?? "")
                return patient.save(on: req.db).map { user }
            } else {
                return req.eventLoop.makeSucceededFuture(user)
            }
        }
    }
    
    @Sendable
    func loginHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        return User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                do {
                    if try Bcrypt.verify(loginRequest.passwordHash, created: user.passwordHash) {
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
    
    @Sendable
    func getUserHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let userID = try req.parameters.require("userID", as: UUID.self)
        return req.db.query(User.self)
            .filter(\.$id == userID)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    @Sendable
    func linkToTherapistHandler(_ req: Request) async throws -> User {
        let userID = try req.parameters.require("userID", as: UUID.self)
        let linkRequest = try req.content.decode(LinkRequest.self)
        
        // Find the User with the given patientID and add reference code from link request to User
        guard let user = try await User.find(userID, on: req.db), user.role == .patient else {
            throw Abort(.notFound, reason: "Patient not found.")
        }
        user.referenceCode = linkRequest.referenceCode
        
        try await user.save(on: req.db)
        return user
    }
    
    @Sendable
    func getTherapistHandler(_ req: Request) async throws -> User {
        let referenceCode = try req.parameters.require("referenceCode", as: String.self)
        
        guard let therapist = try await User.query(on: req.db)
            .filter(\.$role == .therapist)
            .filter(\.$referenceCode == referenceCode)
            .first() else {
            throw Abort(.notFound, reason: "Therapist not found.")
        }
        
        return therapist
    }
    
    private func generateReferenceCode(for username: String) -> String {
        let randomNumbers = String(format: "%06d", Int.random(in: 0..<1000000))
        let sanitizedUsername = username.replacingOccurrences(of: " ", with: "").lowercased()
        return "\(sanitizedUsername)\(randomNumbers)"
    }
}
