//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Fixed on 12.06.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showNextQuestion(quiz model: QuizStepViewModel) {
        
    }
    func setImageViewBorders(responseType: String) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    func hideLoadingIndicator() {
        
    }
    
    func changeButtonsState(state: Bool) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

