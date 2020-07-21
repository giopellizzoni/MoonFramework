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
        
        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse () {
        let (sut, client) = makeSUT()
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: makeJson([]), at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPURLResponseWithEmptyJson() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyJson = makeJson([])
            client.complete(withStatusCode: 200, data: emptyJson)
        })
    }
    
    func test_load_deliverItensOn200HTTPURLResponseWithValidJson() {
        
        let (sut, client) = makeSUT()
        
        let emp1 = makeEmployee(name: "Giovanni", lname: "Pellizzoni", contactDetails: ContactDetails(email: "a-email@.com", phone: "1199"), position: "iOS", projects: "NEW CAR")
        
        let emp2 = makeEmployee(name: "John", lname: "Doe", contactDetails: ContactDetails(email: "a-email@.com", phone: "1199"), position: "iOS", projects: "OLD FLAG")
        
        
        expect(sut, toCompleteWithResult: .success([emp1.model, emp2.model]), when: {
            let employeesJson = makeJson([emp1.json, emp2.json])
            client.complete(withStatusCode: 200, data:employeesJson)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTDeallocated() {
        let url = URL(string: "a-url.com")!
        let client = HTTPClientSpy()
        
        var sut: ContactsLoader? = ContactsLoader(url: url, client: client)
        
        var capturedResult = [ContactsLoader.Result]()
        sut?.load { capturedResult.append($0)}
        sut = nil
        client.complete(withStatusCode: 200, data: makeJson([]))
        
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
}

// MARK: - Helpers

extension ContactLoaderTests {
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: ContactsLoader, client: HTTPClientSpy)  {
        
        let client = HTTPClientSpy()
        let sut = ContactsLoader(url: url, client: client)
        
        checkForMemoryLeaks(sut)
        checkForMemoryLeaks(client)
        
        return (sut, client)
        
    }
    func makeJson(_ contacts: [[String: Any]]) -> Data {
        let json = ["employees": contacts]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
    
    func makeEmployee(name: String, lname: String, contactDetails: ContactDetails, position: String, projects: String?) -> (model: Employee, json: [String: Any]) {
        
        let employee =  Employee(name: name, lname: lname, contactDetails: contactDetails, position: position, projects: projects)
        
        let json: [String: Any] = [
                "name": name,
                "lname": lname,
                "contact_details": [
                    "email": contactDetails.email,
                    "phone": contactDetails.phone ?? ""
                ],
                "position": position,
                "projects": projects ?? ""
        ]
        
        return (employee, json)
    }
    
    private func expect(_ sut: ContactsLoader, toCompleteWithResult result: ContactsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResult = [ContactsLoader.Result]()
        
        sut.load { capturedResult.append($0)}
        action()
        XCTAssertEqual(capturedResult, [result], file:file, line: line)
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
        
        func complete(withStatusCode code: Int = 200, data: Data, at index: Int = 0) {
            let response  = HTTPURLResponse(url: URL(string: "http://a-url.com")!,
                                            statusCode: code,
                                            httpVersion: nil,
                                            headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }
}
