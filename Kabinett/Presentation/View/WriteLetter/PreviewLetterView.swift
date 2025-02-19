//
//  LetterWritePreviewView.swift
//  Kabinett
//
//  Created by Song Kim on 8/29/24.
//

import SwiftUI
import Kingfisher
import UIKit
import FirebaseAnalytics

struct PreviewLetterView: View {
    @Binding var letterContent: LetterWriteModel
    @StateObject var viewModel: PreviewLetterViewModel
    @ObservedObject var customTabViewModel: CustomTabViewModel
    @ObservedObject var imagePickerViewModel: ImagePickerViewModel
    
    init(
        letterContent: Binding<LetterWriteModel>,
        customTabViewModel: CustomTabViewModel,
        imagePickerViewModel: ImagePickerViewModel
    ) {
        @Injected(WriteLetterUseCaseKey.self) var writeLetterUseCase: WriteLetterUseCase
        
        _viewModel = StateObject(wrappedValue: PreviewLetterViewModel(useCase: writeLetterUseCase))
        self._letterContent = letterContent
        self.customTabViewModel = customTabViewModel
        self.imagePickerViewModel = imagePickerViewModel
    }
    
    var body: some View {
        ZStack {
            Color(.background).ignoresSafeArea()
            
            VStack {
                Spacer()
                WriteLetterEnvelopeCell(letter: Letter(fontString: letterContent.fontString, postScript: letterContent.postScript, envelopeImageUrlString: letterContent.envelopeImageUrlString, stampImageUrlString: letterContent.stampImageUrlString, fromUserId: letterContent.fromUserId, fromUserName: letterContent.fromUserName, fromUserKabinettNumber: letterContent.fromUserKabinettNumber, toUserId: letterContent.toUserId, toUserName: letterContent.toUserName, toUserKabinettNumber: letterContent.toUserKabinettNumber, content: letterContent.content, photoContents: [""], date: letterContent.date, stationeryImageUrlString: letterContent.stationeryImageUrlString, isRead: true))
                    .padding(.bottom,30)
                
                VStack {
                    Text("편지가 완성되었어요.")
                        .font(.system(size: 18, weight: .semibold))
                    HStack {
                        Text("\(letterContent.toUserName == letterContent.fromUserName ? "나" : letterContent.toUserName)")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.trailing, -3)
                        Text("에게 편지를 보낼까요?")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .padding(.top, -5)
                }
                
                Spacer()
                
                Button {
                    viewModel.saveLetter(font: letterContent.fontString ?? "",
                                         postScript: letterContent.postScript,
                                         envelope: letterContent.envelopeImageUrlString,
                                         stamp: letterContent.stampImageUrlString,
                                         fromUserId: letterContent.fromUserId,
                                         fromUserName: letterContent.fromUserName,
                                         fromUserKabinettNumber: letterContent.fromUserKabinettNumber,
                                         toUserId: letterContent.toUserId,
                                         toUserName: letterContent.toUserName,
                                         toUserKabinettNumber: letterContent.toUserKabinettNumber,
                                         content: letterContent.content,
                                         photoContents: letterContent.photoContents,
                                         date: letterContent.date,
                                         stationery: letterContent.stationeryImageUrlString ?? "",
                                         isRead: false)
                    customTabViewModel.hideOptions()
                    imagePickerViewModel.resetSelections()
                } label: {
                    Text("편지 보내기")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .background(Color("Primary900"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, UIScreen.main.bounds.width * 0.06)
            .padding(.bottom, LayoutHelper.shared.getSize(forSE: 0.03, forOthers: 0.0))
        }
        .ignoresSafeArea(.keyboard)
        .analyticsScreen(
            name: "\(type(of:self))",
            extraParameters: [
                AnalyticsParameterScreenName: "\(type(of:self))",
                AnalyticsParameterScreenClass: "\(type(of:self))",
            ]
        )
    }
}
