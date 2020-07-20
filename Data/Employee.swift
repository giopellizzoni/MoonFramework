//
//  Employee.swift
//  Data
//
//  Created by Giovanni Pellizzoni on 02/07/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import Foundation

// MARK: - Employee
public struct Employee: Codable, Equatable{
    public let name, lname: String
    public let contactDetails: ContactDetails
    public let position: String
    public let projects: String?
    
    public init(name: String, lname: String, contactDetails: ContactDetails, position: String, projects: String?) {
        self.name = name
        self.lname = lname
        self.contactDetails = ContactDetails(email: contactDetails.email, phone: contactDetails.phone)
        self.position = position
        self.projects = projects
    }
    
    enum CodingKeys: String, CodingKey {
        case name, lname
        case contactDetails = "contact_details"
        case position, projects
    }
}

// MARK: - ContactDetails
public struct ContactDetails: Codable, Equatable {
    public let email: String
    public let phone: String?
    
    public init(email: String, phone: String?) {
        self.email = email
        self.phone = phone
    }
}
