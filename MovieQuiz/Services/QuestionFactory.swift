//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Fixed on 17.05.2023.
//

import Foundation

public enum CustomError: Error {
    case emptyItems(errorMessage: String)
    case imageLoadError
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyItems(let errorMessage):
            return NSLocalizedString(errorMessage, comment: "Client error")
        case .imageLoadError:
            return NSLocalizedString("Image load error", comment: "Image load error")
        }
    }
}

class QuestionFactory: QuestionFactoryProtocol {
    
    private var movies: [MostPopularMovie] = []
    private var questionNumbers: [Int] = []
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoadingProtocol
    
    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            // with replay protection
            if self.questionNumbers.count == 0 {
                self.questionNumbers = Array(0 ... self.movies.count - 1).shuffled()
            }
            
            guard let index = self.questionNumbers.first else {
                self.delegate?.didReceiveNextQuestion(question: nil)
                return
            }
            
            self.questionNumbers.removeFirst()
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                let error: Error = CustomError.imageLoadError
                self.delegate?.didFailToLoadImage(with: error)
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let mark = Array(4 ... 9).randomElement() ?? 7
            var text = ""
            var correctAnswer = false
            if Int(10 * rating) % 2 == 0 {
                text = "Рейтинг этого фильма больше чем \(mark)?"
                correctAnswer = rating > Float(mark)
            } else {
                text = "Рейтинг этого фильма меньше чем \(mark)?"
                correctAnswer = rating < Float(mark)
            }
            
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.items.isEmpty {
                        let error: Error = CustomError.emptyItems(errorMessage: mostPopularMovies.errorMessage)
                        self.delegate?.didFailToLoadData(with: error)
                    } else {
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
