import SwiftUI

struct PremiumCardView: View {
    let onGetNowTapped: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Get Full Access")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("• Unlimited Features")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                    Text("• Unlimited Decibel Meter")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                    
                    Button(action: onGetNowTapped) {
                        Text("Get Now")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.top)
                    }
                }
            }
            Spacer()
            Image("pre2")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
        }
        .padding(20)
        .background(Color(UIColor(hex: "#1375FF")))
        .cornerRadius(24)
        .padding(.horizontal)
    }
}

#Preview {
    PremiumCardView(onGetNowTapped: {})
}
/*

 */
