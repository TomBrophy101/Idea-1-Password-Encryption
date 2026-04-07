//
//  SplashView.swift
//  Project-Idea
//
//  Created by Tom Brophy on 01/04/2026.
//

import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool

    @State private var isActive = false
    @State private var logoScale = 0.5
    @State private var logoOpacity = 0.0

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 20) {
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                Text("Project-Idea")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.blue)
                    .opacity(logoOpacity)
            }
            .transition(.opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                self.logoScale = 1.0
                self.logoOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true

                    self.isFinished = true
                }
            }
        }
    }
}


