//
//  Typography.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 11.06.2025.
//

import SwiftUI

/*
 List of Nunito Sans names provided with the font:
 NunitoSans-12ptExtraLight_Regular
 NunitoSans-12ptExtraLight
 NunitoSans-12ptExtraLight_Light
 NunitoSans-12ptExtraLight_Medium
 NunitoSans-12ptExtraLight_SemiBold
 NunitoSans-12ptExtraLight_Bold
 NunitoSans-12ptExtraLight_ExtraBold
 NunitoSans-12ptExtraLight_Black
 */

/// The extension of Font to proved custom fonts
///
/// The current implementation is not using line heights, which should differ
extension Font {

    static let abzHeading1: Font = .custom("NunitoSans-12ptExtraLight_Light", size: 20) // lineHeight: 24
    static let abzBody1: Font = .custom("NunitoSans-12ptExtraLight_Light", size: 16) // lineHeight: 24
    static let abzBody2: Font = .custom("NunitoSans-12ptExtraLight_Light", size: 18) // lineHeight: 20
    static let abzBody3: Font = .custom("NunitoSans-12ptExtraLight_Light", size: 14) // lineHeight: 20
}
