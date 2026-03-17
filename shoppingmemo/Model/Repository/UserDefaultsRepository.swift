//
//  UserDefaultsRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/17.
//

import Foundation

class UserDefaultsRepository {
    static let userDefaults: UserDefaults = .standard
    
    //save
    static func save(data: Any, key: String) {
        userDefaults.set(data, forKey: key)
    }
    
    //get
    static func get<T>(_ type: T.Type, key: String) -> T? {
        userDefaults.value(forKey: key) as? T
    }
    
    //delete
    static func delete(key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
