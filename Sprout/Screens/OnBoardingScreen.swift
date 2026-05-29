//
//  OnBoardingScreen.swift
//  Sprout
//
//  Created by Alex on 29/05/26.
//

import SwiftUI

private let onboardingAccent = Color(red: 165/255, green: 168/255, blue: 39/255)

struct OnboardingScreen: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selectedPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Grow your learning",
            subtitle: "Create roadmaps for anything you want to learn and organize your progress step by step.",
            fallbackIcon: "leaf.fill"
        ),
        OnboardingPage(
            title: "Complete Milestones",
            subtitle: "Add explanations, photos, and feelings after each milestones to make your progress meaningful.",
            fallbackIcon: "checkmark.circle.fill"
        ),
        OnboardingPage(
            title: "Recollect your journey",
            subtitle: "Completed lessons will appear in Recollection, so you can look back at what you have learned.",
            fallbackIcon: "calendar"
        )
    ]

    struct SkyLearningBackground: View {
        var body: some View {
            LinearGradient(
                colors: [
                    Color.fromHex("#DDF5FF"),
                    Color.fromHex("#F7FBFF"),
                    Color.fromHex("#EAF4F7")
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
    let fallbackIcon: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            OnboardingHeroVisual(page: page)

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

struct OnboardingHeroVisual: View {
    let page: OnboardingPage

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.92))
                .frame(width: 260, height: 260)
                .shadow(color: .black.opacity(0.08), radius: 24, y: 14)

            OnboardingSproutIllustration()
                .frame(width: 190, height: 190)
                .offset(y: 22)

            Circle()
                .fill(onboardingAccent)
                .frame(width: 72, height: 72)
                .shadow(color: .black.opacity(0.12), radius: 14, y: 7)
                .overlay {
                    Image(systemName: page.fallbackIcon)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(x: 88, y: -86)
        }
    }
}

struct OnboardingSproutIllustration: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(onboardingAccent)
                .frame(width: 150, height: 150)
                .offset(y: 42)

            HStack(spacing: 18) {
                Circle()
                    .fill(.white)
                    .frame(width: 15, height: 15)
                    .overlay {
                        Circle()
                            .fill(.black.opacity(0.45))
                            .frame(width: 6, height: 6)
                    }

                Circle()
                    .fill(.white)
                    .frame(width: 15, height: 15)
                    .overlay {
                        Circle()
                            .fill(.black.opacity(0.45))
                            .frame(width: 6, height: 6)
                    }
            }
            .offset(y: -18)

            Capsule()
                .fill(.white.opacity(0.85))
                .frame(width: 10, height: 40)
                .offset(x: 54, y: -5)

            VStack(spacing: -4) {
                OnboardingLeafShape()
                    .fill(onboardingAccent)
                    .frame(width: 36, height: 64)
                    .rotationEffect(.degrees(-34))
                    .offset(x: -16, y: 10)

                OnboardingLeafShape()
                    .fill(onboardingAccent)
                    .frame(width: 36, height: 68)
                    .rotationEffect(.degrees(34))
                    .offset(x: 22, y: -28)
            }
            .offset(y: -108)
        }
    }
}

struct OnboardingLeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))

        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX - rect.width * 0.15, y: rect.height * 0.62),
            control2: CGPoint(x: rect.minX, y: rect.height * 0.10)
        )

        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.height * 0.10),
            control2: CGPoint(x: rect.maxX + rect.width * 0.15, y: rect.height * 0.62)
        )

        return path
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
