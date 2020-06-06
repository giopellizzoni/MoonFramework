//
//  MoonClientTests.swift
//  MoonFrameworkTests
//
//  Created by Giovanni Pellizzoni on 04/06/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import XCTest
@testable import MoonFramework

class MoonClientTests: XCTestCase {
    
    var baseURL: URL!
    var sut: MoonClient!
    var mockSession: MockURLSession!
    
    var employeesURL: URL {
        return URL(string: "employee_list", relativeTo: baseURL)!
    }
    
    // MARK: - Initialization
    override func setUp() {
        super.setUp()
        baseURL = URL(string:"http://www.testurl.com")!
        mockSession = MockURLSession()
        sut = MoonClient(baseURL: baseURL, session: mockSession, responseQueue: nil)
        
        
    }
    
    override func tearDown() {
        baseURL = nil
        mockSession = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Helpers
    func whenGetEmployees(data: Data? = nil,
                          statusCode: Int = 200,
                          error: NSError? = nil) ->
        (calledCompletion: Bool,
        employees: EmployeesData?,
        error: NSError?) {
            
            let response = HTTPURLResponse(url: employeesURL,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            
            var calledCompletion = false
            var receivedEmployees: EmployeesData? = nil
            var receivedError: NSError? = nil
            
            let mockTask = sut.getEmployees { (employees, error) in
                calledCompletion = true
                receivedEmployees = employees
                receivedError = error as NSError?
                } as! MockURLSessionDataTask
            
            mockTask.completionHandler(data, response, error)
            return (calledCompletion, receivedEmployees, receivedError)
    }
    
    func verifyGetEmployeesDispatchedToMain(data: Data? = nil,
                                                 statusCode: Int = 200,
                                                 error:Error? = nil,
                                                 line: UInt = #line) {
        
        mockSession.givenDispatchQueue()
        
        sut = MoonClient(baseURL: baseURL,
                         session: mockSession,
                         responseQueue: .main)
        
        let expectation = self.expectation(description: "Completion no called")
        
        var thread: Thread!
        let mockTask = sut.getEmployees { (empleyees, error) in
            thread = Thread.current
            expectation.fulfill()
        } as! MockURLSessionDataTask
        
        let response = HTTPURLResponse(url: employeesURL,
                                       statusCode: statusCode,
                                       httpVersion: nil,
                                       headerFields: nil)
        
        
        mockTask.completionHandler(data, response, error)
        waitForExpectations(timeout: 0.5) { (_) in
            XCTAssertTrue(thread.isMainThread)
        }
        
    }
    
    
    // MARK: - Inits
    
    func test_init_setClientBaseURL() {
        XCTAssertEqual(sut.baseURL, baseURL)
    }
    
    func test_init_setClientSession() {
        XCTAssertEqual(sut.session, mockSession)
    }
    
    func test_getEmployees_callExpectedURL() {
        let mockTask = sut.getEmployees(completion: { (_, _) in
        }) as! MockURLSessionDataTask
        
        XCTAssertEqual(mockTask.url, employeesURL)
    }
    
    func test_getEmployees_calledResumeOnTask() {
        let mockTask = sut.getEmployees(completion: { (_, _) in
        }) as! MockURLSessionDataTask
        
        XCTAssertTrue(mockTask.calledResume)
    }

    
    // MARK: - Handling Errors
    
    func test_getEmployees_responseWithStatusCode500CallsCompletion() {
        let result = whenGetEmployees(statusCode: 500)
        
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.employees)
        XCTAssertNil(result.error)
        
    }
    
    func test_getEmployees_callsCompletionWithError() throws {
        let expectedError = NSError(domain: "br.com.pellizzonicode.MoonFramework",
                                    code: 42)
        
        let result = whenGetEmployees(error: expectedError)
        
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.employees)
        
        let actualError = try XCTUnwrap(result.error as NSError?)
        XCTAssertEqual(actualError, expectedError)
    }
    
    //MARK: - Decoding Results
    
    func test_getEmployees_callsCompletionWithValidJson() throws {
        let data = try Data.fromJSON(fileName: "Contacts_Valid_JSON")
        
        let decoder = JSONDecoder()
        let employeesData = try decoder.decode(EmployeesData.self, from: data)
        
        let result = whenGetEmployees(data: data)
        
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.error)
        XCTAssertEqual(result.employees, employeesData)
    }
    
    func test_getEmployees_callsCompletionWithInvalidJson() throws {
        let data = try Data.fromJSON(fileName: "Contacts_Invalid_JSON")
        
        var expectedError: NSError!
        let decoder = JSONDecoder()
        do {
            let _ = try decoder.decode(EmployeesData.self, from: data)
        } catch {
            expectedError = error as NSError
        }
        
        let result = whenGetEmployees(data: data)
        
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.employees)
        
        let actualError = try XCTUnwrap(result.error as NSError?)
        XCTAssertEqual(actualError.domain, expectedError.domain)
        XCTAssertEqual(actualError.code, expectedError.code)
    }
    
    // MARK: - Dispatch To a Queue
    
    func test_init_sets_responseQueue() {
        let responseQueue = DispatchQueue.main
        
        sut = MoonClient(baseURL: employeesURL,
                         session: mockSession,
                         responseQueue: responseQueue)
        
        XCTAssertEqual(sut.responseQueue, responseQueue)
    }
    
    func test_getEmployees_givenHTTPStatusError_dispatchersToResponseQueue() {
        verifyGetEmployeesDispatchedToMain(statusCode: 500)
    }
    
    func test_getEmployees_givenError_dispatchersToResponseQueue() {
        
        let error = NSError(domain: "br.com.pellizzonicode.MoonFramework",
                            code: 200)
        verifyGetEmployeesDispatchedToMain(error: error)
        
    }
    
    func test_getEmployees_givenGoodResponse_dispatchesToResponseQueue() throws {
        let data = try Data.fromJSON(fileName: "Contacts_Valid_JSON")
        
        verifyGetEmployeesDispatchedToMain(data: data)
    }
    
    func test_getEmployees_givenInvalidResponse_dispatchesToResponseQueue() throws {
        let data = try Data.fromJSON(fileName: "Contacts_Invalid_JSON")
        verifyGetEmployeesDispatchedToMain(data: data)
    }
}


class MockURLSession: URLSession {
    
    var queue: DispatchQueue? = nil
    
    override init() { }
    
    override func dataTask(with url: URL,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask(completionHandler: completionHandler, url: url, queue: queue)
    }
    
    func givenDispatchQueue() {
        queue = DispatchQueue(label: "br.com.pellizzoni.MookFramework.Queue")
    }
    
}

class MockURLSessionDataTask: URLSessionDataTask {
    
    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    var url: URL
    var calledResume: Bool = false
    
    init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void,
         url: URL,
         queue: DispatchQueue?) {
        
        self.url = url
        
        if let queue = queue {
            self.completionHandler = { data, response, error in
                queue.async {
                    completionHandler(data, response, error)
                }
            }
        } else {
            self.completionHandler = completionHandler
        }
    }
    
    override func resume() {
        calledResume = true
    }
}
