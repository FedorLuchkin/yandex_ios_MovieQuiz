import UIKit


// MARK: - Controller
final class MovieQuizViewController: UIViewController {
    
    // MARK: - Controller class fields
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?

    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Controller class methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
        )
    }
    
    private func showNextQuestion(quiz model: QuizStepViewModel) {
        counterLabel.text = model.questionNumber
        imageView.image = model.image
        textLabel.text = model.question
    }
    
    private func showAnswerResult(isCorrect: Bool, sender: UIButton) {
        imageView.layer.borderWidth = 8
        
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrRoundResults()
            sender.isEnabled = true
        }
    }
    
    private func showNextQuestionOrRoundResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionAmount)
            let date = statisticService.bestGame.date.dateTimeString
            let message = """
                Ваш результат: \(correctAnswers)/\(questionAmount)\n\
                Количесство сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(date))
                Средняя точность: \(statisticService.totalAccuracy)
            """
            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                        message: message,
                                        buttonText: "Сыграть ещё раз",
                                        complection: { [weak self] in
                                            guard let self = self else { return }
                                            self.currentQuestionIndex = 0
                                            self.correctAnswers = 0
                                            self.questionFactory?.requestNextQuestion()
                                        })
            alertPresenter?.showAlert(model: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        sender.isEnabled = false
        let correctAnswer: Bool = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: correctAnswer == false, sender: sender)
    }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        sender.isEnabled = false
        let correctAnswer: Bool = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: correctAnswer == true, sender: sender)
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showNextQuestion(quiz: viewModel)
        }
    }
}
