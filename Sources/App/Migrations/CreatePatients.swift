//
//  File.swift
//  
//
//  Created by Tanish Bhowmick on 5/27/24.
//

import Fluent

struct CreatePatients: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("patients")
            .id()
            .field("therapist_id", .uuid, .references("users", "id"))
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("referenceCode", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("patients").delete()
    }
}
