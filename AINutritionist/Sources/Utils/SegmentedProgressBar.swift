//
//  SegmentedProgressBar.swift
//  AINutritionist
//
//  Created by muser on 31.03.2025.
//

import SwiftUI

struct SegmentedProgressBar: View {
    let totalSegments = 9
    var currentSegment: Int

    var body: some View {
        GeometryReader { geometry in
            let segmentWidth = geometry.size.width / CGFloat(totalSegments)
            
            HStack(spacing: 0) {
                ForEach(0..<totalSegments, id: \.self) { index in
                    Rectangle()
                        .fill(index < currentSegment
                              ? Color.init(red: 4/255, green: 212/255, blue: 132/255)
                              : Color.init(red: 188/255, green: 238/255, blue: 211/255)
                        )
                        .frame(width: segmentWidth, height: 6)
                }
            }
            .cornerRadius(100)
        }
        .frame(height: 8)
    }
}

#Preview {
    SegmentedProgressBar(currentSegment: 2)
}
