//
//  SignUpViewModel.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 12.06.2025.
//

import SwiftUI
import PhotosUI
import Combine

/// The model to cover sign up screen
@MainActor
class SignUpViewModel: ObservableObject {

    /// The published name field to assign to a text field.
    @Published var name: String = ""
    /// The published email field to assign to a text field.
    @Published var email: String = ""
    /// The published phone field to assign to a text field.
    @Published var phone: String = ""
    /// The published selected position field to assign to a radio control.
    @Published var selectedPosition: Int?

    @Published var positions: PositionsModel?

    /// The flag identifying if the signing up in the progress
    @Published var isSigningUp: Bool = false
    /// The flag identifying when to show confirmation dialog to chose the origin of photo
    @Published var showPhotoChooserDialog: Bool = false
    /// The flag identifying when to
    @Published var showImagePicker: Bool = false

    /// The identification if a network call was not successful due to network problem
    ///
    /// To retry the failed operation please see ``retry(action:)``.
    @Published var noInternetIssue: RetryAction?

    /// The flag identifying that the sign up process finished up with success
    @Published var successfullySignedUp: Bool = false
    /// The flag identifying that the user with given email and phone number is already registered
    @Published var alreadySignedUp = false

    /// The validation issues for fields filled up by the user
    ///
    /// These reasons are coming from the server side.
    @Published var validationIssues: SignUpError?

    /// The authorization token to perform sign up operation
    ///
    /// The token is taken automatically (provided the API)
    /// and stored to reduce amount of calls. In case if token is already expired,
    /// it will be automatically updated with ``signUp()`` call.
    @AppStorage("token") private var token: String?

    /// The model to get an actual image from the PhotosPicker
    ///
    /// A bit overcomplicating, but seems to be a recommended approach now.
    private let profileModel = ProfileModel()

    /// The setter for a photo picked from PhotosPicker
    var selectedImage: PhotosPickerItem? {
        didSet {
            profileModel.imageSelection = selectedImage
        }
    }

    /// The setter for a photo taken with a camera
    var capturedPhoto: UIImage? {
        didSet {
            if let capturedPhoto {
                profileModel.profileImage = Image(uiImage: capturedPhoto)
            } else {
                profileModel.profileImage = nil
            }
        }
    }

    /// A simple check if user already chose their photo
    ///
    /// This is not required by the mocks, but without it the upload image field looks way too dead.
    @Published var hasPhoto: Bool = false

    /// Basic validation of provided data
    ///
    /// Looking at mocks for the task, only email field is required.
    /// The server side has its own fields validation, so we can omit it here.
    var canSignUp: Bool {
        !email.isEmpty //&& !name.isEmpty && hasPhoto && !phone.isEmpty && selectedPosition > 0
    }

    /// The instance of network manager to use with the model
    private var networkManager: NetworkManager
    /// Cancellables for combine subsciptions
    private var cancellables: Set<AnyCancellable> = []

