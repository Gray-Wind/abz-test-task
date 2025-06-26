//
//  UsersViewModel.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 24.06.2025.
//

import SwiftUI

/// The model to cover users screen
@MainActor
class UsersViewModel: ObservableObject {

    /// The list of currently loaded users
    ///
    /// The list will be updated with ``loadMoreUsers()`` call.
    @Published var users: [ProfileCardData] = []

    /// The loading state of the model
    ///
    /// The initial state is `true`, will be switched to `false` once the model made its first users update.
    @Published var isLoading: Bool = true
    /// The identification if a network call was not successful due to network problem
    ///
    /// To retry the failed operation please see ``retry(action:)``.
    @Published var noInternetIssue: RetryAction?

    /// The number of a page to load on the next call of ``loadMoreUsers()``
    private var nextPage: Int = 1
    /// The total amount of pages of users, used to update ``canLoadMore``.
    private var totalPages: Int = .max

    /// The flag identifying if the model can load more users
    var canLoadMore: Bool {
        nextPage <= totalPages
    }

    /// The instance of network manager to use with the model
    private var networkManager: NetworkManager

    /// The initializer to make it possible to cover the model with tests
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    /// The method to reset the state of the model
    ///
    /// This is a lazy implementation of reload action. Better would be use array controller or similar and merge necessary changes. Especially taking into account that user list coming from the server side is always sorted be recently signed up user.
    func reset() async {
        isLoading = true
        users.removeAll()
        nextPage = 1
        totalPages = .max
    }

    /// The method to load more users from the server
    ///
    /// If network issue occurs (not connected to internet), ``noInternetIssue`` will be updated accordingly.
    func loadMoreUsers() async {
        defer { isLoading = false }
        do {
            let users = try await networkManager.request(.getUsers(page: nextPage, count: 6), responseType: UsersModel.self)
            nextPage += 1
            self.totalPages = users.totalPages

            self.users.append(
                contentsOf: users.users.map {
                    ProfileCardData(
                        id: $0.id,
                        imageUrl: $0.photoUrl,
                        name: $0.name,
                        title: $0.position,
                        email: $0.email,
                        phone: $0.phone
                    )
            })
        } catch let error as FailResponse {
            logger.error("Cannot get users: \(error.message ?? "No message")")
        } catch let error as URLError {
            if error.code == .notConnectedToInternet {
                noInternetIssue = .getUsers
                return
            }
            logger.error("Network error: \(error.localizedDescription)")
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
        }
    }

    /// The method to retry the failed operation
    ///
    /// The last failed operation is stored in ``noInternetIssue``.
    func retry(action: RetryAction) async {
        switch action {
        case .getUsers:
            noInternetIssue = nil
            await loadMoreUsers()
        }
    }

    /// The enum describing actions on which network issue occurred
    enum RetryAction: Identifiable {
        case getUsers       ///< There was a network issue while getting users

        var id: Self {
            return self
        }
    }
}
