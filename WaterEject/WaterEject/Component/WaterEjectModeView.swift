//
//  WaterEjectModeView.swift
//  WaterEject
//
//  Created by Talha on 21.05.2025.
//

import SwiftUI

struct WaterEjectModeView: View {
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("WATER EJECT MODE")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(uiColor: .titleColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Remove water from your speaker\nusing sound frequencies.")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(uiColor: .textColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Image("eject")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
            .padding()
            .background(Color(uiColor: .cardBackground))
            .cornerRadius(12)
        }
    }
}
