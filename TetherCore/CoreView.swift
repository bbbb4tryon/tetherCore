//
//  CoreView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import SwiftUI
import Foundation


struct CoreView: View {                             /// - Note: Conforms to Error, GlobalError, and LocalizedError protocols; IS for normal use
    @EnvironmentObject private var coordinator: TetherCoordinator
    @StateObject private var coreVM: CoreViewModel
    @FocusState private var field: Bool             /// - Note: For testing - comment out or in
    @State public var buttonWasPressed = false      /// Making a Declaration/State + public, for testing
    @State public var showProgress = false
    
    let showTimer: Bool = false
    
    init(countdownType: CountdownTypes = .production){
        let coordinator = TetherCoordinator()
            _coreVM = StateObject(wrappedValue: CoreViewModel(
                timerType: countdownType, coordinator: coordinator
            ))
    }
    var body: some View {
        NavigationStack {
            VStack(spacing: 20){
                header
                
                VStack(alignment: .leading,spacing: 16){
                    input
                    progressDisplay
                    
                    ///Show and display first tether, second tether
                    switch coreVM.currentState {
                    case .firstTether(let tether):
                        TetherRowView(coordinator: coordinator, tether: tether, onZero: false)
                    case .secondTether(let coil):
                        TetherRowView(coordinator: coordinator, tether: coil.tether1, onZero: coreVM.isTether1Completed)
                        TetherRowView(coordinator: coordinator, tether: coil.tether2, onZero: coreVM.isTether2Completed)
                    case .completed(_):
                        EmptyView()
                    case .empty:
                        EmptyView()
                    }
                    
                    clearData_Button
                    submit_Button
                    
                    
                    ///Pushes content up ~ vertical centering
                    Spacer()
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { coordinator.navigate(to: .home) }) {
                            Image(systemName: "chevron.left")
                                .imageScale(.large)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(item: $coordinator.currentModal) { modalType in
                ModalView(
                    type: modalType,
                    coreVM: coreVM,
                    onAction: { action in
                        await handleModalPresentation(modalType)
                    }
                )
                .environmentObject(coordinator)
                    .task { /// Handles async on appear
                        await handleModalPresentation(modalType)
                    }
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
            coreVM.currentState.inputPlaceholder,
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
                Task {
                    try? await coreVM.submitTether()
                }
            }
    }
    
    private var progressDisplay: some View {
        Group {
            if coordinator.showClock {
                TimePieceView(
                    seconds: coreVM.countDownAmt,
                    showProgress: true,
                    label: "Tethered",
                    onZero: nil
                )
                .environmentObject(coordinator)
            }
        }
    }

    private var clearData_Button: some View {
        Button(action: {
            buttonWasPressed = true
            Task {
                await coreVM.clearEverythingFromUI()
            }
        }) {
            Text("Clear Data")
                .fontWeight(.semibold)
                .foregroundStyle(Color.theme.buttonText)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.theme.primaryBlue)
            )
            .shadow(radius: 5)
            .opacity(coreVM.currentState == .empty ? 0.6 : 1)        /// or coreVM.currentTetherText.isEmpty?
            .animation(.easeInOut, value: coreVM.currentTetherText.isEmpty)
        }

    private var submit_Button: some View {
        Button(action: {
            buttonWasPressed = true     ///tied to @State, is 'public' for testing via `testButton()` in testing
            Task {
                try? await coreVM.submitTether()       ///this calls submit
            }
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
        .environmentObject(TetherCoordinator())
        .environment(\.colorScheme, .light)
}
//func validate(){
//    guard !coreVM.currentTetherText.isEmpty else { return }
//}
