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
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-give-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    
    func test_load_deliversErrorOnCientErrors () {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity, when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse () {
        let (sut, client) = makeSUT()
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithError: .invalidData, when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData, when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
}

// MARK: - Helpers

extension ContactLoaderTests {
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: ContactsLoader, client: HTTPClientSpy)  {
        
        let client = HTTPClientSpy()
        let sut = ContactsLoader(url: url, client: client)
        
        return (sut, client)
        
    }
    
    private func expect(_ sut: ContactsLoader, toCompleteWithError error: ContactsLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedError = [ContactsLoader.Error]()
        
        sut.load { capturedError.append($0)}
        action()
        XCTAssertEqual(capturedError, [error], file:file, line: line)
    }
    
    private class HTTPClientSpy : HTTPClient {
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        var completions = [(HTTPClientResult) -> Void]()
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)  {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int = 200, data: Data = Data(), at index: Int = 0) {
            let response  = HTTPURLResponse(url: URL(string: "http://a-url.com")!,
                                            statusCode: code,
                                            httpVersion: nil,
                                            headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }
}
