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

/// `Exchange` provides exchange rates between currencies. It can also convert `MonetaryAmount` values into
/// those of different `Currency` values.
///
/// ## Decoding a Fixer.io JSON response
/// An `Exchange` can be decoded directly from a standard [Fixer.io](https://fixer.io/) _Latest Rates_ JSON response.
/// See [Fixer API Documentation](https://fixer.io/documentation#latestrates) for more information about its API usage.
///
/// ### Example
///
///     let exchange = try? JSONDecoder().decode(Exchange.self, from: fixerResponseData)
///
/// Alternatively, an `Exchange` can be constructed with a base currency and a dictionary of currency-rate pairs.
///
/// ## Cross-rates
///
/// If converting between two currencies which neither are the base currency, but each have a rate against the base currency,
/// then a cross-rate will be produced.
///
/// For example, if the base currency is _EUR_ but a rate for _GBP to USD_ is requested, a cross-rate will be used. i.e. _GBP to EUR to USD_.
///
/// See the Collins Dictionary definition of [Cross-Rate](https://www.collinsdictionary.com/dictionary/english/cross-rate)
/// for more information.
public struct Exchange: Decodable {
    
    // MARK: Types
    
    /// Represents a monetary exchange rate between two currencies. Rounded to six decimal places.
    public typealias Rate = RoundedDecimal<Places.six>
    
    /// The possible errors thrown by an `Exchange`
    public enum ExchangeError: Error {
        /// Thrown when unable to decode an `Exchange` representation
        case decodeError
        /// Thrown when there is no exchage rate for a particular `Currency`
        case noRateError
    }
    
    // MARK: Values
    
    /// The base currency for this `Exchange`. The currency to which all rates from this exchange are based upon.
    ///
    
    public let base: Currency
    
    /// A dictionary of `Currency` values to `Rate` values where the `Rate` is the exchange rate between the base `Currency` and the queried `Currency`.
    public let rates: [Currency: Rate]
    
    // MARK: Construction
    
    /// Creates a new `Exchange` from a base `Currency` and a collection of exchange rates.
    ///
    /// - Parameters:
    ///
    ///   - base: The base currency for this `Exchange`. The currency to which all rates from this exchange are based upon.
    ///   - rates: A dictionary of `Currency` values to `Rate` values where the `Rate` is the exchange rate between the base `Currency` and the queried `Currency`.
    public init(base: Currency, rates: [Currency: Rate]) {
        self.base = base
        self.rates = rates
    }
    
    // MARK: Exchanging rates and MonetaryAmounts
    
    /// - Parameters:
    ///     - originCurrency: The "base" `Currency` in the pair.
    ///     - targetCurrency: The "quote" `Currency` in the pair.
    /// - Throws: If the exchange has no exchange rate for the `targetCurrency`, this method will throw `ExchangeError.noRateError`
    /// - Returns: The exchange rate for the provided currency pair.
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
    
    /// - Parameters:
    ///     - monetaryAmount: A `MonetaryAmount` which has a `Currency` to be converted to the `targetCurrency`
    ///     - targetCurrency: The "quote" `Currency` in the pair (the base being that in the `monetaryAmount` parameter).
    /// - Throws: If the exchange has no exchange rate for the `targetCurrency`, this method will throw `ExchangeError.noRateError`
    /// - Returns: A `MonetaryAmount` representing the original amount converted to the target currency using the `Exchange` exchange rate.
    public func convert(monetaryAmount: MonetaryAmount, to targetCurrency: Currency) throws -> MonetaryAmount {
       
        let targetRate = try rate(from: monetaryAmount.currency, targetCurrency: targetCurrency)
        return MonetaryAmount(currency: targetCurrency, value: monetaryAmount.value * targetRate.toDynanamic())
    }
}

extension Exchange {
    
    // MARK: Decodable
    
    enum CodingKeys: String, CodingKey {
        case base
        case rates
    }
    
    /// An `Exchange` can be decoded directly from a standard standard [Fixer.io](https://fixer.io/) _Latest Rates_ JSON response.
    /// See [Fixer API Documentation](https://fixer.io/documentation#latestrates) for more information about its API usage.
    ///
    /// #### Example
    ///
    ///     let exchange = try? JSONDecoder().decode(Exchange.self, from: fixerResponseData)
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
