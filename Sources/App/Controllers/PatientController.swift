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

        patientsRoute.get(":userID", use: getHandler)
        patientsRoute.put(":patientID", "link", use: linkToTherapistHandler)
        patientsRoute.put(":patientID", "assign", ":exerciseID", use: assignExerciseHandler)
        patientsRoute.get("all", ":therapistID", use: getAllPatientsHandler)
    }

    @Sendable
    func getHandler(_ req: Request) async throws -> Patient {
        // Get the userID from the request parameters
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // Query the Patient model using the userID
        guard let patient = try await Patient.query(on: req.db)
            .filter(\.$user.$id == userID)
            .with(\.$user)
            .with(\.$therapist)
            .first()
        else {
            throw Abort(.notFound)
        }

        return patient
    }

    @Sendable
    func linkToTherapistHandler(_ req: Request) async throws -> Patient {
        let patientID = try req.parameters.require("patientID", as: UUID.self)
        let linkRequest = try req.content.decode(LinkRequest.self)

        // Find the User with the given patientID
        guard let user = try await User.find(patientID, on: req.db), user.role == .patient else {
            throw Abort(.notFound, reason: "Patient user not found.")
        }

        // Find the Patient record using the user's ID
        guard let patient = try await Patient.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .first()
        else {
            throw Abort(.notFound, reason: "Patient record not found.")
        }

        // Find the Therapist using the reference code
        guard let therapist = try await User.query(on: req.db)
            .filter(\.$referenceCode == linkRequest.referenceCode)
            .filter(\.$role == .therapist)
            .first()
        else {
            throw Abort(.notFound, reason: "Invalid reference code.")
        }

        // Link the patient to the therapist
        patient.$therapist.id = therapist.id!
        try await patient.save(on: req.db)

        return patient
    }


    @Sendable
    func assignExerciseHandler(_ req: Request) async throws -> HTTPStatus {
        let patientID = try req.parameters.require("patientID", as: UUID.self)
        let exerciseID = try req.parameters.require("exerciseID", as: UUID.self)

        let patientExercise = PatientExercise(patientID: patientID, exerciseID: exerciseID)
        try await patientExercise.save(on: req.db)
        return .ok
    }

    @Sendable
    func getAllPatientsHandler(_ req: Request) async throws -> [Patient] {
        let therapistID = try req.parameters.require("therapistID", as: UUID.self)

        return try await Patient.query(on: req.db)
            .filter(\.$therapist.$id == therapistID)
            .with(\.$user)  // Eager load the user information
            .all()
    }
}
