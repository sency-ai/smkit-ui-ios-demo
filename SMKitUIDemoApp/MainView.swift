//
//  MainView.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var authModel = AuthManager.shared
    let buildWorkoutWasPressed:()->Void
    let buildAssessmentWasPressed:()->Void
    let startAssessmentWasPressed:()->Void
    let startCustomAssessmet:()->Void
    let guidanceModeWasPressed:()->Void
    let uiSettingsWasPressed:()->Void

    private func workoutButton(_ title: String, isProminent: Bool = false, action: @escaping ()->Void) -> some View {
        Button {
            if authModel.didFinishAuth { action() }
        } label: {
            HStack(spacing: 8) {
                if isProminent {
                    Image(systemName: "sparkles")
                }
                Text(title)
            }
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(isProminent ? .white : .primary)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isProminent ? Color.accentColor : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isProminent ? Color.accentColor.opacity(0.3) : Color.primary, lineWidth: 1)
                )
                .shadow(
                    color: isProminent ? Color.accentColor.opacity(0.28) : Color.clear,
                    radius: isProminent ? 10 : 0,
                    y: isProminent ? 4 : 0
                )
        }
        .padding(.horizontal, 24)
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
        ScrollView {
            VStack(spacing: 16) {
                workoutButton("BUILD WORKOUT", action: buildWorkoutWasPressed)
                workoutButton("BUILD ASSESSMENT", action: buildAssessmentWasPressed)
                workoutButton("START BUILT-IN ASSESSMENT", action: startAssessmentWasPressed)
                workoutButton("Start Future Assessment", isProminent: true, action: startCustomAssessmet)
                workoutButton("GUIDANCE MODE", action: guidanceModeWasPressed)

                Button(action: uiSettingsWasPressed) {
                    Label("UI Settings", systemImage: "slider.horizontal.3")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 24)
        }
    }
}

#Preview {
    MainView(
        buildWorkoutWasPressed: {},
        buildAssessmentWasPressed: {},
        startAssessmentWasPressed: {},
        startCustomAssessmet: {},
        guidanceModeWasPressed: {},
        uiSettingsWasPressed: {}
    )
}
