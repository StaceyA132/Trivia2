//
//  Questions.swift
//  Trivia
//
//  Created by Stacey A on 3/12/25.
//
import Foundation

struct TriviaResponse: Codable {
    let results: [APIQuestion]
}

struct APIQuestion: Codable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct TriviaQuestion {
    let question: String
    let answers: [String]
    let correctAnswer: String
}
