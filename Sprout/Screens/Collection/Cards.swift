import SwiftUI

struct CollectionCard: View {
    let collection: LearningCollection

    private var accent: Color { Color(hex: collection.accentHex) }

    private var progressText: String {
        collection.hasEnoughLessons ? "\(Int(collection.progress * 100))%" : "Need 5"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(collection.title)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(accent)
                .lineLimit(1)

            Text("\(collection.lessons.count) Entries")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.black.opacity(0.38))

            HStack(spacing: 8) {
                MiniProgressBar(progress: collection.progress, accent: accent)
                    .frame(height: 5)

                Text(progressText)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(collection.hasEnoughLessons ? accent : .black.opacity(0.35))
                    .frame(width: 42, alignment: .trailing)
            }
            .padding(.top, 8)

            Spacer(minLength: 0)

            SproutMascot(accent: collection.hasEnoughLessons ? accent : Color.black.opacity(0.16))
                .frame(width: 108, height: 92)
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: 18)
        }
        .padding(.top, 18)
        .padding(.horizontal, 14)
        .frame(height: 190)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .shadow(color: .black.opacity(0.13), radius: 12, x: 0, y: 7)
        .clipped()
    }
}

struct LessonCard: View {
    let index: Int
    let lesson: Lesson
    let accent: Color

    private var isCompleted: Bool { lesson.isCompleted }

    private var hasExplanation: Bool {
        !lesson.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var statusText: String { isCompleted ? "Completed" : "Incomplete" }
    private var statusIcon: String { isCompleted ? "checkmark.circle.fill" : "circle" }
    private var statusColor: Color { isCompleted ? accent : .black.opacity(0.34) }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isCompleted ? accent.opacity(0.14) : .black.opacity(0.055))
                    .frame(width: 72, height: 72)

                VStack(spacing: 2) {
                    Text(String(format: "%02d", index))
                        .font(.system(size: 18, weight: .black))
                    Text("LESSON")
                        .font(.system(size: 8, weight: .black))
                }
                .foregroundStyle(isCompleted ? accent : .black.opacity(0.28))
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(lesson.title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.black.opacity(isCompleted ? 1 : 0.78))
                    .lineLimit(2)

                Text(hasExplanation ? lesson.explanation : "Tap to add explanation")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.black.opacity(hasExplanation ? 0.52 : 0.30))
                    .lineLimit(2)

                HStack(spacing: 7) {
                    LowKeyFeelingPreview(score: lesson.feelingScore)

                    Image(systemName: statusIcon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(statusColor)

                    Text(statusText)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(statusColor)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 6)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.black.opacity(0.20))
        }
        .padding(14)
        .background(isCompleted ? .white : .white.opacity(0.68))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(isCompleted ? accent.opacity(0.24) : .black.opacity(0.035), lineWidth: 1)
        }
        .shadow(color: .black.opacity(isCompleted ? 0.07 : 0.035), radius: 14, y: 8)
    }
}

struct LowKeyFeelingPreview: View {
    let score: Int?

    private var symbolName: String {
        guard let score else { return "face.smiling" }
        switch score {
        case 0: return "face.dashed"
        case 1: return "face.smiling.inverse"
        case 2: return "face.smiling"
        default: return "face.smiling.fill"
        }
    }

    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.black.opacity(score == nil ? 0.20 : 0.42))
            .frame(width: 18, height: 18)
    }
}
