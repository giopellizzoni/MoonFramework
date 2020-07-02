//
//  ContactLoaderTests.swift
//  DataTests
//
//  Created by Giovanni Pellizzoni on 02/07/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import XCTest
import Data

class ContactLoaderTests: XCTestCase {


    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-give-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    


}
// MARK: - Helpers

extension ContactLoaderTests {
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: ContactsLoader, client: HTTPClientSpy)  {
        
        let client = HTTPClientSpy()
        let sut = ContactsLoader(url: url, client: client)
        
        return (sut, client)
        
    }
    
    private class HTTPClientSpy : HTTPClient {
        
        var requestedURL: URL?
        
        func get(from url: URL)  {
         requestedURL = url
        }
    }
}
