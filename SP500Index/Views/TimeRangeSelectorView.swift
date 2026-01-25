//
//  TimeRangeSelectorView.swift
//  SP500Index
//
//  Period selector buttons (pill-style like Stocks app)
//

import SwiftUI

struct TimeRangeSelectorView: View {
    @Binding var selectedRange: TimeRange
    let onRangeChange: (TimeRange) async -> Void

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 4) {
            ForEach(TimeRange.allCases) { range in
                TimeRangeButton(
                    range: range,
                    isSelected: selectedRange == range,
                    action: {
                        guard range != selectedRange else { return }
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                            selectedRange = range
                        }
                        Task {
                            await onRangeChange(range)
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct TimeRangeButton: View {
    let range: TimeRange
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(range.displayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.accentColor : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(range.description)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedRange: TimeRange = .oneMonth

        var body: some View {
            VStack(spacing: 20) {
                TimeRangeSelectorView(
                    selectedRange: $selectedRange,
                    onRangeChange: { range in
                        print("Selected: \(range.description)")
                    }
                )

                Text("Selected: \(selectedRange.description)")
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(width: 500)
        }
    }

    return PreviewWrapper()
}
