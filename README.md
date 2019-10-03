# MonetaryExchange

[![Build Status](https://app.bitrise.io/app/57e424b934229804/status.svg?token=zDHT8jgVf-wPoK5oVp7LcA&branch=master)](https://app.bitrise.io/app/57e424b934229804) 
[![SPM](https://img.shields.io/badge/SPM-Supported-informational)](#)
[![Swift Version](https://img.shields.io/badge/Swift%20Version-5.1-informational)](#)

`Exchange` provides exchange rates between currencies. It can also convert `MonetaryAmount` values into
those of different `Currency` values.

## Installation

### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/SoftwareEngineerChris/MonetaryExchange.git", from: "1.0.0")
]
```

## Decoding a Fixer.io JSON response
An `Exchange` can be decoded directly from a standard [Fixer.io](https://fixer.io/) _Latest Rates_ JSON response.
See [Fixer API Documentation](https://fixer.io/documentation#latestrates) for more information about its API usage.

### Example

    let exchange = try? JSONDecoder().decode(Exchange.self, from: fixerResponseData)

Alternatively, an `Exchange` can be constructed with a base currency and a dictionary of currency-rate pairs.

## Cross-rates

If converting between two currencies which neither are the base currency, but each have a rate against the base currency,
then a cross-rate will be produced.

For example, if the base currency is _EUR_ but a rate for _GBP to USD_ is requested, a cross-rate will be used. i.e. _GBP to EUR to USD_.

See the Collins Dictionary definition of [Cross-Rate](https://www.collinsdictionary.com/dictionary/english/cross-rate)
for more information.
