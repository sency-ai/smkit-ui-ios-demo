//
//  MainView.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var authModel = AuthManager.shared
    let startWasPressed:()->Void
    let startAssessmentWasPressed:()->Void
    let startCustomAssessmet:()->Void
    let uiSettingsWasPressed:()->Void

    private func workoutButton(_ title: String, action: @escaping ()->Void) -> some View {
        Button {
            if authModel.didFinishAuth { action() }
        } label: {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).stroke())
        }
        .overlay(
            ZStack {
                if !authModel.didFinishAuth {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .padding()
                }
            },
            alignment: .trailing
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            workoutButton("START", action: startWasPressed)
            workoutButton("START ASSESSMENT", action: startAssessmentWasPressed)
            workoutButton("START CUSTOM ASSESSMENT", action: startCustomAssessmet)

            Button(action: uiSettingsWasPressed) {
                Label("UI Settings", systemImage: "slider.horizontal.3")
                    .font(.headline)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).stroke(Color.secondary))
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    MainView(startWasPressed: {}, startAssessmentWasPressed: {}, startCustomAssessmet: {}, uiSettingsWasPressed: {})
}
