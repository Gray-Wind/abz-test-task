//
//  UsersScreen.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 24.06.2025.
//

import SwiftUI

/// The users screen to show all signed up users
struct UsersScreen: View {

    @StateObject private var viewModel = UsersViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .onAppear {
                        Task {
                            await viewModel.loadMoreUsers()
                        }
                    }
                Spacer()
            } else if viewModel.users.isEmpty {
                Spacer()
                NoUsersScreen()
                Spacer()
            } else {
                List {
                    ForEach(viewModel.users) { user in
                        ProfileCard(cardData: user)
                    }
                    if viewModel.canLoadMore, !viewModel.isLoading {
                        ProgressView()
                            .onAppear {
                                Task {
                                    await viewModel.loadMoreUsers()
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .sheet(item: $viewModel.noInternetIssue) { action in
            NoInternetScreen {
                Task {
                    await viewModel.retry(action: action)
                }
            }
        }
        .refreshable {
            Task {
                await viewModel.reset()
            }
        }
    }
}

#Preview {
    UsersScreen()
}
