//
//  UserSelectionView.swift
//  Kabinett
//
//  Created by Song Kim on 8/12/24.
//

import SwiftUI
import Kingfisher
import FirebaseAnalytics

struct UserSelectionView: View {
    @Binding var letterContent: LetterWriteModel
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel : UserSelectionViewModel
    
    init(letterContent: Binding<LetterWriteModel>) {
        @Injected(WriteLetterUseCaseKey.self) var writeLetterUseCase: WriteLetterUseCase
        _viewModel = StateObject(wrappedValue: UserSelectionViewModel(useCase: writeLetterUseCase))
        self._letterContent = letterContent
    }
    
    var body: some View {
        
        ZStack {
            Color(.primary100).ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button("완료") {
                        dismiss()
                    }
                }
                .fontWeight(.medium)
                .font(.system(size: 19))
                .foregroundColor(.contentPrimary)
                .padding(.bottom, -3)
                
                FormToUser(letterContent: $letterContent, viewModel: viewModel)
                
                HStack {
                    if viewModel.checkLogin {
                        Spacer(minLength: 95)
                        VStack {
                            SearchBar(letterContent: $letterContent, searchText: $viewModel.searchText, viewModel: viewModel)
                            Group {
                                Text("정확한 닉네임")
                                    .bold() +
                                Text(" 혹은 -를 뺀") +
                                Text(" 6개의 카비넷 번호만\n")
                                    .bold() +
                                Text("입력해주세요.")
                            }
                            .font(.system(size: 12))
                            .foregroundColor(Color("ContentSecondary"))
                            .lineSpacing(3)
                            .padding(.top, 1)
                        }
                    } else {
                        Spacer(minLength: 65)
                        VStack {
                            Text("로그인을 하면 다른 사람에게도 편지를 \n보낼 수 있어요.")
                                .font(.system(size: 12))
                                .lineSpacing(3)
                                .foregroundStyle(Color("ContentSecondary"))
                                .bold()
                            HStack {
                                Spacer()
                                Button("로그인하기") {
                                    viewModel.showModal = true
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(Color("ContentPrimary"))
                                .font(.system(size: 16))
                                .bold()
                                .underline()
                                .padding(.top, 15)
                                .sheet(isPresented: $viewModel.showModal) {
                                    LetterWriteLoginView()
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.top, 1)
                Spacer()
            }
            .padding(.horizontal, UIScreen.main.bounds.width * 0.06)
            .padding(.top, 24)
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


// MARK: - FormToUserView
struct FormToUser: View {
    @Binding var letterContent: LetterWriteModel
    @ObservedObject var viewModel : UserSelectionViewModel
    
    var body: some View {
        HStack {
            Text("보내는 사람")
                .foregroundStyle(Color("ContentPrimary"))
                .font(.system(size: 16))
                .bold()
            Spacer(minLength: 22)
            Text(viewModel.checkLogin ? "\(viewModel.fromUser?.name ?? "") (나)" : "나")
                .foregroundStyle(Color("ContentSecondary"))
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, minHeight: 35)
                .background(Color.white)
                .clipShape(Capsule())
        }
        .padding(.top, 15)
        .onChange(of: viewModel.fromUser?.kabinettNumber) {
            letterContent.fromUserId = viewModel.fromUser?.id
            letterContent.fromUserKabinettNumber = viewModel.fromUser?.kabinettNumber
            letterContent.toUserId = viewModel.toUser?.id
            letterContent.toUserKabinettNumber = viewModel.toUser?.kabinettNumber
            letterContent.date = Date()
            if viewModel.checkLogin {
                letterContent.fromUserName = viewModel.fromUser?.name ?? ""
                letterContent.toUserName = viewModel.toUser?.name ?? ""
            } else {
                letterContent.fromUserName = "나"
                letterContent.toUserName = "나"
            }
        }
        
        HStack {
            Text("받는 사람")
                .foregroundStyle(Color("ContentPrimary"))
                .font(.system(size: 16))
                .bold()
            Spacer(minLength: 37)
            let toName = letterContent.toUserName.isEmpty ? viewModel.toUser?.name ?? "" : letterContent.toUserName
            let toKabi = letterContent.toUserName.isEmpty ? viewModel.fromUser?.kabinettNumber ?? 0 : letterContent.toUserKabinettNumber
            Text(viewModel.checkLogin ? "\(toName) \(viewModel.checkMe(kabiNumber: toKabi ?? 0))" : "나")
                .foregroundStyle(viewModel.checkLogin ? Color.black : Color("ContentSecondary"))
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
    @Binding var letterContent: LetterWriteModel
    @Binding var searchText: String
    @ObservedObject var viewModel: UserSelectionViewModel
    @State var isSearchBar: Bool = true
    
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
                    .onAppear {
                        isSearchBar = true
                    }
                }
            }
            .padding(EdgeInsets(top: 7, leading: 13, bottom: 7, trailing: 13))
            .background(Color(.white))
            .clipShape(.capsule)
            
            if !viewModel.debouncedSearchText.isEmpty && isSearchBar {
                Divider()
                    .padding([.leading, .trailing], 10)
                    .padding(.top, -6)
                
                List {
                    Text("\(viewModel.debouncedSearchText) 입력")
                        .onTapGesture {
                            viewModel.updateToUser(&letterContent, toUserName: viewModel.debouncedSearchText)
                            searchText = ""
                            UIApplication.shared.endEditing()
                            isSearchBar = false
                        }
                        .padding(.leading, 35)
                        .listRowSeparator(.hidden)
                        .foregroundStyle(Color("Primary900"))
                    
                    ForEach(viewModel.usersData) { user in
                        HStack {
                            if let profileImage = user.profileImage {
                                KFImage(URL(string: profileImage))
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .clipShape(.circle)
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .clipShape(.circle)
                                    .foregroundStyle(Color("Primary100"))
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
                            isSearchBar = false
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: 200)
                .padding(.top, -5)
            }
        }
        .padding(.top, 2)
        .background(viewModel.debouncedSearchText.isEmpty ? Color.clear : Color.white)
        .cornerRadius(20)
    }
}


// MARK: - LetterWriteLoginView
struct LetterWriteLoginView: View {
    var body: some View {
        NavigationStack {
            ZStack (alignment: .topTrailing) {
                SignUpView()
                Rectangle()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(Color(.background))
            }
        }
    }
}
