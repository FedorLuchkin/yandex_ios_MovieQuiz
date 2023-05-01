import UIKit

// TODO: move structures and mock-data to separate files

// MARK: - Structs
private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

// MARK: - Mock-data
private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]

// MARK: - Controller
final class MovieQuizViewController: UIViewController {
    
    // MARK: - Controller class fields
    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Controller class methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func showNextQuestion(quiz model: QuizStepViewModel) {
        counterLabel.text = model.questionNumber
        imageView.image = model.image
        textLabel.text = model.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrRoundResults()
        }
    }
    
    private func showRoundResult(model: QuizResultsViewModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.text,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let viewModel = self.convert(model: questions[self.currentQuestionIndex])
            self.showNextQuestion(quiz: viewModel)
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func showNextQuestionOrRoundResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/10",
                buttonText: "Сыграть ещё раз")
            showRoundResult(model: viewModel)
        } else {
            currentQuestionIndex += 1
            let viewModel = convert(model: questions[currentQuestionIndex])
            showNextQuestion(quiz: viewModel)
        }
    }
    
    @IBAction private func noButtonClicked() {
        let correctAnswer: Bool = questions[currentQuestionIndex].correctAnswer
        showAnswerResult(isCorrect: correctAnswer == false)
    }
    
    @IBAction private func yesButtonClicked() {
        let correctAnswer: Bool = questions[currentQuestionIndex].correctAnswer
        showAnswerResult(isCorrect: correctAnswer == true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        let viewModel = convert(model: questions[currentQuestionIndex])
        showNextQuestion(quiz: viewModel)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
