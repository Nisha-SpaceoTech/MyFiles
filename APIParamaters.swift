//
//  APIParamaters.swift
//  Utmostu
//
//  Created by SOTSYS138 on 06/04/17.
//  Copyright © 2017 Sohil Memon. All rights reserved.
//

import UIKit

enum LoginParamaters: String {
    case email
    case password
    case device_type
    case device_token
    case os_version
}

enum SignUpParamaters: String {
    case email
    case password
    case device_type
    case device_token
    case os_version
}

enum SignUpWithFacebookParamaters: String {
    case email
    case facebook_id
    case password
    case device_type
    case device_token
    case os_version
}

enum AddPost: String {
    case post_type
    case media
    case description
    case offset
}

enum SharePost: String {
    case post_id
    case social_account_id
    case token
    case expired_at
    case social_post_id
}
