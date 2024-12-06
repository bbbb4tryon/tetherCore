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
            header
            input
            toSubmit_Button
        }
        .padding()
        .alert(
            "Error",
            isPresented: Binding(
                get: {  coreVM.error != nil },
                set: { if !$0 { coreVM.clearError() }}
            ),
            actions: { Button("OK") { coreVM.clearError() }},
            message: { Text(coreVM.error?.message ?? "" )}
        )
        .sheet(item: $coreVM.currentModal) { modalType in
            ModalView(
                type: modalType,
                onComplete: { coreVM.handleModalAction(for: modalType, action: .complete) },
                onInProgress: { coreVM.handleModalAction(for: modalType, action: .inProgress) },
                onCancel: { coreVM.handleModalAction(for: modalType, action: .cancel) }
            )
        }
    }
    private var header: some View {
        get {
            Text("Pull yourself back to center")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.theme.primaryBlue)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .padding(.vertical, 20)
                .shadow(color: Color.theme.primaryBlue.opacity(0.2), radius: 2, y: 2)
                .animation(.easeInOut, value: buttonWasPressed)
        }
    }
    private var input: some View {
        TextField( "Required", text: $coreVM.currentTetherText )
            .accessibilityIdentifier("Required")
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 20)
            .frame(maxWidth: 300)
            .shadow(color: Color.theme.primaryBlue.opacity(0.1), radius: 5)
            .focused($field)
            .onSubmit {
                buttonWasPressed = true     //JUST the action, not the whole button view
                coreVM.submitTether()
            }
    }
    private var toSubmit_Button: some View {
        Button(action: {
            buttonWasPressed = true //Ties a Declaration/State + public, for testing; then see testButton() in testing
            coreVM.submitTether()
        }){
            Text("Done")
                .fontWeight(.semibold)
                .foregroundStyle(Color.theme.buttonText)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
        }
        .accessibilityIdentifier("Done")
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.theme.primaryBlue)
        )
        .shadow(radius: 5)
        .opacity(coreVM.currentTetherText.isEmpty ? 0.6 : 1)
        .animation(.easeInOut, value: coreVM.currentTetherText.isEmpty)
    }
}
#Preview {
    CoreView()
}
//func validate(){
//    guard !coreVM.currentTetherText.isEmpty else { return }
//}
