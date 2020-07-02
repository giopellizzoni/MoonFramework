//
//  ContactLoaderTests.swift
//  DataTests
//
//  Created by Giovanni Pellizzoni on 02/07/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import XCTest


class ContactsLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL , client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}
protocol HTTPClient {
    
    func get(from url: URL)
}

class HTTPClientSpy : HTTPClient {
    
    var requestedURL: URL?
    
    func get(from url: URL)  {
     requestedURL = url
    }
}

class ContactLoaderTests: XCTestCase {


    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let (sut, client) = makeSUT()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    


}


extension ContactLoaderTests {
    func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: ContactsLoader, client: HTTPClientSpy)  {
        
        let client = HTTPClientSpy()
        let sut = ContactsLoader(url: url, client: client)
        
        return (sut, client)
        
    }
}
