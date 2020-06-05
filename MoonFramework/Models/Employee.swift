//
//  Employee.swift
//  MoonFramework
//
//  Created by Giovanni Pellizzoni on 04/06/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import Foundation


public struct EmployeesData: Codable, Equatable {
    
    public let employees: [Employee]
    
    public static func == (lhs: EmployeesData, rhs: EmployeesData) -> Bool {
        return lhs.employees == rhs.employees
    }
    
    enum CodingKeys: String, CodingKey {
        case employees = "employees"
    }
}

public struct Employee: Codable, Equatable {
    
    public let fname: String
    public let lname: String
    public let contactDetails: ContactDetails
    public let position: String
    public let projects: [String]?
    
    public static func == (lhs: Employee, rhs: Employee) -> Bool {
        return (lhs.fname == rhs.fname && rhs.lname == rhs.lname)
    }
    
    enum CodingKeys: String, CodingKey {
        case fname = "fname"
        case lname = "lname"
        case contactDetails = "contact_details"
        case position = "position"
        case projects = "projects"
        
    }
    
}

public struct ContactDetails: Codable {
    public let email: String
    public let phone: String?
    
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case phone = "phone"
    }
}
