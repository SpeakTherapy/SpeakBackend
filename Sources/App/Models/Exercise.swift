//
//  Exercise.swift
//
//
//  Created by Tanish Bhowmick on 5/28/24.
//

import Foundation
import Fluent
import Vapor

final class Exercise: Model, Content {
    static let schema = "exercises"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "category")
    var category: String
    
    @Siblings(through: PatientExercise.self, from: \.$exercise, to: \.$patient)
    var patients: [Patient]
    
    init() { }

    init(id: UUID? = nil, title: String, description: String, category: String) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
    }
}
