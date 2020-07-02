//
//  ContactsLoaderTest.swift
//  MoonFrameworkTests
//
//  Created by Giovanni Pellizzoni on 01/07/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import XCTest

protocol HTTPGetClient {
    func get(from url: URL)
}

class ContactsLoader {
    private let url: URL
    private let client: HTTPGetClient?
    
    init(_ url: URL, with client: HTTPGetClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client?.get(from: url)
    }
    
}


class ContactsLoaderTest: XCTestCase {
    
    func test_init_contactsloader_with_correct_url() {
        
        let url = URL(string: "http://a-url.com")!
        let client = HTTPGetClientSpy()
        let sut = ContactsLoader(url, with: client)
        
        sut.load()
        
        XCTAssertEqual(client.url, url)
        
    }
    
    
    
    
    
}

extension ContactsLoaderTest {
    class HTTPGetClientSpy: HTTPGetClient {
        var url: URL?
        
        func get(from url: URL) {
            self.url = url
        }
    }
}
