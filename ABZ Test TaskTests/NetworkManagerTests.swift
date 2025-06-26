//
//  IntegrationTests.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 15.06.2025.
//

import Testing
@testable import ABZ_Test_Task
import Foundation

actor MockUrlSession {

    private var mockDataResponse: (Data, URLResponse)?

    func setMockDataResponse(_ dataResponse: (Data, URLResponse)?) {
        self.mockDataResponse = dataResponse
    }
}

extension MockUrlSession: URLSessionProtocol {

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        guard let mockDataResponse else {
            throw URLError(.resourceUnavailable)
        }

        return mockDataResponse
    }
}

struct NetworkManagerTests {

    let baseUrl = URL(string: "https://example.com")!

    @Test func getToken() async throws {
        let mockSession = MockUrlSession()
        let responseData = """
            {
                "success": true,
                "token": "tokenValue"
            }
            """.data(using: .utf8)!
        await mockSession.setMockDataResponse((
            responseData,
            HTTPURLResponse(
                url: baseUrl,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        ))
        let networkManager = NetworkManager(urlSession: mockSession)
        let urlRequest = URLRequest(url: baseUrl)
        let tokenModel = try await networkManager.request(.init(urlRequest: urlRequest), responseType: TokenModel.self)
        #expect(tokenModel.token == "tokenValue")
    }

    @Test func signUpWithInvalidFields() async throws {
        let mockSession = MockUrlSession()
        let responseData = """
            {
              "success": false,
              "message": "Validation failed",
              "fails": {
                "name": [
                  "The name must be at least 2 characters."
                ],
                "email": [
                  "The email must be a valid email address."
                ],
                "phone": [
                  "The phone field is required."
                ],
                "position_id": [
                  "The position id must be an integer."
                ],
                "photo": [
                  "The photo may not be greater than 5 Mbytes."
                ]
              }
            }
            """.data(using: .utf8)!

        await mockSession.setMockDataResponse(
            (
                responseData,
                HTTPURLResponse(
                    url: baseUrl,
                    statusCode: 422,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
        )
        let networkManager = NetworkManager(urlSession: mockSession)
        let urlRequest = URLRequest(url: baseUrl)
        let failResponse = try await #require(throws: FailResponse.self) {
            try await networkManager.request(.init(urlRequest: urlRequest), responseType: SignUpResponseModel.self)
        }
        #expect(failResponse.message == "Validation failed")
        #expect(
            failResponse.fails == [
                "name": ["The name must be at least 2 characters."],
                "email": ["The email must be a valid email address."],
                "phone": ["The phone field is required."],
                "position_id": ["The position id must be an integer."],
                "photo": ["The photo may not be greater than 5 Mbytes."]
            ]
        )
    }

    @Test func signUpWithValidFields() async throws {
        let mockSession = MockUrlSession()
        let responseData = """
            {
                "success": true,
                "user_id": 23,
                "message": "New user successfully registered"
            }
            """.data(using: .utf8)!

        await mockSession.setMockDataResponse(
            (
                responseData,
                HTTPURLResponse(
                    url: baseUrl,
                    statusCode: 201,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
        )
        let networkManager = NetworkManager(urlSession: mockSession)
        let urlRequest = URLRequest(url: baseUrl)
        let signUpResponseModel = try await networkManager.request(.init(urlRequest: urlRequest), responseType: SignUpResponseModel.self)
        #expect(signUpResponseModel.userId == 23)
        #expect(signUpResponseModel.message == "New user successfully registered")
    }
}
