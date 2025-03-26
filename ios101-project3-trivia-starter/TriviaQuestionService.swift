//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Stacey A on 3/22/25.
//

import Foundation

class TriviaQuestionService {
    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]) -> Void) {
        // Multiple-choice questions URL
        let mcUrlString = "https://opentdb.com/api.php?amount=5&category=9&difficulty=easy&type=multiple"
        // True/False questions URL
        let tfUrlString = "https://opentdb.com/api.php?amount=3&type=boolean"
        
        let group = DispatchGroup()
        var triviaQuestions: [TriviaQuestion] = []

        // Fetch multiple-choice questions
        group.enter()
        fetchQuestions(from: mcUrlString) { questions in
            triviaQuestions.append(contentsOf: questions)
            group.leave()
        }
        
        // Fetch true/false questions
        group.enter()
        fetchQuestions(from: tfUrlString) { questions in
            triviaQuestions.append(contentsOf: questions)
            group.leave()
        }

        // Wait for both fetches to complete
        group.notify(queue: .main) {
            triviaQuestions.shuffle() // Randomize the combined list
            completion(triviaQuestions)
        }
    }
    
    private func fetchQuestions(from urlString: String, completion: @escaping ([TriviaQuestion]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching trivia questions: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                print("No data received")
                completion([])
                return
            }

            do {
                let apiResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                let triviaQuestions = apiResponse.results.map { apiQuestion in
                    var allAnswers = apiQuestion.incorrect_answers
                    allAnswers.append(apiQuestion.correct_answer)
                    allAnswers.shuffle() // Randomize answer order
                    
                    return TriviaQuestion(
                        question: apiQuestion.question,
                        answers: allAnswers,
                        correctAnswer: apiQuestion.correct_answer
                    )
                }
                completion(triviaQuestions)
            } catch {
                print("Failed to decode JSON: \(error)")
                completion([])
            }
        }.resume()
    }
}
