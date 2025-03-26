//
//  TriviaViewController.swift
//  Trivia
//
//  Created by Stacey A on 3/12/25.
//

import UIKit

class TriviaViewController: UIViewController {

    

    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerButton1: UIButton!
    
    @IBOutlet weak var answerButton2: UIButton!
    
    @IBOutlet weak var answerButton3: UIButton!
    
    @IBOutlet weak var answerButton4: UIButton!
    
    @IBOutlet weak var YayOrNayLabel: UILabel!
    
    @IBOutlet weak var questionTrackerLabel: UILabel!

    let triviaService = TriviaQuestionService()

    
       var questions: [TriviaQuestion] = []
       var currentQuestionIndex = 0
       var correctAnswersCount = 0
    

       
    override func viewDidLoad() {
            super.viewDidLoad()
            fetchQuestions()
        }
    
    func fetchQuestions() {
            triviaService.fetchTriviaQuestions { questions in
                self.questions = questions
                self.currentQuestionIndex = 0
                self.correctAnswersCount = 0
                self.updateUI()
            }
        }

    
    @IBAction func answerClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
            
            // Check if the selected answer is correct
            if sender.currentTitle == currentQuestion.correctAnswer {
                YayOrNayLabel.text = "Correct!"
                YayOrNayLabel.textColor = .green
                correctAnswersCount += 1
            } else {
                YayOrNayLabel.text = "Wrong! The correct answer is: \(currentQuestion.correctAnswer)"
                YayOrNayLabel.textColor = .red
            }
            
            // Show feedback
            YayOrNayLabel.isHidden = false
            
            // Disable all answer buttons temporarily
            let buttons = [answerButton1, answerButton2, answerButton3, answerButton4]
            buttons.forEach { $0?.isEnabled = false }
            
            // Delay before moving to the next question to allow users to see the feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Move to the next question
                self.currentQuestionIndex += 1
                if self.currentQuestionIndex >= self.questions.count {
                    self.showResults()
                } else {
                    self.updateUI()
                    self.YayOrNayLabel.isHidden = true
                }
                
                // Re-enable the answer buttons for the next question
                buttons.forEach { $0?.isEnabled = true }
            }
        }
            
            func updateUI() {
                guard currentQuestionIndex < questions.count else { return }
                
                let currentQuestion = questions[currentQuestionIndex]
                questionLabel.text = currentQuestion.question
                
                // Show/hide answer buttons based on the number of answers
                let buttons = [answerButton1, answerButton2, answerButton3, answerButton4]
                for (index, button) in buttons.enumerated() {
                    if index < currentQuestion.answers.count {
                        button?.setTitle(currentQuestion.answers[index], for: .normal)
                        button?.isHidden = false
                    } else {
                        button?.isHidden = true
                    }
                }
                
                questionTrackerLabel.text = "Question \(currentQuestionIndex + 1) of \(questions.count)"
            }
            
            func showResults() {
                let alert = UIAlertController(
                    title: "Quiz Complete!",
                    message: "You got \(correctAnswersCount) out of \(questions.count) correct!",
                    preferredStyle: .alert
                )
                
                let restartAction = UIAlertAction(title: "Restart", style: .default) { _ in
                    self.fetchQuestions()
                    self.YayOrNayLabel.isHidden = true
                }
                alert.addAction(restartAction)
                
                present(alert, animated: true, completion: nil)
            }
        }
