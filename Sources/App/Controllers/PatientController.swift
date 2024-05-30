//
//  PatientController.swift
//
//
//  Created by Tanish Bhowmick on 5/28/24.
//

import Vapor
import Fluent

struct PatientController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let patientsRoute = routes.grouped("patients")
        patientsRoute.post(use: createHandler)
        patientsRoute.get(":patientID", use: getHandler)
        patientsRoute.put(":patientID", "link", use: linkToTherapistHandler)
        patientsRoute.put(":patientID", "assign", ":exerciseID", use: assignExerciseHandler)
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let patientRequest = try req.content.decode(User.self)
        var patient = User(name: patientRequest.name, email: patientRequest.email, passwordHash: patientRequest.passwordHash, role: .patient)
        patient.passwordHash = try Bcrypt.hash(patient.passwordHash)
        return patient.save(on: req.db).map { patient }
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<User> {
        User.find(req.parameters.get("patientID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func linkToTherapistHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let patientID = try req.parameters.require("patientID", as: UUID.self)
        let linkRequest = try req.content.decode(LinkRequest.self)
        
        return User.find(patientID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { patient in
                return User.query(on: req.db)
                    .filter(\.$referenceCode == linkRequest.referenceCode)
                    .first()
                    .unwrap(or: Abort(.notFound, reason: "Invalid reference code."))
                    .flatMap { therapist in
                        let patientModel = Patient(therapistID: therapist.id!, referenceCode: therapist.referenceCode!)
                        patientModel.$therapist.id = therapist.id!
                        return patientModel.save(on: req.db).transform(to: .ok)
                    }
            }
    }
    
    func assignExerciseHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let patientID = try req.parameters.require("patientID", as: UUID.self)
        let exerciseID = try req.parameters.require("exerciseID", as: UUID.self)
        
        let patientExercise = PatientExercise(patientID: patientID, exerciseID: exerciseID)
        return patientExercise.save(on: req.db).transform(to: .ok)
    }
}
