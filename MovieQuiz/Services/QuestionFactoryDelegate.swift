//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Fixed on 17.05.2023.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didFailToLoadImage(with error: Error)
}