    /// The initializer to make it possible to cover the model with tests
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        profileModel.$profileImage.sink { [weak self] image in
            self?.hasPhoto = image != nil
        }.store(in: &cancellables)
    }

    /// The method to retry the failed operation
    ///
    /// The last failed operation is stored in ``noInternetIssue``.
    func retry(action: RetryAction) async {
        switch action {
        case .getPositions:
            await getPositions()
        case .signUp:
            await signUp()
        }
    }

    /// The method to sign up the user with given data
    ///
    /// Sign up method is under authorization, so this method gets token if not yet available.
    /// If there was a token before but it is expired, the token will updated and the method will retry automatically.
    /// If newer token is expired right away it will go to the vicious cycle, and I am too lazy to fix it now.
    ///
    /// If network issue occurs (not connected to internet), ``noInternetIssue`` will be updated accordingly.
    func signUp() async {
        isSigningUp = true
        defer {
            isSigningUp = false
        }
        do {
            guard let token else {
                logger.debug("Getting new token...")
                token = try await networkManager
                    .request(.getToken, responseType: TokenModel.self)
                    .token
                return await signUp()
            }
            logger.debug("Signing up user '\(self.email)'...")
            let signUpModel = try await networkManager.request(
                .signUp(
                    .init(
                        name: name,
                        email: email,
                        phone: phone,
                        position_id: selectedPosition ?? -1, // TODO: proper handling
                        photo: await profileModel.profileImage?.exported(as: .jpeg)
                    ),
                    token: token
                ),
                responseType: SignUpResponseModel.self
            )

            logger.info("Successfully registered user with id: \(signUpModel.userId): \(signUpModel.message)")

            successfullySignedUp = true
            // TODO: it would be nice to clean up fields probably
        } catch let error as FailResponse {
            if error.statusCode == 401 {  // token expired
                token = nil
                logger.info("Token expired: \(error.message ?? "No message"); refreshing token...")
                return await signUp()
            }
            if error.statusCode == 409 {  // user already registered
                alreadySignedUp = true
                logger.info("User already signed up: \(error.message ?? "No message")")
                return
            }

            logger.error("Cannot sign up: \(error.message ?? "No message")")

            validationIssues = SignUpError(fails: error.fails)
        } catch let error as URLError {
            if error.code == .notConnectedToInternet {
                noInternetIssue = .signUp
                return
            }
            logger.error("Network error: \(error.localizedDescription)")
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
        }
    }

    /// The method to get all available positions from the server side
    ///
    /// If network issue occurs (not connected to internet), ``noInternetIssue`` will be updated accordingly.
    func getPositions() async {
        do {
            // TODO: add caching?
            let positions = try await networkManager.request(
                .positions,
                responseType: PositionsModel.self
            )
            self.positions = positions
        } catch let error as FailResponse {
            logger.error("Cannot get positions: \(error.message ?? "No message")")
        } catch let error as URLError {
            if error.code == .notConnectedToInternet {
                noInternetIssue = .getPositions
                return
            }
            logger.error("Network error: \(error.localizedDescription)")
        } catch {
            logger.error("Unexpected error while getting positions: \(error.localizedDescription)")
        }
    }

    /// The structure to identify validation issues coming from the server side
    struct SignUpError {

        var nameError: String?
        var emailError: String?
        var phoneError: String?
        var positionError: String?
        var photoError: String?

        /// Parse fail reasons and fill up all needed fields
        ///
        /// It only gets the first issue for each field, as only one could be shown to user.
        init?(fails: [String: [String]]?) {
            guard let fails else { return nil }

            for (fail, issues) in fails {
                switch fail {
                case Fails.name.rawValue:
                    nameError = issues.first
                case Fails.email.rawValue:
                    emailError = issues.first
                case Fails.phone.rawValue:
                    phoneError = issues.first
                case Fails.photo.rawValue:
                    photoError = issues.first
                case Fails.position.rawValue:
                    positionError = issues.first
                default:
                    logger.warning("Unrecognized fail field: \(fail)")
                    break
                }
            }
        }

        /// Fields names in fails dictionary coming from the server
        enum Fails: String {
            case name = "name"
            case photo = "photo"
            case position = "position_id"
            case email = "email"
            case phone = "phone"
        }
    }

    /// The enum describing actions on which network issue occurred
    enum RetryAction: Identifiable {
        case getPositions   ///< There was a network issue while getting positions
        case signUp         ///< There was a network issue while signing up

        var id: Self {
            return self
        }
    }
}

/// The model to properly get an image from PhotosPicker
@MainActor
fileprivate class ProfileModel: ObservableObject {

    /// The getter for resulting image
    @Published var profileImage: Image?

    /// The setter for image selection from the PhotosPicker
    ///
    /// Once image is selected, it will be loaded.
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                loadTransferable(from: imageSelection)
            }
        }
    }

    // MARK: - Private Methods

    /// Method to load transferable image
    ///
    /// Once loaded, ``profileImage`` will updated with the result.
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        imageSelection.loadTransferable(type: ProfileImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    logger.warning("Failed to get the selected item from photos picker.")
                    return
                }
                switch result {
                case .success(let profileImage?):
                    self.profileImage = profileImage.image
                case .failure(let error):
                    logger.error("Cannot load transferable: \(error.localizedDescription)")
                    fallthrough
                case .success(nil):
                    self.profileImage = nil
                }
            }
        }
    }

    // MARK: - Supporting types

    /// Error to be thrown in case of transferring failure
    enum TransferError: Error {
        case importFailed
    }

    /// The structure to get and check an image from data representation.
    struct ProfileImage: Transferable {

        /// The resulting image of transfer
        let image: Image

        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return ProfileImage(image: image)
            }
        }
    }
}
