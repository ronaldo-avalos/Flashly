//
//  StudyGroupManager.swift
//  Flashly
//
//  Created by Ronaldo Avalos on 08/12/24.
//

import Foundation
import Foundation

struct StudyGroupManager {
    private let userDefaults = UserDefaults.standard
    private let key = "StudyGroups"
    
    // Recuperar los grupos guardados
    func fetchGroups() -> [String] {
        return userDefaults.stringArray(forKey: key) ?? []
    }
    
    // Guardar los grupos en UserDefaults
    func saveGroups(_ groups: [String]) {
        userDefaults.set(groups, forKey: key)
    }
    
    // Agregar un nuevo grupo
    func addGroup(_ group: String) -> [String] {
        var groups = fetchGroups()
        groups.append(group)
        saveGroups(groups)
        return groups
    }
}
