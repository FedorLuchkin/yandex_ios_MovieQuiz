//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Fixed on 12.06.2023.
//

import UIKit

final class MovieQuizPresenter {
    let questionAmount: Int = 10
    var correctAnswers = 0
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewControllerProtocol?
    var alertPresenter: AlertPresenterProtocol?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServiceProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory?.loadData()
        self.statisticService = StatisticServiceImplementation()
        guard let viewController = viewController as? MovieQuizViewController else { return }
        self.alertPresenter = AlertPresenter(delegate: viewController)
        self.viewController?.showLoadingIndicator()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func switchToPreviousQuestion() {
        currentQuestionIndex -= 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
        )
    }
    
    func ButtonClicked(currentAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        viewController?.changeButtonsState(state: false)
        let correctAnswer: Bool = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: correctAnswer == currentAnswer)
    }
    
    func showNextQuestionOrRoundResults() {
        viewController?.setImageViewBorders(responseType: "New question")
        if isLastQuestion() {
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
                    self.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.viewController?.showLoadingIndicator()
                    self.questionFactory?.requestNextQuestion()
                })
            alertPresenter?.showAlert(model: alertModel)
            viewController?.hideLoadingIndicator()
        } else {
            switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            viewController?.setImageViewBorders(responseType: "True")
        } else {
            viewController?.setImageViewBorders(responseType: "False")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrRoundResults()
        }
    }
    
    func resetGame() {
        resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.loadData()
        viewController?.changeButtonsState(state: true)
    }
    
    func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                self?.resetGame()
            })
        alertPresenter?.showAlert(model: alertModel)
    }
    
    func showImageLoadError(message: String) {
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                self?.showNextQuestionOrRoundResults()
            })
        alertPresenter?.showAlert(model: alertModel)
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showNextQuestion(quiz: viewModel)
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.changeButtonsState(state: true)
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
            self?.viewController?.changeButtonsState(state: false)
            self?.viewController?.hideLoadingIndicator()
            self?.switchToPreviousQuestion()
            self?.showImageLoadError(message: error.localizedDescription)
        }
    }
}
