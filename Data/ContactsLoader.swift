//
//  ContactsLoader.swift
//  Data
//
//  Created by Giovanni Pellizzoni on 02/07/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class ContactsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([Employee])
        case failure(Error)
    }
    
    public init(url: URL , client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    private struct EmployeesRoot: Decodable {
        let employees: [Contacts]
    }


    private struct Contacts: Codable{
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
    private class EmployeesMapper {
        static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [Employee] {
            guard response.statusCode == 200 else { throw ContactsLoader.Error.invalidData }
            let employees = try JSONDecoder().decode(EmployeesRoot.self, from: data)
            return employees.employees.map { $0.employee }
        }
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            
            switch result {
            case let .success(data, response):
                
                do {
                    let employees = try EmployeesMapper.map(data, response)
                    
                    completion(.success(employees))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
            
        }
    }
}


