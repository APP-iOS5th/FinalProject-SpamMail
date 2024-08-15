//
//  ProfileView.swift
//  Kabinett
//
//  Created by Yule on 8/14/24.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileSettingsViewModel
    @State private var shouldNavigateToSettings = false
    
    var body: some View {
        NavigationStack {
            VStack{
                if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width:110, height: 110)
                        .clipShape(Circle())
                        .padding(.bottom, -1)
                } else {
                    Circle()
                        .foregroundColor(.primary300)
                        .frame(width: 110, height: 110)
                        .padding(.bottom, -1)
                }
                
                Text(viewModel.userName)
                    .fontWeight(.regular)
                    .font(.system(size: 36))
                    .padding(.bottom, 0.1)
                Text("000-000")
                    .fontWeight(.light)
                    .font(.system(size: 16))
                    .monospaced()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        shouldNavigateToSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 19))
                            .foregroundColor(.contentPrimary)
                    }
                }
            }
            .navigationDestination(isPresented: $shouldNavigateToSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ProfileView(viewModel: ProfileSettingsViewModel())
}
