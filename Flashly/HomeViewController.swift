//
//  ViewController.swift
//  Flashly
//
//  Created by Ronaldo Avalos on 08/12/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var studyGroups: [String] = [] // Array para almacenar los grupos de estudio
    private let studyGroupManager = StudyGroupManager() // Manager para manejar UserDefaults
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 112, height: 112)  // Tamaño de las celdas
        layout.minimumInteritemSpacing = 10  // Espacio entre columnas (horizontal)
        layout.minimumLineSpacing = 10  // Espacio entre filas (vertical)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 14, bottom: 80, right: 14)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(StudyGroupCell.self, forCellWithReuseIdentifier: "StudyGroupCell")
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStudyGroups() // Cargar los grupos al iniciar
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Flashcards"
        view.backgroundColor = .systemBackground
        
        // Add UIBarButtonItem to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddGroup)
        )
        
        // Add and constrain collectionView
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Management
    private func loadStudyGroups() {
        studyGroups = studyGroupManager.fetchGroups()
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func didTapAddGroup() {
        let alertController = UIAlertController(title: "Nuevo Grupo", message: "Ingresa el nombre del grupo de estudio", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Nombre del grupo"
        }
        let addAction = UIAlertAction(title: "Añadir", style: .default) { [weak self] _ in
            guard let self = self, let groupName = alertController.textFields?.first?.text, !groupName.isEmpty else { return }
            self.studyGroups = self.studyGroupManager.addGroup(groupName) // Guardar y actualizar el array
            self.collectionView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return studyGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudyGroupCell", for: indexPath) as? StudyGroupCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: studyGroups[indexPath.item])
        // Añadir interacción de menú contextual
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupName = studyGroups[indexPath.item]
        let studyGroupVC = StudyGroupViewController(groupName: groupName)
        navigationController?.pushViewController(studyGroupVC, animated: true)
    }

}

// MARK: - UIContextMenuInteractionDelegate
extension HomeViewController: UIContextMenuInteractionDelegate {
    
    // Implementar el menú contextual
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return nil }
        _ = studyGroups[indexPath.item]
        
        let editAction = UIAction(title: "Editar", image: UIImage(systemName: "pencil")) { _ in
            self.didTapEditGroup(at: indexPath)
        }
        
        let deleteAction = UIAction(title: "Eliminar", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.didTapDeleteGroup(at: indexPath)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func didTapEditGroup(at indexPath: IndexPath) {
        let groupName = studyGroups[indexPath.item]
        let alertController = UIAlertController(title: "Editar Grupo", message: "Ingresa un nuevo nombre para el grupo", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = groupName
        }
        
        let saveAction = UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            guard let self = self, let newGroupName = alertController.textFields?.first?.text, !newGroupName.isEmpty else { return }
            self.studyGroups[indexPath.item] = newGroupName
            self.studyGroupManager.saveGroups(self.studyGroups)
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func didTapDeleteGroup(at indexPath: IndexPath) {
        let groupName = studyGroups[indexPath.item]
        let alertController = UIAlertController(title: "Eliminar Grupo", message: "¿Estás seguro de que quieres eliminar el grupo \(groupName)?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.studyGroups.remove(at: indexPath.item)
            self.studyGroupManager.saveGroups(self.studyGroups)
            self.collectionView.deleteItems(at: [indexPath])
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - StudyGroupCell
class StudyGroupCell: UICollectionViewCell {
    
    private let folderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "folder.fill") // Ícono de carpeta
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(folderImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            folderImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            folderImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            folderImageView.widthAnchor.constraint(equalToConstant: 60),
            folderImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: folderImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
        
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}

