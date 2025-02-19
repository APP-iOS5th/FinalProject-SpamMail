//
//  ProfileViewModel.swift
//  Kabinett
//
//  Created by Yule on 8/15/24.
//

import SwiftUI
import Combine
import PhotosUI
import os

class ProfileViewModel: ObservableObject {
    struct WriterViewModel {
        let name: String
        let formattedNumber: String
        let imageUrlString: String?
    }
    
    enum NavigateState {
        case toLogin
        case toProfile
    }
    
    private let profileUseCase: ProfileUseCase
    private var cancellables = Set<AnyCancellable>()
    
    private let logger = Logger(
        subsystem: "co.kr.codegrove.Kabinett",
        category: "ProfileSettingsViewModel"
    )
    
    @Published private(set) var currentWriter: WriterViewModel = .init(name: "", formattedNumber: "", imageUrlString: nil)
    @Published var newUserName: String = ""
    @Published private(set) var appleID: String = ""
    @Published var selectedImageItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var isShowingCropper = false
    @Published var croppedImage: UIImage?
    @Published private(set) var userStatus: UserStatus?
    @Published private(set) var profileUpdateError: String?
    @Published var showProfileAlert = false
    @Published var navigateState: NavigateState = .toLogin
    @Published var showSettingsView = false
    @Published var isLoading: Bool = false
    
    var displayName: String {
        return newUserName.isEmpty ? currentWriter.name : newUserName
    }
    
    init(profileUseCase: ProfileUseCase) {
        self.profileUseCase = profileUseCase
        
        loadCurrentWriter()
        checkUserStatus()
    }
    
    @MainActor
    func completeProfileUpdate() async {
        let success = await profileUseCase.updateWriter(
            newWriterName: displayName,
            profileImage: croppedImage?.jpegData(compressionQuality: 0.8)
        )
        
        if !success {
            showProfileAlert = true
            self.profileUpdateError = "프로필 업데이트 오류 발생"
        }
    }
    
    func handleImageSelection(newItem: PhotosPickerItem?) {
        Task {
            if let item = newItem,
               let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = uiImage
                    self.isShowingCropper = true
                }
            }
        }
    }
    
    func crop(image: UIImage, cropArea: CGRect, imageViewSize: CGSize) {
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
            return
        }
        
        let croppedImage = UIImage(cgImage: cutImageRef)
        DispatchQueue.main.async {
            self.croppedImage = croppedImage
            self.isShowingCropper = false
        }
    }
    
    @MainActor
    func signout() async {
        startLoading()
        let success = await profileUseCase.signout()
        stopLoading()
        if success {
            currentWriter = WriterViewModel(name: "", formattedNumber: "", imageUrlString: nil)
        } else {
            print("로그아웃에 실패했어요.")
        }
    }
    
    @MainActor
    func deletieID() async {
        let success = await profileUseCase.deleteId()
        if !success {
            print("회원탈퇴에 실패했어요.")
        }
    }
    
    // MARK: - Private Methods
    private func loadCurrentWriter() {
        profileUseCase
            .getCurrentWriter()
            .map { writer in
                WriterViewModel(
                    name: writer.name,
                    formattedNumber: writer.kabinettNumber.formatKabinettNumber(),
                    imageUrlString: writer.profileImage
                )
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentWriter)
    }
    
    private func checkUserStatus() {
        profileUseCase.getCurrentUserStatus()
            .receive(on: DispatchQueue.main)
            .print()
            .sink { [weak self] status in
                self?.userStatus = status
                switch status {
                case .anonymous, .incomplete:
                    self?.navigateState = .toLogin
                case .registered:
                    self?.navigateState = .toProfile
                    Task { [weak self] in
                        await self?.fetchAppleID()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func startLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }
    
    @MainActor
    private func stopLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    @MainActor
    private func fetchAppleID() async {
        self.appleID = await profileUseCase.getAppleID()
    }
}

extension ProfileViewModel {
    func resetToInitialState() {
        showSettingsView = false
        profileUpdateError = nil
        newUserName = ""
        selectedImageItem = nil
        selectedImage = nil
        isShowingCropper = false
        croppedImage = nil
        showProfileAlert = false
        loadCurrentWriter()
    }
}
