//
//  CoreView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import SwiftUI
import Foundation


struct CoreView: View {
    //    @StateObject private var coreVM = CoreViewModel() /// Handles storage-related errors in the core view model
    /// - Note: Conforms to Error, GlobalError, and LocalizedError protocols; IS for normal use
    @StateObject private var coreVM = CoreViewModel(testing: true)
    /// - Note: For testing - comment out or in
    @FocusState private var field: Bool
    @State public var buttonWasPressed = false  //Making a Declaration/State + public, for testing
    let show: Bool = false
    
    var body: some View {
        NavigationStack {
        VStack(spacing: 20){
            header
            input
            ///Show first tether, if it is entered
            if let tether = coreVM.temporaryTether {
                DisplayUnderInput(tether: tether, onClear:  coreVM.clearTetherUponMistake)
            }
            toSubmit_Button
            ///Pushes content up ~ vertical centering
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                onCancel: { coreVM.handleModalAction(for: modalType, action: .cancel) },
                coreVM: coreVM
            )
        }
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
        /// Input field with dynamic placeholder
        TextField(
            coreVM.temporaryTether == nil ? "Required" : "Enter One More",
            text: $coreVM.currentTetherText
        )
            .accessibilityIdentifier("Required")
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 20)
            .frame(maxWidth: 300)
            .focused($field)
            .shadow(color: Color.theme.primaryBlue.opacity(0.1), radius: 5)
            .submitLabel(.done)
            .onSubmit {
                buttonWasPressed = true     //JUST the action, not the whole button view
                coreVM.submitTether()
            }
    }

    private var toSubmit_Button: some View {
        Button(action: {
            buttonWasPressed = true     ///tied to @State, is 'public' for testing via `testButton()` in testing
            coreVM.submitTether()       ///this calls submit
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
