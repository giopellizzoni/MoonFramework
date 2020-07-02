//
//  Employee.swift
//  Data
//
//  Created by Giovanni Pellizzoni on 02/07/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import Foundation

// MARK: - Employee
struct Employee: Codable {
    let name, lname: String
    let contactDetails: ContactDetails
    let position: String
    let projects: [String]

    enum CodingKeys: String, CodingKey {
        case name, lname
        case contactDetails = "contact_details"
        case position, projects
    }
}

// MARK: - ContactDetails
struct ContactDetails: Codable {
    let email, phone: String
}
