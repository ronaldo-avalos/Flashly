//
//  AddQuestionViewController.swift
//  Flashly
//
//  Created by Ronaldo Avalos on 08/12/24.
//

import Foundation
import UIKit

class AddQuestionViewController: UIViewController {
    
    // MARK: - Properties
    var onSave: ((String, String) -> Void)? // Callback para guardar la pregunta
    
    private let questionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Escribe la pregunta"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let answerTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Escribe la respuesta"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Guardar", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(questionTextField)
        view.addSubview(answerTextField)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            questionTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            questionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            answerTextField.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 12),
            answerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            answerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            saveButton.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func didTapSave() {
        guard let question = questionTextField.text, !question.isEmpty,
              let answer = answerTextField.text, !answer.isEmpty else {
            return
        }
        onSave?(question, answer)
        dismiss(animated: true, completion: nil)
    }
}
