//
//  LetterBoxDetailView.swift
//  Kabinett
//
//  Created by uunwon on 8/14/24.
//

import SwiftUI

struct LetterBoxDetailView: View {
    @State var letterBoxType: String
    @State private var letterCount: Int = 0
    
    @State private var navigationBarHeight: CGFloat = 0
    
    @Binding var showSearchBarView: Bool
    @Binding var searchText: String
    
    @State private var showCalendarView = false
    @State private var startDateFiltering = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @Environment(\.dismiss) private var dismiss
    
    let letters = Array(0...16) // dummy
//    let letters: [Int] = [] // empty dummy
    
    private var xOffsets: [CGFloat] {
        return [-8, 10, 6, -2, 16]
    }
    
    var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .regular))
                    .padding(.leading, 4)
            }
        }
    }
    
    init(letterBoxType: String, showSearchBarView: Binding<Bool>, searchText: Binding<String>) {
        self.letterBoxType = letterBoxType
        self._showSearchBarView = showSearchBarView
        self._searchText = searchText
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        UITabBar.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
            
            if startDateFiltering {
                CalendarBar(startDateFiltering: $startDateFiltering, startDate: $startDate, endDate: $endDate)
                    .zIndex(1)
            }
            
            ZStack {
                if letters.count == 0 {
                    Text("아직 나에게 보낸 편지가 없어요.")
                        .font(.system(size: 16, weight: .semibold))
                }
                else if letters.count < 3 {
                    VStack(spacing: 25) {
                        ForEach(letters, id: \.self) { letter in
                            LetterBoxDetailEnvelopeCell()
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: -75) {
                            ForEach(letters.indices, id: \.self) { idx in
                                if idx < 2 {
                                    LetterBoxDetailEnvelopeCell()
                                        .padding(.bottom, idx == 0 ? 82 : 37)
                                } else {
                                    LetterBoxDetailEnvelopeCell()
                                        .offset(x: xOffsets[idx % xOffsets.count], y: CGFloat(idx * 5))
                                        .zIndex(Double(idx))
                                        .padding(.bottom, idx % 3 == 1 ? 37 : 0)
                                }
                            }
                        }
                        .padding(.top, navigationBarHeight)
                        .padding(.top, startDateFiltering ? 40 : 0)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: NavigationBarHeightKey.self, value: geometry.safeAreaInsets.top + geometry.frame(in: .global).minY)
                            }
                        )
                    }
                    .onPreferenceChange(NavigationBarHeightKey.self) { value in
                        navigationBarHeight = value + 15
                    }
                }
            }
            .onAppear {
                letterCount = letters.count
            }
            
            VStack {
                Spacer()
                
                ZStack {
                    Text("\(letterCount)")
                        .padding(.horizontal, 17)
                        .padding(.vertical, 6)
                        .foregroundStyle(.black)
                        .background(.black.opacity(0.2))
                        .background(TransparentBlurView(removeAllFilters: true))
                        .cornerRadius(20)
                        .padding()
                        .font(.system(size: 16, weight: .regular))
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(letterBoxType)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button{
                    withAnimation {
                        if startDateFiltering {
                            startDateFiltering = false
                            startDate = Date()
                            endDate = Date()
                        }
                        showSearchBarView.toggle()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button{
                    withAnimation {
                        showCalendarView.toggle()
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .padding(5)
            }
        }
        .overlay {
            if showCalendarView {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showCalendarView.toggle()
                            }
                        }
                    
                    CalendarView(showCalendarView: $showCalendarView, startDateFiltering: $startDateFiltering ,startDate: $startDate, endDate: $endDate)
                        .cornerRadius(20)
                }
            }
        }
    }
    
}

#Preview {
    LetterBoxDetailView(letterBoxType: "All", showSearchBarView: .constant(false), searchText: .constant(""))
}

struct NavigationBarHeightKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var showSearchBarView: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .tint(.black)
                TextField("Search", text: $searchText)
                    .foregroundStyle(.primary)
                Image(systemName: "mic.fill")
            }
            .padding(7)
            .foregroundStyle(.primary600)
            .background(.primary300.opacity(0.2))
            .background(TransparentBlurView(removeAllFilters: false))
            .cornerRadius(10)
            
            if !searchText.isEmpty {
                Button(action: {
                    withAnimation {
                        showSearchBarView.toggle()
                        self.searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.primary600)
                }
            } else {
                EmptyView()
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 15)
    }
}

struct CalendarBar: View {
    @Binding var startDateFiltering: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .tint(.primary300)
                    Text("\(formattedDate(date: startDate))부터 \(formattedDate(date: endDate))까지")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding(8)
                .foregroundStyle(.primary600)
                .background(.primary300.opacity(0.4))
                .background(TransparentBlurView(removeAllFilters: false))
                .cornerRadius(10)
                
                Button(action: {
                    withAnimation {
                        startDateFiltering.toggle()
                        startDate = Date()
                        endDate = Date()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.primary600)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MMM d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
