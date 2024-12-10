//  FlashcardViewController.swift
//  Flashly
//
//  Created by Ronaldo Avalos on 09/12/24.

import UIKit

class FlashcardViewController: UIViewController, SwipeCardViewProtocol {
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var flashCardsData: [FlashCardModel] = []
    private var cards: [SwipeCardView] = []
    private var cardInitialLocationCenter: CGPoint!
    private var panInitialLocation: CGPoint!
    private var discardedCard: SwipeCardView?
    private var discardedCardPosition: CGPoint?
    private var discardedCardDirection: CGFloat?
    private var playTimer: Timer?
    private var discardedCardsStack: [(card: SwipeCardView, position: CGPoint, direction: CGFloat)] = []
    
    
    
    // MARK: - UI Elements
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("←", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("▶", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        return button
    }()
    
    
    private let flipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("↻", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .systemGreen
        progress.trackTintColor = .lightGray.withAlphaComponent(0.4)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let cardCounterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .accent
        initialSetup()
        setupProgressView()
        setupButtons()
    }
    
    private func setupProgressView() {
        view.addSubview(progressView)
        view.addSubview(cardCounterLabel)
        
        // Constraints para la barra de progreso
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -42),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            // Constraints para el contador de tarjetas
            cardCounterLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            cardCounterLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor, constant: -15)
        ])
        
        updateProgress()
    }

    // MARK: - Setup Buttons
    private func setupButtons() {
        view.addSubview(buttonStackView)
        
        // Añadir botones al stack
        [backButton, playButton, flipButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        // Configurar acciones para cada botón
        backButton.addTarget(self, action: #selector(recoverCard), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playCards), for: .touchUpInside)
        flipButton.addTarget(self, action: #selector(flipTopCard), for: .touchUpInside)
        
        // Constraints del stack
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
        ])
    }
    
    private func initialSetup() {
        view.addSubview(cardContainerView)
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            cardContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ])

        flashCardsData = FlashCardModel.questions()
        
        DispatchQueue.main.async {
            self.flashCardsData.forEach { (question) in
                self.setupCard(cardInfo: question)
            }
            self.updateProgress() // Progreso inicial
        }
    }

    
    private func setupCard(cardInfo: FlashCardModel) {
        let cardView = SwipeCardView(frame: cardContainerView.bounds)
        cardView.question = cardInfo
        cardView.delegate = self
        cards.append(cardView)
        cardContainerView.addSubview(cardView)
        cardContainerView.sendSubviewToBack(cardView)
        
        setupTransforms()
        
        // Agregar gestos de flip y pan a cada tarjeta
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
        
        //        if cards.count == 1 {
        // Configuración inicial para la tarjeta superior
        cardInitialLocationCenter = cardView.center
        cardView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
        //        }
    }
    
    @objc private func flipCard(_ gesture: UITapGestureRecognizer) {
        guard let card = gesture.view as? SwipeCardView else { return }
        
        // Animación de flip
        UIView.transition(with: card, duration: 0.5, options: .transitionFlipFromTop, animations: {
            // Cambiar el contenido de la tarjeta al reverso
            card.isFlipped.toggle() // Variable booleana que indica si la tarjeta está volteada
            
            if card.isFlipped {
                card.showAnswer() // Método para mostrar el contenido del reverso
            } else {
                card.showQuestion() // Método para mostrar la pregunta
            }
        }, completion: nil)
    }
    
    @objc func pan(gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view as? SwipeCardView else { return }
        let translation = gesture.translation(in: cardContainerView)
        
        switch gesture.state {
        case .changed:
            // Permitir el movimiento libre
            card.center = CGPoint(
                x: cardInitialLocationCenter.x + translation.x,
                y: cardInitialLocationCenter.y + translation.y
            )
            
            // Mostrar "like" o "nope" según la dirección del movimiento
            if translation.x > 0 {
                card.likeView.alpha = abs(translation.x * 2) / cardContainerView.bounds.midX
                card.nopeView.alpha = 0
            } else {
                card.nopeView.alpha = abs(translation.x * 2) / cardContainerView.bounds.midX
                card.likeView.alpha = 0
            }
            
        case .ended:
            let threshold: CGFloat = 100 // Umbral para descartar la tarjeta
            let velocity = gesture.velocity(in: cardContainerView)
            
            if abs(translation.x) > threshold || abs(velocity.x) > 500 {
                let direction: CGFloat = translation.x > 0 ? 1 : -1
                let offScreenX = cardInitialLocationCenter.x + (1000 * direction)
                
                // Guardar la tarjeta descartada en la pila
                discardedCardsStack.append((card: card, position: card.center, direction: direction))
                
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: offScreenX, y: self.cardInitialLocationCenter.y)
                }) { _ in
                    card.removeFromSuperview()
                    self.updateProgress()
                    self.updateCards(card: card)
                }
                
            } else {
                // Regresar la tarjeta a su posición original
                UIView.animate(withDuration: 0.3) {
                    card.center = self.cardInitialLocationCenter
                    card.likeView.alpha = 0
                    card.nopeView.alpha = 0
                    card.transform = CGAffineTransform.identity
                }
            }
            
        default:
            break
        }
    }
    
   
    
    
    func updateCards(card: SwipeCardView) {
        if let index = self.cards.firstIndex(where: { $0.question.id == card.question.id }) {
            // Eliminar la tarjeta del stack visible
            self.cards.remove(at: index)
            
            // Mover la tarjeta al stack de descartadas
            self.discardedCardsStack.append((card: card, position: cardInitialLocationCenter, direction: 1))
        } else {
            print("Error: La tarjeta no fue encontrada en la lista de tarjetas activas.")
        }
        setupTransforms()
    }

    
    
    func setupTransforms() {
        for (index, card) in cards.enumerated() {
            // Ignore for top most card view
            if index == 0 { continue }
            
            // Add transform for only few cards behind the top most card
            if index > 3 { return }
            
            var transform = CGAffineTransform.identity
            if index % 2 == 0 {
                // Transforming to right side
                transform = transform.translatedBy(x: CGFloat(index) * 2, y: 0)
                transform = transform.rotated(by: CGFloat(Double.pi) / 150 * CGFloat(index))
            } else {
                // Transforming to left side
                transform = transform.translatedBy(x: -CGFloat(index) * 2, y: 0)
                transform = transform.rotated(by: -CGFloat(Double.pi) / 150 * CGFloat(index))
            }
            card.transform = transform
        }
    }
    
    private func updateProgress() {
        let totalCards = flashCardsData.count
        let discardedCards = discardedCardsStack.count
        let currentCardIndex = totalCards - cards.count + 1 // Posición actual de la tarjeta
        let progress = totalCards > 0 ? Float(discardedCards) / Float(totalCards) : 0.0

        // Actualiza la barra de progreso
        progressView.setProgress(progress, animated: true)

        // Actualiza el contador de tarjetas
        if cards.isEmpty {
            cardCounterLabel.text = "¡Terminaste!"
        } else {
            cardCounterLabel.text = "\(currentCardIndex) / \(totalCards)"
        }
    }



    
    // MARK: - Button Actions
    
    @objc func recoverCard() {
        guard let lastDiscarded = discardedCardsStack.popLast() else { return }
        let discardedCard = lastDiscarded.card

        // Reagregar la tarjeta al stack visible
        self.cards.insert(discardedCard, at: 0)

        // Reagregar la tarjeta a la vista
        cardContainerView.addSubview(discardedCard)
        cardContainerView.bringSubviewToFront(discardedCard)

        // Animar el regreso de la tarjeta al centro original
        discardedCard.center = CGPoint(
            x: cardInitialLocationCenter.x + (1000 * lastDiscarded.direction),
            y: cardInitialLocationCenter.y
        )

        UIView.animate(withDuration: 0.5, animations: {
            discardedCard.center = self.cardInitialLocationCenter
            discardedCard.transform = .identity
            discardedCard.likeView.alpha = 0
            discardedCard.nopeView.alpha = 0
        }) { _ in
            self.setupTransforms()
            self.updateProgress()
        }
    }

    
    @objc private func nextCard() {
        guard let topCard = cards.first else { return }
        let offScreenX = cardInitialLocationCenter.x + 1000 // Descartar hacia la derecha
        UIView.animate(withDuration: 0.3, animations: {
            topCard.center = CGPoint(x: offScreenX, y: self.cardInitialLocationCenter.y)
        }) { _ in
            topCard.removeFromSuperview()
            self.updateCards(card: topCard)
            self.updateProgress() // Actualizar progreso después de descartar
        }
    }

    @objc private func flipTopCard() {
        guard let topCard = cards.first else { return }
        UIView.transition(with: topCard, duration: 0.5, options: .transitionFlipFromTop, animations: {
            topCard.isFlipped.toggle()
            if topCard.isFlipped {
                topCard.showAnswer()
            } else {
                topCard.showQuestion()
            }
        }, completion: nil)
    }
    
    @objc private func playCards() {
        if let timer = playTimer {
            // Si ya está reproduciendo, detener
            timer.invalidate()
            playTimer = nil
            playButton.setTitle("▶", for: .normal) // Cambiar de nuevo al ícono de play
            playButton.backgroundColor = .systemGreen
            return
        }
        
        // Cambiar el botón a "stop"
        playButton.setTitle("■", for: .normal)
        playButton.backgroundColor = .systemRed
        
        guard !cards.isEmpty else { return }
        
        var currentIndex = 0
        playTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            guard currentIndex < self.cards.count else {
                timer.invalidate()
                self.playTimer = nil
                self.playButton.setTitle("▶", for: .normal) // Cambiar al ícono de play
                self.playButton.backgroundColor = .systemGreen
                return
            }
            
            // Girar la tarjeta actual
            self.flipTopCard()
            
            // Avanzar a la siguiente tarjeta tras 1.5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.nextCard()
                currentIndex += 1
            }
        }
    }
    
    
    // MARK: - Delegates
    func didUserInfoTapped(user: FlashCardModel) {
        print("perform your action on click user card view....")
    }
}
