//
//  StudyGroupViewController.swift
//  Flashly
//
//  Created by Ronaldo Avalos on 08/12/24.
//
import UIKit

class StudyGroupViewController: UIViewController {
    
    // MARK: - Properties
    private var questions: [QuestionManager.Question] = [] // Array para almacenar las preguntas
      private let studyGroupName: String // Nombre del grupo de estudio
      private let questionManager = QuestionManager() // Manager de preguntas
      
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuestionCell.self, forCellReuseIdentifier: "QuestionCell")
        return tableView
    }()
    
    // MARK: - Initializer
      init(groupName: String) {
          self.studyGroupName = groupName
          super.init(nibName: nil, bundle: nil)
          self.questions = questionManager.fetchQuestions(for: groupName)
      }
      
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = studyGroupName
        view.backgroundColor = .systemBackground
        
        // Add UIBarButtonItem for adding questions
        navigationItem.rightBarButtonItems = [
             UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddQuestion)),
             UIBarButtonItem(title: "Editar", style: .plain, target: self, action: #selector(didTapEdit))
         ]
        
        // Add and constrain tableView
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func didTapEdit() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItems?[1].title = tableView.isEditing ? "Hecho" : "Editar"
    }

    
    // MARK: - Actions
    @objc private func didTapAddQuestion() {
        let addQuestionVC = AddQuestionViewController()
        addQuestionVC.onSave = { [weak self] question, answer in
            guard let self = self else { return }
            let newQuestion = QuestionManager.Question(question: question, answer: answer)
            self.questions = self.questionManager.addQuestion(newQuestion, to: self.studyGroupName)
            self.tableView.reloadData()
        }
        let navController = UINavigationController(rootViewController: addQuestionVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension StudyGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as? QuestionCell else {
            return UITableViewCell()
        }
        let question = questions[indexPath.row]
        cell.configure(question: question.question, answer: question.answer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question = questions[indexPath.row]
        print("Pregunta: \(question.question), Respuesta: \(question.answer)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        // Eliminar pregunta del array
        questions.remove(at: indexPath.row)
        questionManager.saveQuestions(questions, for: studyGroupName)
        // Eliminar fila de la tabla con animación
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

class QuestionCell: UITableViewCell {
    
    // MARK: - Properties
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let answerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(questionLabel)
        contentView.addSubview(answerLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 4),
            answerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            answerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            answerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(question: String, answer: String) {
        questionLabel.text = question
        answerLabel.text = "Respuesta: \(answer)"
    }
}
