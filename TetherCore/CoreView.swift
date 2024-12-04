//
//  CoreView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import SwiftUI


struct CoreView: View {
    @StateObject private var coreVM = CoreViewModel() /// Handles storage-related errors in the core view model
    /// - Note: Conforms to Error, GlobalError, and LocalizedError protocols
    @FocusState private var field: Bool
    @State public var buttonWasPressed = false  //Making a Declaration/State + public, for testing
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
            header
            input
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: {  coreVM.error != nil },
                set: { if !$0 { coreVM.clearError() }}
            ),
            actions: { Button("OK") { coreVM.clearError() }},
            message: { Text(coreVM.error?.message ?? "" )}
        )
    }
    private var header: some View {
        get {
            Text("Pull yourself back to center")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
    private var input: some View {
        TextField(
            "Required",
            text: $coreVM.currentTetherText
        )
        .accessibilityIdentifier("Required")
        .focused($field)
        .onSubmit {
            buttonWasPressed = true     //JUST the action, not the whole button view
        }
    }
    private var toSubmit_Button: some View {
        Button(action: {
            buttonWasPressed = true //Ties a Declaration/State + public, for testing; then see testButton() in testing
        }){
            Text("Done")
        }
        .accessibilityIdentifier("Done")
    }
}
#Preview {
    CoreView()
}
//func validate(){
//    guard !coreVM.currentTetherText.isEmpty else { return }
//}
