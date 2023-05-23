//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Fixed on 17.05.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let complection: () -> ()
}
