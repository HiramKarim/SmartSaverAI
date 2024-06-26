//
//  OnboardingCarouselView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 25/06/24.
//

import SwiftUI

struct OnboardingCarouselView: View {
    
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<5) { index in
                    OnboardingView(pageIndex: index,
                                   titleKey: LocalizedStringKey("onboarding_page_\(index + 1)_title"),
                                   descriptionKey: LocalizedStringKey("onboarding_page_\(index + 1)_description"),
                                   imageName: "slide-\(index + 1)")
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

#Preview {
    OnboardingCarouselView()
}
