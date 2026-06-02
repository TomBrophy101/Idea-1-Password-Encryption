//
//  SplashView.swift
//  SalusPass
//
//  Created by Tom Brophy on 01/04/2026.
//  This is the opening sequence when a user opens the app before going into the lock screen.

import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool

    @State private var logoScale = 0.5
    @State private var logoOpacity = 0.0

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            //This is what the user will see when they first open the app.
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                Text("SalusPass")
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
                    self.isFinished = true
                }
            }
        }
    }
}


