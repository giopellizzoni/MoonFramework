//
//  HTTPClient.swift
//  Data
//
//  Created by Giovanni Pellizzoni on 21/07/20.
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
