//
//  MoonClient.swift
//  MoonFramework
//
//  Created by Giovanni Pellizzoni on 04/06/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import Foundation


class MoonClient {
    let baseURL: URL
    let session: URLSession
    let responseQueue: DispatchQueue?
    
    init(baseURL: URL, session: URLSession, responseQueue: DispatchQueue?) {
        self.baseURL = baseURL
        self.session = session
        self.responseQueue = responseQueue
    }
    
    func getEmployees(completion: @escaping (EmployeesData?, Error?) -> Void) -> URLSessionDataTask {
        let url = URL(string: "employee", relativeTo: baseURL)!        
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                error == nil,
                let data = data else {
                    self.dispatchResult(models: nil, error: error, completion: completion)
                    return
            }
            
            let decoder = JSONDecoder()
            do {
                let employees = try decoder.decode(EmployeesData.self, from: data)
                self.dispatchResult(models: employees, error: nil, completion: completion)
                
            } catch {
             self.dispatchResult(models: nil, error: error, completion: completion)
            }
        }
        task.resume()
        return task
    }
    
    private func dispatchResult<Type>(models: Type? = nil,
                                      error: Error? = nil,
                                      completion: @escaping (Type?, Error?) -> Void) {
        guard let responseQueue = responseQueue else {
            completion(models, error)
            return
        }
        
        responseQueue.async {
            completion(models, error)
        }
    }
    
}
