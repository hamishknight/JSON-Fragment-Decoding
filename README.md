# JSONFragmentDecoding

A `JSONDecoder` extension to allow decoding JSON fragments.

## Usage

Simply pass `allowFragments: true` to a `JSONDecoder.decode(_:from:)` call, and you’ll be able to decode JSON fragments:

```swift
import Foundation
import JSONFragmentDecoding

let data = Data("10".utf8)

let decoded = try JSONDecoder().decode(Int.self, from: data, allowFragments: true)
print(decoded) // 10
```

## Installation

Honestly it’s so lightweight that you could just drop `/Sources/JSONFragmentDecoding/JSONFragmentDecoding.swift` into your project and be on your way.

### Swift PM

Add the following dependancy to your `Package.swift` file:

```swift
dependencies: [
  .package(url: "https://github.com/hamishknight/JSONFragmentDecoding.git", from: "0.1.0")
],
```

and then add the dependancy to any targets that need to use it:

```swift
targets: [
  .target(
    name: "SomeTarget",
    dependencies: ["JSONFragmentDecoding"]),
]
```

### Carthage

Add the following to your `Cartfile`:

```swift
github "hamishknight/JSONFragmentDecoding" ~> 0.1
```
