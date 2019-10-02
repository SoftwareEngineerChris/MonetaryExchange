//
//  MonetaryExchange.swift
//  MonetaryExchange
//
//  Created by Chris Hargreaves on 02/10/2019.
//  Copyright © 2019 Software Engineering Limited. All rights reserved.
//

import Foundation
import RoundedDecimal
import MonetaryAmount

public struct Exchange {
    
    public typealias Rate = RoundedDecimal<Places.six>
    
    let base: Currency
    let rates: [Currency: Rate]
    
    public init(base: Currency, rates: [Currency: Rate]) {
        self.base = base
        self.rates = rates
    }
    
    public enum ExchangeError: Error {
        case decodeError
        case noRateError
    }
    
    public func rate(from originCurrency: Currency, targetCurrency: Currency) throws -> Rate {
        
        if originCurrency == targetCurrency {
            return 1
        }
        
        if originCurrency == base, let rate = rates[targetCurrency] {
            return rate
        }
        
        guard let rateFromBaseToOrigin = rates[originCurrency],
            let rateFromBaseToTarget = rates[targetCurrency] else {
                throw ExchangeError.noRateError
        }
        
        return rateFromBaseToTarget / rateFromBaseToOrigin
    }
    
    public func convert(monetaryAmount: MonetaryAmount, to targetCurrency: Currency) throws -> MonetaryAmount {
       
        let targetRate = try rate(from: monetaryAmount.currency, targetCurrency: targetCurrency)
        return MonetaryAmount(currency: targetCurrency, value: monetaryAmount.value * targetRate.toDynanamic())
    }
}

extension Exchange: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case base
        case rates
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let baseCurrencyIdentifier = try container.decode(String.self, forKey: .base)
        let rawRates = try container.decode([String: Decimal].self, forKey: .rates)

        guard let baseCurrency = Currency.with(currencyCode: baseCurrencyIdentifier) else {
            throw ExchangeError.decodeError
        }
        
        self.base = baseCurrency
        self.rates = Dictionary(uniqueKeysWithValues: rawRates.compactMap { currencyIdentifier, rate in
            Currency.with(currencyCode: currencyIdentifier).flatMap { currency in
                (currency: currency, rate: Rate(value: rate))
            }
        })
    }
}
