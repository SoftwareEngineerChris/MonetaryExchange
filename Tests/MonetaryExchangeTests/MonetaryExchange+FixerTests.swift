//
//  MonetaryExchangeFixerTests.swift
//  MonetaryExchangeTests
//
//  Created by Chris Hargreaves on 04/10/2019.
//  Copyright © 2019 Software Engineering Limited. All rights reserved.
//

import XCTest
import RoundedDecimal
@testable import MonetaryExchangeSample
@testable import MonetaryExchange

final class MonetaryExchangeFixerTests: XCTestCase {
    
    private var session: StubSession!
    
    override func setUp() {
        super.setUp()
        session = StubSession()
    }
    
    override func tearDown() {
        session = nil
        super.tearDown()
    }
    
    // MARK: exchange(...)
    
    func test_exchange_default_requestsDataTask() {
        
        Exchange.Fixer.exchange(
            session: session,
            accessKey: "testKey",
            completion: { _ in }
        )
        
        XCTAssertEqual(
            session.didCallDataTaskWithRequest?.url?.absoluteString,
            "https://data.fixer.io/api/latest?access_key=testKey"
        )
    }
    
    func test_exchange_insecure_requestsDataTask() {
        
        Exchange.Fixer.exchange(
            session: session,
            secure: false,
            accessKey: "testKey",
            completion: { _ in }
        )
        
        XCTAssertEqual(
            session.didCallDataTaskWithRequest?.url?.absoluteString,
            "http://data.fixer.io/api/latest?access_key=testKey"
        )
    }
    
    func test_exchange_withoutAccessKey_requestsDataTask() {
        
        Exchange.Fixer.exchange(
            session: session,
            accessKey: nil,
            completion: { _ in }
        )
        
        XCTAssertEqual(
            session.didCallDataTaskWithRequest?.url?.absoluteString,
            "https://data.fixer.io/api/latest"
        )
    }
    
    func test_exchange_invalidURL_completesWithFailure() {
        
        var capturedResult: Result<Exchange, Exchange.Fixer.FixerError>?
        
        Exchange.Fixer.exchange(
            session: session,
            path: "invalidPath",
            accessKey: nil,
            completion: { result in capturedResult = result }
        )
        
        XCTAssertNil(session.didCallDataTaskWithRequest)
        
        guard case .failure(.invalidURL) = capturedResult else {
            return XCTFail("Expected invalidURL failure")
        }
    }
    
    func test_exchange_uponCompletion_withError_completesWithFailure() {
        
        let error = StubSession.SessionError.networkFailure
        session.shouldComplete = true
        session.shouldCompleteWithError = error
        
        var capturedResult: Result<Exchange, Exchange.Fixer.FixerError>?
        
        Exchange.Fixer.exchange(
            session: session,
            accessKey: "testKey",
            completion: { result in capturedResult = result }
        )
        
        guard case let .failure(.requestFailure(underlyingError)) = capturedResult else {
            return XCTFail("Expected requestFailure failure, got \(String(describing: capturedResult))")
        }
        
        XCTAssertEqual(underlyingError as? StubSession.SessionError, error)
    }
    
    func test_exchange_uponCompletion_noError_butNoData_completesWithFailure() {
        
        session.shouldComplete = true
        session.shouldCompleteWithError = nil
        session.shouldCompleteWithData = nil
        
        var capturedResult: Result<Exchange, Exchange.Fixer.FixerError>?
        
        Exchange.Fixer.exchange(
            session: session,
            accessKey: "testKey",
            completion: { result in capturedResult = result }
        )
        
        guard case .failure(.noData) = capturedResult else {
            return XCTFail("Expected noData failure, got \(String(describing: capturedResult))")
        }
    }
    
