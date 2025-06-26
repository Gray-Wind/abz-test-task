//
//  DataModel.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 12.06.2025.
//

import MetaCodable
import HelperCoders
import Foundation // for Date

@Codable
@CodingKeys(.snake_case)
struct FailResponseFunc {

    let success: Bool
    let message: String?
    let fails: [String: [String]]?

    func callAsFunction(statusCode: Int) -> FailResponse {
        FailResponse(
            success: success,
            statusCode: statusCode,
            message: message,
            fails: fails
        )
    }
}

struct FailResponse: Error {

    let success: Bool
    let statusCode: Int
    let message: String?
    let fails: [String: [String]]?
}

@Codable
@CodingKeys(.snake_case)
struct UsersModel {

    let page: Int
    let totalPages: Int
    let totalUsers: Int
    let count: Int
    let links: LinksModel
    let users: [UserModel]

    @Codable
    @CodingKeys(.snake_case)
    struct LinksModel {

        let nextUrl: String?
        let previousUrl: String?
    }

    @Codable
    @CodingKeys(.snake_case)
    struct UserModel {

        let id: Int
        let name: String
        let email: String
        let phone: String
        let position: String
        let positionId: Int
        @CodedBy(Since1970DateCoder())
        @CodedAs("registration_timestamp")
        let registrationDate: Date
        @CodedAs("photo")
        let photoUrl: String
    }
}

@Codable
@CodingKeys(.snake_case)
struct PositionsModel {

    let positions: [PositionModel]

    @Codable
    struct PositionModel {
        let id: Int
        let name: String
    }
}

@Codable
@CodingKeys(.snake_case)
struct TokenModel {

    let token: String
}

@Codable
@CodingKeys(.snake_case)
struct SignUpResponseModel {

    let userId: Int
    let message: String
}


