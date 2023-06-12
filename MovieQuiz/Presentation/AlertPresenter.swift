//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Fixed on 17.05.2023.
//

import UIKit

protocol AlertPresenterProtocol {
    func showAlert(model: AlertModel)
}

class AlertPresenter: AlertPresenterProtocol {
    weak private var delegate: MovieQuizViewController?
    
    init(delegate: MovieQuizViewController) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        // alert.accessibilityLabel = "Game results"
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true)
    }
}
