//
//  SettingsView.swift
//  Kabinett
//
//  Created by Yule on 8/14/24.
//

import FirebaseAnalytics
import SwiftUI

// `SettingsView`
struct SettingsView: View {
    //
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    let horizontalPadding: CGFloat = UIScreen.main.bounds.width * 0.06
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea(.all)
            VStack(alignment: .leading) {
                NavigationLink(destination: ProfileSettingsView(viewModel: viewModel)) {
                    HStack{
                        Text("프로필 설정")
                            .fontWeight(.medium)
                            .font(.system(size: 18))
                            .foregroundColor(.contentPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .fontWeight(.medium)
                            .font(.system(size: 19))
                            .foregroundColor(.contentPrimary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 25)
                    .padding(.horizontal, horizontalPadding)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: AccountSettingsView(viewModel: viewModel)) {
                    HStack{
                        Text("계정 설정")
                            .fontWeight(.medium)
                            .font(.system(size: 18))
                            .foregroundColor(.contentPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .fontWeight(.medium)
                            .font(.system(size: 19))
                            .foregroundColor(.contentPrimary)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                // TODO: - 추후에 다른 소셜로그인 추가되면 이미지 변경 가능하게 수정하기
                HStack{
                    ZStack {
                        Rectangle()
                            .frame(width: 23, height: 23)
                            .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        Image(systemName: "apple.logo")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 10)
                    Text(viewModel.appleID)
                        .font(.system(size: 17))
                        .foregroundColor(.contentSecondary)
                }
                .padding(.horizontal, horizontalPadding)
                
                Spacer()
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
        .analyticsScreen(
            name: "\(type(of:self))",
            extraParameters: [
                AnalyticsParameterScreenName: "\(type(of:self))",
                AnalyticsParameterScreenClass: "\(type(of:self))",
            ]
        )
    }
    
}
