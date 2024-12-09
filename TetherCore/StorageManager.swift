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
    let maxCoils = 25
    
    ///[Function][Async][ProfileStorageManager][-> ProfileCoil]
    func loadCoils() async throws  -> [Coil] {
        guard let data = defaults.data(forKey: coilsKey),
                  let coils = try? JSONDecoder().decode([Coil].self, from: data) else {
                    return []
                }
                return coils
        }

    ///[Function][Async][ProfileStorageManager][-> Void]
    func saveCoil(_ coil: Coil) async throws {
        var coils = try await loadCoils()
        coils.insert(coil, at: 0)   ///Adds new coil at the top
        
        ///Only keep 25 most-recent coils
        if coils.count > maxCoils {
            coils = Array(coils.prefix(maxCoils))
        }
        
        /// Saves the coils - Do not need another or any save()
        try await saveCoils(coils)
    }
        
    func moveCoilToCompleted(_ coil: Coil) async throws {
        var coils = try await loadCoils()
        if let index = coils.firstIndex(where: { $0.id == coil.id }) {
            coils[index] = coil
            try await saveCoils(coils)
        }
    }
    
    private func saveCoils(_ coils: [Coil]) async throws {
        let data = try JSONEncoder().encode(coils)
        defaults.set(data, forKey: coilsKey)
    }
}
