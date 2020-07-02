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
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-give-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-give-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    
    func test_load_deliversErroOnCientErrors () {
        let (sut, client) = makeSUT()
        
        
        var capturedError: ContactsLoader.Error?
        
        sut.load { error in
            capturedError = error
        }
        
        let clientError = NSError(domain: "Test", code: 0)
        
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, .connectivity)
        
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
        var requestedURLs = [URL]()
        var completions = [(Error) -> Void]()
        
        func get(from url: URL, completion: @escaping (Error) -> Void)  {
            completions.append(completion)
            requestedURLs.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }
}
