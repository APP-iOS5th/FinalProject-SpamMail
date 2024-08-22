//
//  ProfileSettingsView.swift
//  Kabinett
//
//  Created by Yule on 8/14/24.
//

import SwiftUI
import PhotosUI

struct ProfileSettingsView: View {
    @ObservedObject var viewModel: ProfileSettingsViewModel
    
    var body: some View {
        NavigationStack {
            VStack{
                PhotosPicker(
                    selection: $viewModel.selectedImageItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack{
                        Circle()
                            .foregroundColor(.primary300)
                            .frame(width: 110, height: 110)
                        if let image = viewModel.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                    }
                }
                .onChange(of: viewModel.selectedImageItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            viewModel.selectedImage = uiImage
                            viewModel.isShowingCropper = true
                        }
                    }
                }
                .padding(.bottom, 10)
                
                TextField(viewModel.displayName, text: $viewModel.newUserName)
                    .textFieldStyle(OvalTextFieldStyle())
                    .autocorrectionDisabled(true)
                    .keyboardType(.alphabet)
                    .submitLabel(.done)
                    .frame(alignment: .center)
                    .multilineTextAlignment(.center)
                    .font(Font.system(size: 25, design: .default))
                    .padding(.bottom, 10)
                
                Text(viewModel.kabinettNumber)
                    .fontWeight(.light)
                    .font(.system(size: 16))
                    .monospaced()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .navigationTitle("프로필 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.completeProfileUpdate()
                    }) {
                        Text("완료")
                            .fontWeight(.medium)
                            .font(.system(size: 18))
                            .foregroundColor(.contentPrimary)
                            .padding(.trailing, 8)
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToProfile) {
                ProfileView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.isShowingCropper) {
            if let profileImage = viewModel.selectedImage {
                ImageCropper(viewModel: viewModel, isShowingCropper: $viewModel.isShowingCropper, image: profileImage)
            } else {
                Text("No image available for cropping.")
            }
        }
    }
}


struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(
                Capsule()
                    .stroke(Color.primary300, lineWidth: 1)
                    .background(Capsule().fill(Color.white))
            )
            .frame(width: 270, height: 54)
    }
}

struct ImageCropper: View {
    @ObservedObject var viewModel: ProfileSettingsViewModel
    @Binding var isShowingCropper: Bool
    let image: UIImage?
    @State var cropArea: CGRect = .init(x: 0, y:0, width: 110, height: 110)
    @State var imageViewSize: CGSize = .zero
    @State var croppedImage: UIImage?
    
    var body: some View {
        if let image = image {
            VStack {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay(alignment: .topLeading) {
                        GeometryReader { geometry in
                            CropBox(rect: $cropArea)
                                .onAppear {
                                    self.imageViewSize = geometry.size
                                }
                                .onChange(of: geometry.size) {
                                    self.imageViewSize = $0
                                }
                        }
                    }
                Spacer()
                Button("이미지 적용하기", action: {
                    croppedImage = self.crop(image: image, cropArea: cropArea, imageViewSize: imageViewSize)
                    if let croppedImage = croppedImage {
                        viewModel.updateProfileImage(with: croppedImage)
                    }
                    isShowingCropper = false
                })
                .foregroundStyle(.white)
                .padding(.bottom, 20)
                
                if let croppedImage {
                    Image(uiImage: croppedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        } else {
            Text("No image available for cropping.")
        }
    }
    
    private func crop(image: UIImage, cropArea: CGRect, imageViewSize: CGSize) -> UIImage? {
        let scaleX = image.size.width / imageViewSize.width * image.scale
        let scaleY = image.size.height / imageViewSize.height * image.scale
        let scaledCropArea = CGRect(
            x: cropArea.origin.x * scaleX,
            y: cropArea.origin.y * scaleY,
            width: cropArea.size.width * scaleX,
            height: cropArea.size.height * scaleY
        )
        
        guard let cutImageRef: CGImage =
                image.cgImage?.cropping(to: scaledCropArea) else {
            return nil
        }
        
        return UIImage(cgImage: cutImageRef)
    }
}

#Preview {
    ProfileSettingsView(viewModel: ProfileSettingsViewModel())
}
