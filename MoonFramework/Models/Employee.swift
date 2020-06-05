//
//  Employee.swift
//  MoonFramework
//
//  Created by Giovanni Pellizzoni on 04/06/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import Foundation


struct EmployeesData: Codable, Equatable {
    
    let employees: [Employee]
    
    static func == (lhs: EmployeesData, rhs: EmployeesData) -> Bool {
        return lhs.employees == rhs.employees
    }
    
    enum CodingKeys: String, CodingKey {
        case employees = "employees"
    }
}

struct Employee: Codable, Equatable {
    
    let fname: String
    let lname: String
    let contactDetails: ContactDetails
    let position: String
    let projects: [String]?
    
    static func == (lhs: Employee, rhs: Employee) -> Bool {
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

struct ContactDetails: Codable {
    let email: String
    let phone: String?
    
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case phone = "phone"
    }
}
