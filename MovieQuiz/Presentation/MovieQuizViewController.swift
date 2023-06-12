import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showNextQuestion(quiz model: QuizStepViewModel)
    func setImageViewBorders(responseType: String)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func changeButtonsState(state: Bool)
}

// MARK: - Controller
final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Controller class fields
    
    var alertPresenter: AlertPresenterProtocol?
    private var moviesLoader: MoviesLoadingProtocol?
    private var presenter: MovieQuizPresenter!
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Controller class methods
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func changeButtonsState(state: Bool) {
        noButton.isEnabled = state
        yesButton.isEnabled = state
    }
    
    func setImageViewBorders(responseType: String) {
        switch responseType {
        case "True":
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        case "False":
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        default:
            imageView.layer.borderWidth = 0
        }
    }
    
    func showNextQuestion(quiz model: QuizStepViewModel) {
        counterLabel.text = model.questionNumber
        imageView.image = model.image
        textLabel.text = model.question
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func noButtonClicked() {
        presenter.ButtonClicked(currentAnswer: false)
    }
    
    @IBAction private func yesButtonClicked() {
        presenter.ButtonClicked(currentAnswer: true)
    }
}
