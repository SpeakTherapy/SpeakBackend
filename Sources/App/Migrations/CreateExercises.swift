//
//  File.swift
//  
//
//  Created by Tanish Bhowmick on 5/27/24.
//

import Fluent

struct CreateExercises: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("exercises")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("category", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("exercises").delete()
    }
}

