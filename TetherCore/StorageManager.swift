//
//  StorageManager.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import Foundation

//[Protocol][Conformance StorageManaging][Storage][-> Void]
actor TetherStorageManager {
    private let defaults = UserDefaults.standard
    private let coilsKey = "stored_coils"
    private let maxCoils = 25
    
    func saveCoil(_ coil: Coil) async throws {
        var coils = await loadCoils()
        coils.insert(coil, at: 0)   ///Adds new coil at the top
        
        ///Maintain max limit
        if coils.count > maxCoils {
            coils = Array(coils.prefix(maxCoils))
        }
        
        /// Saves the coils - Do not need another or any save()
        let encoder = JSONEncoder()
        let data = try encoder.encode(coils)
        defaults.set(data, forKey: coilsKey)

    }
    
    func loadCoils() async -> [Coil] {
        guard let data = defaults.data(forKey: coilsKey),
              let coils = try? JSONDecoder().decode([Coil].self, from: data) else {
            return []
        }
        return coils
    }
}
