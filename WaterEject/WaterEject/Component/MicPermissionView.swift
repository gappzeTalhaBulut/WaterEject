//
//  MicPermissionView.swift
//  WaterEject
//
//  Created by Talha on 21.05.2025.
//

import SwiftUI

struct MicrophonePermissionRequestView: View {
    var onGrantAccess: () -> Void
    var onCancel: () -> Void // Optional: if you want a cancel/dismiss option

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .padding(25)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())

                Text("Allow Microphone Access")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("To play tones and eject water, we need access to your microphone. Don't worry — we never record or store any audio.")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Button(action: onGrantAccess) {
                    Text("Grant Access")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                
                // Optional: Add a cancel button if needed
                /*
                Button(action: onCancel) {
                    Text("Not Now")
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .padding(.horizontal, 30)
                */
            }
            .padding(.vertical, 40)
            .background(Color(red: 0.12, green: 0.18, blue: 0.25)) // Dark blueish background
            .cornerRadius(20)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)) // Semi-transparent background
    }
}

#Preview {
    MicrophonePermissionRequestView(onGrantAccess: {}, onCancel: {})
        .preferredColorScheme(.dark)
}
