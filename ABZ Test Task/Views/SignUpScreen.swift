//
//  SignUpScreen.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI
import PhotosUI

/// The sign up screen to sign up a new user
struct SignUpScreen: View {

    @StateObject private var viewModel = SignUpViewModel()
    @State private var isPhotoPickerPresented: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ABZTextField(
                    label: "Your name",
                    text: $viewModel.name,
                    supportingText: " ",
                    fieldError: viewModel.validationIssues?.nameError
                )
                .padding(.top)

                ABZTextField(
                    label: "Email",
                    text: $viewModel.email,
                    supportingText: " ",
                    fieldError: viewModel.validationIssues?.emailError
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

                ABZTextField(
                    label: "Phone",
                    text: $viewModel.phone,
                    supportingText: "+38 (xxx) xxx - xx - xx",
                    fieldError: viewModel.validationIssues?.phoneError
                )
                .keyboardType(.phonePad)
                .padding(.bottom)

                if let positions = viewModel.positions {
                    // TODO: add somewhere a position validation issue
                    RadioButtonGroup(
                        groupTitle: "Select your position",
                        elements: positions.positions.map { .init(id: $0.id, title: $0.name) },
                        currentElementId: $viewModel.selectedPosition
                    )
                    .padding(.bottom, 24)
                } else {
                    ProgressView()
                        .frame(minWidth: .infinity, alignment: .center)
                }

                ZStack(alignment: .topTrailing) {
                    ABZTextField(
                        label: viewModel.hasPhoto ? "Photo prepared" : "Upload your photo",
                        text: .constant(""),
                        fieldError: viewModel.validationIssues?.photoError
                    )
                    .focused($isFocused)
                    .onChange(of: isFocused, initial: false) { _, newValue in
                        if newValue {
                            logger.info("Open photo chooser from text field")
                            viewModel.showPhotoChooserDialog = true
                            isFocused = false
                        }
                    }
                    SecondaryButton(label: "Upload") {
                        logger.info("Open photo chooser from button")
                        viewModel.showPhotoChooserDialog = true
                    }
                    .padding(.trailing, 4)
                    .padding(.top, 7)
                }
                .padding(.bottom, 24)

                if viewModel.isSigningUp {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                } else {
                    PrimaryFilledButton(label: "Sign up") {
                        Task {
                            await viewModel.signUp()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(!viewModel.canSignUp)
                }

                Spacer()
            }
        }
        .padding(.horizontal)
        .task {
            await viewModel.getPositions()
        }
        .sheet(item: $viewModel.noInternetIssue) { retryAction in
            NoInternetScreen {
                viewModel.noInternetIssue = nil
                Task {
                    await viewModel.retry(action: retryAction)
                }
            }
        }
        .confirmationDialog("Camera or gallery choice dialog", isPresented: $viewModel.showPhotoChooserDialog) {
            Button("Camera") {
                logger.info(">>> Camera")
                viewModel.showImagePicker = true
            }
            Button("Gallery") {
                logger.info(">>> Gallery")
                isPhotoPickerPresented = true
            }
        } message: {
            Text("Choose how you want to add a photo")
        }
        .sheet(isPresented: $viewModel.successfullySignedUp) {
            UserRegisteredScreen()
        }
        .sheet(isPresented: $viewModel.alreadySignedUp) {
            UserAlreadyRegisteredScreen {
                Task {
                    await viewModel.retry(action: .signUp)
                }
            }
        }
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $viewModel.selectedImage)
        .fullScreenCover(isPresented: $viewModel.showImagePicker) {
            ImagePickerView(sourceType: .camera) { image in
                viewModel.capturedPhoto = image
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    SignUpScreen()
}
