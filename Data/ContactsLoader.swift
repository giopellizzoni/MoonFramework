//
//  ContactsLoader.swift
//  Data
//
//  Created by Giovanni Pellizzoni on 02/07/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public final class ContactsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL , client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}


