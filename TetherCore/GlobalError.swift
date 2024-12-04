//
//  GlobalError.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import SwiftUI

// MARK - Base Error Types (global.swift)
/// ErrorTypes: GlobalError
///     var: message
///     let: dismiss - don't add any text
protocol GlobalError: Error {
    var message: String { get }
}

struct ErrorAlert: View {
    let message: String
    let dismiss: () -> Void
    
    var body: some View {
        VStack {
            Text(message)
            Button("OK", action: dismiss)
        }
    }
}

