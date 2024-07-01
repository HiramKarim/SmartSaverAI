//
//  OnboardingCarouselView.swift
//  SavingsApp
//
//  Created by Hiram Castro on 25/06/24.
//

import SwiftUI

struct OnboardingCarouselView: View {
    
    @EnvironmentObject var appState: AppState

    @State private var currentPage = 0
    
    private func getTitle(using pageIndex: Int) -> LocalizedStringKey {
        let newTitle = "onboarding_page_\(pageIndex)_title"
        return LocalizedStringKey(newTitle)
    }
    
    private func getDescription(using pageIndex: Int) -> LocalizedStringKey {
        let newDescription = "onboarding_page_\(pageIndex)_description"
        return LocalizedStringKey(newDescription)
    }
    
    private let endPage = 4
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(gradient: .init(colors: [
                Color.init("GradientColor-1", bundle: nil),
                Color.init("GradientColor-2", bundle: nil),
                Color.init("GradientColor-3", bundle: nil)
            ]), startPoint: .top,
                endPoint: .bottom)
            .ignoresSafeArea(.all)
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<5) { index in
                        OnboardingView(pageIndex: index,
                                       titleKey: getTitle(using: index + 1),
                                       descriptionKey: getDescription(using: index + 1),
                                       imageName: "slide-\(index + 1)")
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                
                if currentPage == endPage {
                    HStack {
                        Button {
                            appState.hasCompletedOnboarding = true
                        } label: {
                            Text("onboarding_button_start")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.init("PrimaryColor", bundle: nil), in: Capsule())
                        .foregroundStyle(Color.init("BackgroundColor", bundle: nil))
                        .controlSize(.large)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: currentPage)
                        
                    }
                    .padding()
                } else {
                    HStack {
                        Button {
                            currentPage += 1
                        } label: {
                            Text("onboarding_button_next")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("PrimaryColor"), in: Capsule())
                        .foregroundColor(Color("BackgroundColor"))
                        .controlSize(.large)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: currentPage)
                    }
                    .padding()
                }

            }
        }
        
    }
}

#Preview {
    OnboardingCarouselView()
}
