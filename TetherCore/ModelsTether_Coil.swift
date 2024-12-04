//
//  ModelsTether_Coil.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/4/24.
//

import SwiftUI

/// [Model: 'ModelTether' ][Conformance: Identifiable, Codable]['Storage' Data Type][-> Tether]
struct Tether: Identifiable, Codable {
    let id: UUID
    var tetherText: String
    var completionStatus: Bool
    var timeStamp: Date
    init(tetherText: String, completionStatus: Bool = false){
        self.id = UUID()
        self.tetherText = tetherText
        self.completionStatus = completionStatus
        self.timeStamp = Date()
    }
}

///[Mode: 'ModelCoil'][Conformance: Identifiable, Codable]['Storage' Data Type][-> Tether]
struct Coil: Identifiable, Codable {
    let id: UUID
    var tether1: Tether
    var tether2: Tether
    var completionStatus: Bool
    var timeStamp: Date
    init(tether1: Tether, tether2: Tether, completionStatus: Bool, timeStamp: Date) {
        self.id = UUID()
        self.tether1 = tether1
        self.tether2 = tether2
        self.completionStatus = false
        self.timeStamp = Date()
    }
}

