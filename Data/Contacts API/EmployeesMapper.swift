//
//  EmployeesMapper.swift
//  Data
//
//  Created by Giovanni Pellizzoni on 21/07/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import Foundation


internal final class EmployeesMapper {
    private struct EmployeesRoot: Decodable {
        let employees: [Contacts]
        
        var contacts: [Employee] {
            return employees.map { $0.employee }
        }
    }
    
    private struct Contacts: Codable {
        let name, lname: String
        let contactDetails: ContactDetails
        let position: String
        let projects: String?
        
        var employee: Employee {
            return Employee(name: name, lname: lname, contactDetails: contactDetails, position: position, projects: projects)
        }
        
        private struct ContactDetailst: Codable, Equatable {
            public let email: String
            public let phone: String?
        }
        
        enum CodingKeys: String, CodingKey {
            case name, lname
            case contactDetails = "contact_details"
            case position, projects
        }
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> ContactsLoader.Result {
        
        guard response.statusCode == 200,
            let employees = try? JSONDecoder().decode(EmployeesRoot.self, from: data) else { return  .failure(.invalidData) }
        
        return .success(employees.contacts)
        
    }
}
