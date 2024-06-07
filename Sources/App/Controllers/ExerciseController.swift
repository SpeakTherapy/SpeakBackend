//
//  ExerciseController.swift
//
//
//  Created by Tanish Bhowmick on 5/28/24.
//

import Foundation
import Vapor
import Fluent

struct ExerciseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let exercisesRoute = routes.grouped("exercises")
        exercisesRoute.post(use: createHandler)
        exercisesRoute.get(use: getAllHandler)
    }
    
    @Sendable
    func createHandler(_ req: Request) throws -> EventLoopFuture<Exercise> {
        let exercise = try req.content.decode(Exercise.self)
        return exercise.save(on: req.db).map { exercise }
    }
    
    @Sendable
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Exercise]> {
        Exercise.query(on: req.db).all()
    }
}
