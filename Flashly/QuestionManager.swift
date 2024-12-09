//
//  QuestionManager.swift
//  Flashly
//
//  Created by Ronaldo Avalos on 08/12/24.
//

import Foundation
import Foundation

struct QuestionManager {
    private let userDefaults = UserDefaults.standard
    private let key = "StudyGroupQuestions"
    
    // Estructura para almacenar pregunta y respuesta
    struct Question: Codable {
        let question: String
        let answer: String
    }
    
    // Recuperar preguntas para un grupo específico
    func fetchQuestions(for groupName: String) -> [Question] {
        guard let data = userDefaults.data(forKey: "\(key)_\(groupName)"),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            return []
        }
        return questions
    }
    
    // Guardar preguntas para un grupo específico
    func saveQuestions(_ questions: [Question], for groupName: String) {
        if let data = try? JSONEncoder().encode(questions) {
            userDefaults.set(data, forKey: "\(key)_\(groupName)")
        }
    }
    
    // Agregar una pregunta a un grupo específico
    func addQuestion(_ question: Question, to groupName: String) -> [Question] {
        var questions = fetchQuestions(for: groupName)
        questions.append(question)
        saveQuestions(questions, for: groupName)
        return questions
    }
}
