//
//  OnBoardingScreen.swift
//  Sprout
//
//  Created by Alex on 29/05/26.
//

import SwiftUI

private let onboardingAccent = Color.appAccent

struct OnboardingScreen: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selectedPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Grow your learning",
            subtitle: "Create roadmaps for anything you want to learn and organize your progress step by step.",
            imageName: "onboarding 1"
        ),
        OnboardingPage(
            title: "Complete Milestones",
            subtitle: "Add explanations, photos, and feelings after each milestones to make your progress meaningful.",
            imageName: "onboarding 2"
        ),
        OnboardingPage(
            title: "Recollect your journey",
            subtitle: "Completed lessons will appear in Recollection, so you can look back at what you have learned.",
            imageName: "onboarding 3"
        )
    ]

    struct SkyLearningBackground: View {
        var body: some View {
            LinearGradient(
                colors: [
                    Color.fromHex("#EFEFD5"),
                    Color.fromHex("#FFFFF3"),
                    Color.fromHex("#FFFFFF")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(.white.opacity(0.5))
                    .frame(width: 230, height: 230)
                    .blur(radius: 24)
                    .offset(x: 80, y: -70)
            }
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(Color.white.opacity(0.34))
                    .frame(width: 220, height: 70)
                    .blur(radius: 10)
                    .offset(x: -40, y: 92)
            }
        }
    }

    
    var body: some View {
        ZStack {
            SkyLearningBackground()

            VStack(spacing: 0) {
                Spacer(minLength: 28)

                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                            .padding(.horizontal, 28)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                OnboardingPageIndicator(
                    pageCount: pages.count,
                    selectedPage: selectedPage
                )
                .padding(.bottom, 28)

                Button {
                    if selectedPage < pages.count - 1 {
                        withAnimation(.snappy(duration: 0.28)) {
                            selectedPage += 1
                        }
                    } else {
                        hasSeenOnboarding = true
                    }
                } label: {
                    Text(selectedPage == pages.count - 1 ? "Get Started" : "Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(onboardingAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: onboardingAccent.opacity(0.28), radius: 16, y: 8)
                }
                .padding(.horizontal, 28)

                Button {
                    hasSeenOnboarding = true
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.38))
                        .padding(.vertical, 18)
                }

                Spacer(minLength: 12)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 260)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 38, weight: .black))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text(page.subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.black.opacity(0.50))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }

            Spacer()
        }
    }
}


struct OnboardingPageIndicator: View {
    let pageCount: Int
    let selectedPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == selectedPage ? onboardingAccent : Color.black.opacity(0.16))
                    .frame(width: index == selectedPage ? 28 : 9, height: 9)
                    .animation(.snappy(duration: 0.22), value: selectedPage)
            }
        }
    }
}

#Preview {
    OnboardingScreen()
}
