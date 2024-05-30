//
//  PatientExercise.swift
//
//
//  Created by Tanish Bhowmick on 5/28/24.
//

import Foundation
import Fluent
import Vapor

final class PatientExercise: Model {
    static let schema = "patient_exercise"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "patient_id")
    var patient: Patient
    
    @Parent(key: "exercise_id")
    var exercise: Exercise
    
    init() { }

    init(patientID: UUID, exerciseID: UUID) {
        self.$patient.id = patientID
        self.$exercise.id = exerciseID
    }
}
