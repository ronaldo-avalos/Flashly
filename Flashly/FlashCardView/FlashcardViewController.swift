//  FlashcardViewController.swift
//  Flashly
//
//  Created by Ronaldo Avalos on 09/12/24.

import UIKit

class FlashcardViewController: UIViewController {
    
    // MARK: - Properties
    private var flashcards: [(question: String, answer: String, image: UIImage?)] = [
         ("¿Qué es una célula?", "La unidad básica de la vida.", UIImage(named: "humano")),
         ("¿Qué es ADN?", "Ácido desoxirribonucleico.", nil),
         ("¿Qué es el sol?", "Una estrella en el centro del sistema solar.", UIImage(named: "heart"))
     ]
     private var currentIndex = 0
     private var showingQuestion = true
     
    
    // Card View
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardImageView: UIImageView = {
          let imageView = UIImageView()
          imageView.contentMode = .scaleAspectFit
          imageView.translatesAutoresizingMaskIntoConstraints = false
          imageView.isHidden = true
          return imageView
      }()
    
    private let cardLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Buttons
    private lazy var previousButton: UIButton = createButton(title: "Anterior", action: #selector(didTapPrevious))
    private lazy var playButton: UIButton = createButton(title: "Play", action: #selector(didTapPlay))
    private lazy var nextButton: UIButton = createButton(title: "Siguiente", action: #selector(didTapNext))
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        updateCardContent()
    }
    
    // MARK: - UI Setup
    private var labelTopConstraint: NSLayoutConstraint!
    private var labelCenterYConstraint: NSLayoutConstraint!

    private func setupUI() {
        view.backgroundColor = .accent

        // Card View Setup
        view.addSubview(cardView)
        cardView.addSubview(cardImageView)
        cardView.addSubview(cardLabel)

        labelTopConstraint = cardLabel.topAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: 22)
        labelCenterYConstraint = cardLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        
        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            cardImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),
            cardImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardImageView.heightAnchor.constraint(equalTo: cardView.heightAnchor, multiplier: 0.6),

            labelTopConstraint,
            cardLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
        
        // Buttons Setup
        let stackView = UIStackView(arrangedSubviews: [previousButton, playButton, nextButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPlay))
        view.addGestureRecognizer(tapGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    @objc private func didTapPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        animateCardTransition(direction: .right)
    }
    
    @objc private func didTapPlay() {
        let transitionOption: UIView.AnimationOptions = showingQuestion ? .transitionFlipFromTop : .transitionFlipFromBottom
        UIView.transition(
            with: cardView,
            duration: 0.5,
            options: [transitionOption],
            animations: {
                self.showingQuestion.toggle()
                self.updateCardContent()
            }
        )
    }

    
    @objc private func didTapNext() {
        guard currentIndex < flashcards.count - 1 else { return }
        currentIndex += 1
        animateCardTransition(direction: .left)
    }
    
    @objc private func didSwipeLeft() {
        didTapNext()
    }
    
    @objc private func didSwipeRight() {
        didTapPrevious()
    }
    
    // MARK: - Helpers
    private func updateCardContent() {
        let currentFlashcard = flashcards[currentIndex]
        cardLabel.text = showingQuestion ? currentFlashcard.question : currentFlashcard.answer

        if let image = currentFlashcard.image, showingQuestion {
            cardImageView.image = image
            cardImageView.isHidden = false
            
            // Activar restricciones relacionadas con la imagen
            labelTopConstraint.isActive = true
            labelCenterYConstraint.isActive = false
        } else {
            cardImageView.isHidden = true
            
            // Activar restricciones para centrar el texto
            labelTopConstraint.isActive = false
            labelCenterYConstraint.isActive = true
        }
        
        // Forzar actualización de restricciones
        cardView.layoutIfNeeded()
    }


    
    private func animateCardTransition(direction: AnimationDirection) {
        let offset = direction == .right ? view.frame.width : -view.frame.width
        let originalFrame = cardView.frame
        
        UIView.animate(withDuration: 0.3, animations: {
            self.cardView.frame = self.cardView.frame.offsetBy(dx: offset, dy: 0)
            self.cardView.alpha = 0
        }, completion: { _ in
            self.cardView.frame = originalFrame.offsetBy(dx: -offset, dy: 0)
            self.updateCardContent()
            UIView.animate(withDuration: 0.3) {
                self.cardView.frame = originalFrame
                self.cardView.alpha = 1
            }
        })
    }
}

// MARK: - Animation Direction Enum
private enum AnimationDirection {
    case left, right
}
