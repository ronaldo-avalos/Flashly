//
//  CardView.swift
//  Flashly
//
//  Created by Ronaldo Avalos on 09/12/24.
//

import Foundation
import UIKit
// MARK: - CardView Class


protocol SwipeCardViewProtocol {
    func didUserInfoTapped(user: FlashCardModel)
}

class SwipeCardView: UIView {
    
    private let cardImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.isHidden = true
            return imageView
        }()
      
      private let questionLabel: UILabel = {
          let label = UILabel()
          label.textAlignment = .center
          label.textColor = .black
          label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
          label.numberOfLines = 0
          label.translatesAutoresizingMaskIntoConstraints = false
          return label
      }()
    
    let likeView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.borderColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1).cgColor
        view.transform = CGAffineTransform(rotationAngle: -.pi / 8)
        view.backgroundColor = .white
        return view
    }()
    
    let likeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: "LIKE", attributes:[.font : UIFont.boldSystemFont(ofSize: 28)])
        label.textColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1)
        return label
    }()
    
    let nopeView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.borderColor = UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1).cgColor
        view.transform = CGAffineTransform(rotationAngle: .pi / 8)
        view.backgroundColor = .white
        return view
    }()
    
    let nopeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: "NOPE", attributes:[.font : UIFont.boldSystemFont(ofSize: 28)])
        label.textColor = UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1)
        return label
    }()
    
    var question: FlashCardModel! {
        didSet {
            cardImageView.image = UIImage(named: self.question.imageName ?? "")
            questionLabel.text = question.question
        }
    }
    
    var delegate: SwipeCardViewProtocol?

    var isFlipped = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 6
        isUserInteractionEnabled = true
        let views = [cardImageView, questionLabel]
        views.forEach(addSubview(_:))
        // Set constraints for profileImageView
        let labelTopConstraint = questionLabel.topAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: 22)
        let labelCenterYConstraint = questionLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    //
        NSLayoutConstraint.activate([

            cardImageView.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            cardImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cardImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cardImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            
            labelCenterYConstraint,
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    func showAnswer() {
          // Cambiar el contenido de la tarjeta para mostrar la respuesta
        self.questionLabel.text = question.answer // Cambia esto según tus datos
      }


      func showQuestion() {
          // Cambiar el contenido de la tarjeta para mostrar la pregunta
          self.questionLabel.text = question.question // Cambia esto según tus datos
      }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleInfo() {
        print("Card info tapped")
            delegate?.didUserInfoTapped(user: self.question)
        
    }

}
