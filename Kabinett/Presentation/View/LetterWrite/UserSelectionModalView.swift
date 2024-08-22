//
//  UserSelectionView.swift
//  Kabinett
//
//  Created by Song Kim on 8/12/24.
//

import SwiftUI

struct UserSelectionModalView: View {
    @Binding var letterContent: LetterWriteViewModel
    @Environment(\.presentationMode) var presentation
    @ObservedObject private var viewModel = UserSelectionViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            Spacer()
                            Button("완료") {
                                letterContent.fromUserId = viewModel.fromUser?.id
                                letterContent.fromUserName = viewModel.fromUser?.name ?? ""
                                letterContent.fromUserKabinettNumber = viewModel.fromUser?.kabinettNumber
                                if letterContent.toUserName == "" {
                                    viewModel.updateToUser(&letterContent, toUserName: letterContent.fromUserName)
                                }
                                letterContent.toUserId = viewModel.toUser?.id
                                letterContent.toUserName = viewModel.toUser?.name ?? ""
                                letterContent.toUserKabinettNumber = viewModel.toUser?.kabinettNumber
                                
                                presentation.wrappedValue.dismiss()
                            }
                        }
                        .foregroundStyle(.black)
                        
                        FormToUser(letterContent: $letterContent, viewModel: viewModel)
                        
                        HStack {
                            if viewModel.checkLogin {
                                Spacer(minLength: 95)
                                VStack {
                                    SearchBar(letterContent: $letterContent, searchText: $viewModel.searchText, viewModel: viewModel)
                                }
                            } else {
                                Spacer(minLength: 65)
                                VStack {
                                    Text("로그인을 하면 다른 사람에게도 편지를 \n보낼 수 있어요")
                                        .font(.system(size: 12))
                                        .lineSpacing(5)
                                        .foregroundStyle(Color("ContentSecondary"))
                                        .bold()
                                    HStack {
                                        Spacer()
                                        Button("로그인하기") {
                                            // TODO: 로그인창으로 이동
                                        }
                                        .buttonStyle(.plain)
                                        .foregroundStyle(Color("ContentPrimary"))
                                        .font(.system(size: 13))
                                        .bold()
                                        .underline()
                                        .padding(.top, 20)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(.top, 1)
                        Spacer()
                    }
                    .padding(.horizontal, geometry.size.width * 0.06)
                    .padding(.top, 24)
                    .background(Color("Primary100"))
                }
            }
        }
        
    }
}


// MARK: - FormToUserView
struct FormToUser: View {
    @Binding var letterContent: LetterWriteViewModel
    @ObservedObject var viewModel: UserSelectionViewModel
    
    var body: some View {
        let fromName = letterContent.fromUserName == "" ? viewModel.fromUser?.name ?? "" : letterContent.fromUserName
        
        HStack {
            Text("보내는 사람")
                .foregroundStyle(Color("ContentPrimary"))
                .font(.system(size: 16))
                .bold()
            Spacer(minLength: 22)
            Text("\(fromName) \(viewModel.checkMe(kabi: viewModel.userKabi ?? 0))")
                .foregroundStyle(Color("ContentSecondary"))
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, minHeight: 35)
                .background(Color.white)
                .clipShape(Capsule())
        }
        .padding(.top, 24)
        
        HStack {
            Text("받는 사람")
                .foregroundStyle(Color("ContentPrimary"))
                .font(.system(size: 16))
                .bold()
            Spacer(minLength: 37)
            let toName = letterContent.toUserName == "" ? fromName : letterContent.toUserName
            let toKabi = letterContent.toUserName == "" ? viewModel.userKabi ?? 0 : letterContent.toUserKabinettNumber
            Text("\(toName) \(viewModel.checkMe(kabi: toKabi ?? 0))")
                .foregroundStyle(viewModel.toUser?.name == "나" ? Color("ContentSecondary") : Color.black)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, minHeight: 35)
                .background(Color.white)
                .clipShape(Capsule())
        }
        .padding(.top, 40)
    }
}


// MARK: - SearchBarView
struct SearchBar: View {
    @Binding var letterContent: LetterWriteViewModel
    @Binding var searchText: String
    @ObservedObject var viewModel: UserSelectionViewModel
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color("ContentPrimary"))
                
                TextField("", text: $searchText)
                    .foregroundStyle(.primary)
                
                if !searchText.isEmpty {
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color("Primary100"))
                    }
                } else {
                    EmptyView()
                }
            }
            .padding(EdgeInsets(top: 7, leading: 13, bottom: 7, trailing:13))
            .background(Color(.white))
            .clipShape(.capsule)
            if !searchText.isEmpty {
                Divider()
                    .padding([.leading, .trailing], 10)
                    .padding(.top, -6)
                
                List {
                    Text("\(searchText) 입력")
                        .onTapGesture {
                            viewModel.updateToUser(&letterContent, toUserName: searchText)
                            searchText = ""
                            UIApplication.shared.endEditing()
                        }
                        .padding(.leading, 35)
                        .listRowSeparator(.hidden)
                        .foregroundStyle(Color("Primary900"))
                    
                    ForEach(viewModel.dummyUsers.filter { user in
                        user.name.lowercased().contains(searchText.lowercased()) ||
                        String(format: "%06d", user.kabinettNumber).hasPrefix(searchText)
                    }, id: \.kabinettNumber) { user in
                        HStack {
                            if let profileImage = user.profileImage {
                                AsyncImage(url: URL(string: profileImage)) { image in
                                    image
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .clipShape(.circle)
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .clipShape(.circle)
                                    .foregroundStyle(Color("background"))
                            }
                            Text(user.name)
                                .foregroundStyle(Color("Primary900"))
                            Spacer()
                            let formattedKabinettNumber = String(format: "%06d", user.kabinettNumber)
                            Text("\(String(formattedKabinettNumber.prefix(3)))-\(String(formattedKabinettNumber.suffix(3)))")
                                .foregroundStyle(Color("Primary900"))
                        }
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            viewModel.updateToUser(&letterContent, toUserName: user.name)
                            searchText = ""
                            UIApplication.shared.endEditing()
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: 200)
                .padding(.top, -5)
            }
        }
        .padding(.top, 2)
        .background(searchText.isEmpty ? Color.clear : Color.white)
        .cornerRadius(16)
    }
}
