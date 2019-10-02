//
//  MonetaryExchangeTests.swift
//  MonetaryExchangeTests
//
//  Created by Chris Hargreaves on 02/10/2019.
//  Copyright © 2019 Software Engineering Limited. All rights reserved.
//

import XCTest
import MonetaryAmount
@testable import MonetaryExchangeSample
@testable import MonetaryExchange

final class MonetaryExchangeTests: XCTestCase {
    
    // MARK: Decoding
    
    func test_decoding_validJSON_notNil() {
        
        let exchange = try? JSONDecoder().decode(Exchange.self, from: RateData.validJSON.data(using: .utf8)!)
        
        XCTAssertNotNil(exchange)
    }

    func test_decoding_validJSON_correctBase() {
        
        let exchange = try? JSONDecoder().decode(Exchange.self, from: RateData.validJSON.data(using: .utf8)!)
        
        XCTAssertEqual(exchange?.base, .EUR)
    }

    func test_decoding_validJSON_correctRates() {
        
        let exchange = try? JSONDecoder().decode(Exchange.self, from: RateData.validJSON.data(using: .utf8)!)
        
        XCTAssertEqual(exchange?.rates.count, 154)
    }
    
    func test_decoding_missingBase_nil() {
        
        let exchange = try? JSONDecoder().decode(Exchange.self, from: RateData.withoutBase.data(using: .utf8)!)
        
        XCTAssertNil(exchange)
    }

    func test_decoding_unknownBase_nil() {
        
        let exchange = try? JSONDecoder().decode(Exchange.self, from: RateData.unknownBase.data(using: .utf8)!)
        
        XCTAssertNil(exchange)
    }
    
    // MARK: Rates
    
    func test_rate_originTargetEqual_returns1() {
        
        let rate = try? Exchange.sample.rate(from: .USD, targetCurrency: .USD)
        
        XCTAssertEqual(rate, 1)
    }
    
    func test_rate_hasDirectRateFromBase_returnsRate() {
        
        let rate = try? Exchange.sample.rate(from: Exchange.sample.base, targetCurrency: .USD)
        
        XCTAssertEqual(rate, "1.092037")
    }
    
    func test_rate_hasIndirectRateFromBase_returnsRate() {
        
        let rate = try? Exchange.sample.rate(from: .GBP, targetCurrency: .USD)
        
        XCTAssertEqual(rate, "1.225805")
    }
    
    func test_rate_hasNoRateFromBase_throws() {

        XCTAssertThrowsError(try Exchange.sample.rate(from: .GBP, targetCurrency: Currency(name: "Test", code: "TEST", minorUnit: 2)))
    }
    
    // MARK: Conversion
    
    func test_convert_toSameCurrency_returnsOriginalAmount() {
        
        let result = try? Exchange.sample.convert(monetaryAmount: 10.45.in(.USD), to: .USD)
        
        XCTAssertEqual(result, 10.45.in(.USD))
    }
    
    func test_convert_hasDirectRateFromBase_returnsConvertedAmount() {
        
        let result = try? Exchange.sample.convert(monetaryAmount: 10.45.in(.EUR), to: .USD)
        
        XCTAssertEqual(result, 11.41.in(.USD))
    }
    
    func test_rate_hasIndirectRateFromBase_returnsConvertedAmount() {
        
        let result = try? Exchange.sample.convert(monetaryAmount: 10.45.in(.GBP), to: .USD)
        
        XCTAssertEqual(result, 12.81.in(.USD))
    }
    
    func test_convert_hasNoRateFromBase_throws() {

        XCTAssertThrowsError(try Exchange.sample.convert(monetaryAmount: 10.45.in(.GBP), to: Currency(name: "Test", code: "TEST", minorUnit: 2)))
    }

    static var allTests = [
        ("test_decoding_validJSON_notNil", test_decoding_validJSON_notNil),
        ("test_decoding_validJSON_correctBase", test_decoding_validJSON_correctBase),
        ("test_decoding_validJSON_correctRates", test_decoding_validJSON_correctRates),
        ("test_decoding_missingBase_nil", test_decoding_missingBase_nil),
        ("test_decoding_unknownBase_nil", test_decoding_unknownBase_nil),
        ("test_rate_originTargetEqual_returns1", test_rate_originTargetEqual_returns1),
        ("test_rate_hasDirectRateFromBase_returnsRate", test_rate_hasDirectRateFromBase_returnsRate),
        ("test_rate_hasIndirectRateFromBase_returnsRate", test_rate_hasIndirectRateFromBase_returnsRate),
        ("test_rate_hasNoRateFromBase_throws", test_rate_hasNoRateFromBase_throws),
        ("test_convert_toSameCurrency_returnsOriginalAmount", test_convert_toSameCurrency_returnsOriginalAmount),
        ("test_convert_hasDirectRateFromBase_returnsConvertedAmount", test_convert_hasDirectRateFromBase_returnsConvertedAmount),
        ("test_rate_hasIndirectRateFromBase_returnsConvertedAmount", test_rate_hasIndirectRateFromBase_returnsConvertedAmount),
        ("test_convert_hasNoRateFromBase_throws", test_convert_hasNoRateFromBase_throws),
    ]
}
