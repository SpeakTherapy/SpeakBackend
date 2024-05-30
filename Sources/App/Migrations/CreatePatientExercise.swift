//
//  File.swift
//  
//
//  Created by Tanish Bhowmick on 5/27/24.
//

import Fluent

struct CreatePatientExercise: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("patient_exercise")
            .id()
            .field("patient_id", .uuid, .required, .references("patients", "id"))
            .field("exercise_id", .uuid, .required, .references("exercises", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("patient_exercise").delete()
    }
}
