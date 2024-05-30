//
//  Patient.swift
//  
//
//  Created by Tanish Bhowmick on 5/28/24.
//

import Foundation
import Fluent
import Vapor

final class Patient: Model, Content {
    static let schema = "patients"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "therapist_id")
    var therapist: User
    
    @Siblings(through: PatientExercise.self, from: \.$patient, to: \.$exercise)
    var exercises: [Exercise]
    
    @Field(key: "referenceCode")
    var referenceCode: String
    
    init() { }

    init(id: UUID? = nil, therapistID: UUID, referenceCode: String) {
        self.id = id
        self.$therapist.id = therapistID
        self.referenceCode = referenceCode
    }
}
