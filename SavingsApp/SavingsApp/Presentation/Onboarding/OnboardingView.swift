//
//  OnboardingView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 25/06/24.
//

import SwiftUI

struct OnboardingView: View {
    var pageIndex: Int
    var titleKey: LocalizedStringKey
    var descriptionKey: LocalizedStringKey
    var imageName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .clipShape(Circle())
            
            Text(titleKey)
                .font(Font.getCustomFont(ofFont: .HelveticaBlkIt,
                                       ofSize: 20))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            Text(descriptionKey)
                .font(Font.getCustomFont(ofFont: .HelveticaBlkIt,
                                       ofSize: 20))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding([.leading, .trailing], 40)
        }
    }
}

#Preview {
    OnboardingView(pageIndex: 1,
                   titleKey: LocalizedStringKey("onboarding_page_1_title"),
                   descriptionKey: LocalizedStringKey("onboarding_page_1_description"),
                   imageName: "slide-1")
}
