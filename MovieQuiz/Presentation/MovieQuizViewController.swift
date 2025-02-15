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
    private var moviesLoader: MoviesLoadingProtocol?
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Controller class methods
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func changeButtonsState(state: Bool) {
        noButton.isEnabled = state
        yesButton.isEnabled = state
    }
    
    private func resetGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
        changeButtonsState(state: true)
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                self?.resetGame()
            })
        alertPresenter?.showAlert(model: alertModel)
    }
    
    private func showImageLoadError(message: String) {
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                self?.showNextQuestionOrRoundResults()
            })
        alertPresenter?.showAlert(model: alertModel)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrRoundResults()
        }
    }
    
    private func showNextQuestionOrRoundResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionAmount)
            let date = statisticService.bestGame.date.dateTimeString
            let totalAccuracy = (String(format: "%.2f", statisticService.totalAccuracy) + "%")
            let message = """
                Ваш результат: \(correctAnswers)/\(questionAmount)\n\
                Количесство сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(date))
                Средняя точность: \(totalAccuracy)
            """
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.activityIndicator.startAnimating()
                    self.questionFactory?.requestNextQuestion()
                })
            alertPresenter?.showAlert(model: alertModel)
            activityIndicator.stopAnimating()
        } else {
            currentQuestionIndex += 1
            activityIndicator.startAnimating()
            questionFactory?.requestNextQuestion()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        changeButtonsState(state: false)
        let correctAnswer: Bool = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: correctAnswer == false)
    }
    
    @IBAction private func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        changeButtonsState(state: false)
        let correctAnswer: Bool = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: correctAnswer == true)
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
            self?.activityIndicator.stopAnimating()
            self?.changeButtonsState(state: true)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadImage(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.changeButtonsState(state: false)
            self?.activityIndicator.stopAnimating()
            self?.currentQuestionIndex -= 1
            self?.showImageLoadError(message: error.localizedDescription)
        }
    }
}
