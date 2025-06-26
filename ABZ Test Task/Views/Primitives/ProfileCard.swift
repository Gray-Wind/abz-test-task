//
//  ProfileCard.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI
import PhoneNumberKit

/// The data required to present the profile card
struct ProfileCardData: Identifiable {

    /// The id of the profile to make the view identifiable
    let id: Int
    /// The url to asynchronously download a profile image
    let imageUrl: String?
    /// The name of the person shown in the profile
    let name: String
    /// The title of the person shown in the profile
    let title: String
    /// The email address of the person shown in the profile
    let email: String
    /// The phone number of the person shown in the profile
    let phone: String

    /// The initializer of the data object representation of the profile
    init(
        id: Int,
        imageUrl: String?,
        name: String,
        title: String,
        email: String,
        phone: String
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.name = name
        self.title = title
        self.email = email
        self.phone = PhoneNumberFormatter().string(for: phone)!
    }
}

/// The profile card view
struct ProfileCard: View {

    /// The data for the profile card
    let cardData: ProfileCardData

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CachedAsyncImage(string: cardData.imageUrl) { image in
                image
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(.circle)
            } placeholder: {
                Image(.photoCover)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(cardData.name)
                    .font(.abzBody2)
                    .lineLimit(nil)
                    .padding(.bottom, 5)
                Text(cardData.title)
                    .lineLimit(nil)
                    .opacity(0.6)
                    .padding(.bottom, 8)
                Text(cardData.email)
                    .padding(.bottom, 5)
                Text(cardData.phone)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.abzBody3)
            .lineLimit(1)
            .opacity(0.87)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    ProfileCard(cardData: .init(
        id: 0,
        imageUrl: nil,
        name: "Some very long name to fit in the card not fully but partially",
        title: "Backend developer",
        email: "a_very_long_email_address_which_should_be_truncated_anyway@example.com",
        phone: "+38 (099) 123-45-67 (mobile)"
    ))
    .border(.black)
    ProfileCard(cardData: .init(
        id: 0,
        imageUrl: nil,
        name: "Short name",
        title: "Designer",
        email: "some@example.com",
        phone: "+38 (099) 123-45-67"
    ))
    .border(.black)
}
