# MonetaryExchange

[![Build Status](https://app.bitrise.io/app/57e424b934229804/status.svg?token=zDHT8jgVf-wPoK5oVp7LcA&branch=master)](https://app.bitrise.io/app/57e424b934229804)
[![Docs](https://softwareengineerchris.github.io/MonetaryExchange/badge.svg)](https://softwareengineerchris.github.io/MonetaryExchange)
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
An `Exchange` can be decoded directly from a the [Fixer.io](https://fixer.io/) Latest Rates JSON response.
See [Fixer API Documentation](https://fixer.io/documentation#latestrates) for more information about its API usage.

### Example using the Fixer Extension

```swift
Exchange.Fixer.exchange(accessKey: "YourFixerAccessKey") { result in
    switch result {
        case let .success(exchange):
            // We have an Exchange value

        case let .failure(error):
            // Something went wrong. Dig into the error.
     }
}
```
See the documentation for `Exchange.Fixer` for more information.

### Example using JSONDecoder Directly

```swift
let exchange = try? JSONDecoder().decode(Exchange.self, from: fixerResponseData)
```

Alternatively, an `Exchange` can be constructed with a base currency and a dictionary of currency-rate pairs.

## Cross-rates

If converting between two currencies which neither are the base currency, but each have a rate against the base currency,
then a cross-rate will be produced.

For example, if the base currency is _EUR_ but a rate for _GBP to USD_ is requested, a cross-rate will be used. i.e. _GBP to EUR to USD_.

See the Collins Dictionary definition of [Cross-Rate](https://www.collinsdictionary.com/dictionary/english/cross-rate)
for more information.
