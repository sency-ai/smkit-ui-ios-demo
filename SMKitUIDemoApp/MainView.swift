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
    
    var body: some View {
        VStack{
            Button {
                if authModel.didFinishAuth{
                    startWasPressed()
                }
            } label: {
                Text("START")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke()
                    )
            }
            .overlay(
                ZStack{
                    if !authModel.didFinishAuth{
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .padding()
                    }
                },
                alignment: .trailing
            )
            
            Button {
                if authModel.didFinishAuth{
                    startAssessmentWasPressed()
                }
            } label: {
                Text("START ASSESSMENT")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke()
                    )
            }
            .overlay(
                ZStack{
                    if !authModel.didFinishAuth{
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .padding()
                    }
                },
                alignment: .trailing
            )
            
            Button {
                if authModel.didFinishAuth{
                    startCustomAssessmet()
                }
            } label: {
                Text("START CUSTOM ASSESSMET")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke()
                    )
            }
            .overlay(
                ZStack{
                    if !authModel.didFinishAuth{
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .padding()
                    }
                },
                alignment: .trailing
            )
        }
    }
}

#Preview {
    MainView(startWasPressed: {}, startAssessmentWasPressed: {}, startCustomAssessmet: {})
}
