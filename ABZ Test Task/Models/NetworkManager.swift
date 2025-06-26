//
//  NetworkManager.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 15.06.2025.
//

import Foundation
import MultipartKit

/// The error network manage could return
enum NetworkManagerError: Error {

    case invalidResponse
    case decodingFailed
    case failResponse(Int)
    case serverError
}

/// The protocol for URLSession to make it possible to cover network manager with tests
public protocol URLSessionProtocol {

    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// The extension of URLSession with protocol to make it possible to cover network manager with tests
extension URLSession: URLSessionProtocol {}

/// The network manager to perform network call, and to parse the given response
actor NetworkManager {

    /// The shared instance of network manager
    public static let shared = NetworkManager()

    private let session: URLSessionProtocol
    private let decoder: JSONDecoder

    /// The initializer of the network manager with custom url session and decoder
    ///
    /// Provide url session or decoder in order to customize the behavior of the manager and/or to use it in tests.
    init(urlSession: URLSessionProtocol = URLSession.shared, decoder: JSONDecoder = .init()) {
        self.session = urlSession
        self.decoder = decoder
    }

    /// The method to perform a network request
    ///
    /// - Parameter request: The request to perform
    /// - Parameter responseType: The expected type of response
    ///
    /// - throws: Network issue from session delegate, ``NetworkManagerError`` or ``FailResponse`` with the description of the issue from the server side.
    public func request<T: Decodable>(_ request: Request, responseType: T.Type) async throws -> T {
        logger.debug("Requesting \(String(describing: request.urlRequest))")
        let (data, response) = try await session.data(for: request.urlRequest)

        do {
            try validate(response: response, data: data)
        } catch NetworkManagerError.failResponse(let statusCode) {
            let failResponse = try decoder.decode(FailResponseFunc.self, from: data)
            throw failResponse(statusCode: statusCode)
        }

        return try decoder.decode(responseType, from: data)
    }

    /// The validation of the response
    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkManagerError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 400..<500:
            throw NetworkManagerError.failResponse(httpResponse.statusCode)
        case 500..<600:
            throw NetworkManagerError.serverError
        default:
            throw NetworkManagerError.invalidResponse
        }
    }

    /// The request used in the network manager
    enum Request {

        /// Get users starting from the given page of given amount
        case getUsers(page: Int, count: Int)
        /// Get user data with given id
        case getUser(id: Int)
        /// Get positions
        case positions
        /// Get token
        case getToken
        /// Post data to sign up user with the given token
        case signUp(_ data: SignUpData, token: String)

        // There could be a switch between Test/Staging/Prod envs
        private static let baseUrl = URL(string: "https://frontend-test-assignment-api.abz.agency/api/v1/")!

        /// The url request which will be actually used to perform a network call
        var urlRequest: URLRequest {
            let url: URL
            switch self {
            case .getUsers, .signUp:
                url = Request.baseUrl.appendingPathComponent("users")
            case .getUser(id: let id):
                url = Request.baseUrl.appendingPathComponent("users/\(id)")
            case .positions:
                url = Request.baseUrl.appendingPathComponent("positions")
            case .getToken:
                url = Request.baseUrl.appendingPathComponent("token")
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            if case let .signUp(signUpData, token) = self {
                request.httpMethod = "POST"
                let boundary = "Boundary-\(UUID().uuidString)"
                // The only reason to use multipart parts is to add filename and content type to a photo
                // Otherwise it would be much easier to just use decodable
                let parts: [MultipartPart] = [
                    .init(
                        headerFields: .init([
                            .init(name: .contentDisposition, value: "form-data; name=\"name\""),
                        ]),
                        body: signUpData.name.data(using: .utf8)!
                    ),
                    .init(
                        headerFields: .init([
                            .init(name: .contentDisposition, value: "form-data; name=\"email\""),
                        ]),
                        body: signUpData.email.data(using: .utf8)!
                    ),
                    .init(
                        headerFields: .init([
                            .init(name: .contentDisposition, value: "form-data; name=\"phone\""),
                        ]),
                        body: signUpData.phone.data(using: .utf8)!
                    ),
                    .init(
                        headerFields: .init([
                            .init(name: .contentDisposition, value: "form-data; name=\"position_id\""),
                        ]),
                        body: String(signUpData.position_id).data(using: .utf8)!
                    ),
                    .init(
                        headerFields: .init([
                            .init(name: .contentType, value: "image/jpeg"),
                            .init(name: .contentDisposition, value: "form-data; name=\"photo\"; filename=\"image.jpg\"")  // NB: filename is required, otherwise server returns 500
                        ]),
                        body: signUpData.photo ?? Data()
                    ),
                ]

                request.httpBody = MultipartSerializer(boundary: boundary).serialize(parts: parts)
                request.setValue(token, forHTTPHeaderField: "Token")
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            } else if case let .getUsers(page, count) = self {
                let queryItems: [URLQueryItem] = [
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "count", value: String(count)),
                ]
                request.url?.append(queryItems: queryItems)
            }

            return request
        }

        /// The representation of data to be sent with sign up call
        struct SignUpData: Encodable {

            let name: String
            let email: String
            let phone: String
            let position_id: Int
            let photo: Data?
        }
    }
}
