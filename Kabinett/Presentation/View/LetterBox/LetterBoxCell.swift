//
//  LetterBoxCell.swift
//  Kabinett
//
//  Created by uunwon on 8/14/24.
//

import SwiftUI

struct LetterBoxCell: View {
    var type: String = "All"
    var typeName: String = "전체 편지"
    var letters: [Letter]
    var unreadCount: Int
    
    let rotationValues: [Double] = [-10, 0, 10]
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(letters.prefix(3).reversed()) { letter in
                    LetterBoxEnvelopeCell(letter: letter)
                        .offset(x: CGFloat(Int.random(in: -10...5)), y: 0)
                }
                
                Rectangle()
                    .fill(.clear)
                    .background(.clear.opacity(0.1))
                    .background(TransparentBlurView(removeAllFilters: true).blur(radius: 0.8))
//                    .background(.ultraThinMaterial)
                    .frame(width: 125, height: 180)
//                    .opacity(0.5)
                    .padding(.top, 37)
                    .shadow(radius: 2, y: CGFloat(2))
                    .blendMode(.luminosity)
                
                Text(type)
                    .font(.custom("Pecita", size: 20))
                    .offset(y: 90)
            }
            .padding(.bottom, 12)
            
            HStack {
                Text(typeName)
                    .font(.system(size: 11))
                    .foregroundStyle(.contentSecondary)
                
//                새로 도착한 편지에 대한 알림
                if unreadCount > 0 {
                    ZStack {
                        Circle()
                            .fill(.secondary900)
                            .frame(width: 17)
                        Text("\(unreadCount)")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(.white)
                    }
                    .padding(.leading, -2)
                }
            }
            
        }
        
        
    }
}

#Preview {
    LetterBoxCell(letters: LetterBoxViewModel().letterBoxDetailLetters, unreadCount: 1)
}
