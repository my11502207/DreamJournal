//
//  TimeRangeSelector.swift
//  dreamjournal
//
//  Created by kevin on 2025/3/6.
//
import SwiftUI

// 时间范围选择器组件
struct TimeRangeSelector: View {
    @Binding var selectedRange: DreamAnalysisView.TimeRange
    
    var body: some View {
        HStack {
            Text("时间范围:")
                .font(.subheadline)
                .foregroundColor(Color("SubtitleColor"))
                .padding(.trailing, 8)
            
            ForEach(DreamAnalysisView.TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    selectedRange = range
                }) {
                    Text(range.rawValue)
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedRange == range ? Color("AccentColor") : Color.clear)
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedRange == range ? Color.clear : Color("BorderColor"), lineWidth: 1)
                        )
                        .foregroundColor(selectedRange == range ? .white : Color("SubtitleColor"))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CardBackgroundColor"))
        )
    }
}