    func test_exchange_uponCompletion_noError_invalidData_completesWithFailure() {
        
        session.shouldComplete = true
        session.shouldCompleteWithError = nil
        session.shouldCompleteWithData = RateData.withoutBase.data(using: .utf8)
        
        var capturedResult: Result<Exchange, Exchange.Fixer.FixerError>?
        
        Exchange.Fixer.exchange(
            session: session,
            accessKey: "testKey",
            completion: { result in capturedResult = result }
        )
        
        guard case .failure(.decodingError) = capturedResult else {
            return XCTFail("Expected decodingError failure, got \(String(describing: capturedResult))")
        }
    }
    
    func test_exchange_uponCompletion_noError_validData_completesWithSuccess() {
        
        session.shouldComplete = true
        session.shouldCompleteWithError = nil
        session.shouldCompleteWithData = RateData.validJSON.data(using: .utf8)
        
        var capturedResult: Result<Exchange, Exchange.Fixer.FixerError>?
        
        Exchange.Fixer.exchange(
            session: session,
            accessKey: "testKey",
            completion: { result in capturedResult = result }
        )
        
        guard case let .success(exchange) = capturedResult else {
            return XCTFail("Expected success, got \(String(describing: capturedResult))")
        }
        
        XCTAssertEqual(exchange.base, .EUR)
        XCTAssertEqual(exchange.rates.count, 154)
        XCTAssertEqual(try? exchange.rate(from: .GBP, targetCurrency: .USD), RoundedDecimal(stringLiteral: "1.225805"))
    }
    
    func test_exchange_uponCompletion_noError_validData_resumesDataTask() {
        
        session.shouldComplete = true
        session.shouldCompleteWithError = nil
        session.shouldCompleteWithData = RateData.validJSON.data(using: .utf8)
        
        let task = Exchange.Fixer.exchange(
            session: session,
            accessKey: "testKey",
            completion: { _ in }
        )
        
        guard let stubTask = task as? StubSession.StubDataTask else {
            return XCTFail("Expected StubDataTask to be returned")
        }
        
        XCTAssertTrue(stubTask.didCallResume)
    }
    
    static var allTests = [
        ("test_exchange_default_requestsDataTask", test_exchange_default_requestsDataTask),
        ("test_exchange_insecure_requestsDataTask", test_exchange_insecure_requestsDataTask),
        ("test_exchange_withoutAccessKey_requestsDataTask", test_exchange_withoutAccessKey_requestsDataTask),
        ("test_exchange_invalidURL_completesWithFailure", test_exchange_invalidURL_completesWithFailure),
        ("test_exchange_uponCompletion_withError_completesWithFailure", test_exchange_uponCompletion_withError_completesWithFailure),
        ("test_exchange_uponCompletion_noError_butNoData_completesWithFailure", test_exchange_uponCompletion_noError_butNoData_completesWithFailure),
        ("test_exchange_uponCompletion_noError_invalidData_completesWithFailure", test_exchange_uponCompletion_noError_invalidData_completesWithFailure),
        ("test_exchange_uponCompletion_noError_validData_completesWithSuccess", test_exchange_uponCompletion_noError_validData_completesWithSuccess),
        ("test_exchange_uponCompletion_noError_validData_resumesDataTask", test_exchange_uponCompletion_noError_validData_resumesDataTask),
    ]
    
    // MARK: Test Helpers
    
    final private class StubSession: URLSession {
        
        enum SessionError: Error, Equatable {
            case networkFailure
        }
        
        var dataTask = StubDataTask()
        var shouldComplete = false
        var shouldCompleteWithData: Data?
        var shouldCompleteWithResponse: URLResponse?
        var shouldCompleteWithError: Error?
        var didCallDataTaskWithRequest: URLRequest?
        
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            didCallDataTaskWithRequest = request
            
            if shouldComplete {
                completionHandler(shouldCompleteWithData, shouldCompleteWithResponse, shouldCompleteWithError)
            }
            
            return dataTask
        }
        
        final class StubDataTask: URLSessionDataTask {
            
            var didCallResume: Bool = false
            
            override func resume() {
                didCallResume = true
            }
        }
    }
}
