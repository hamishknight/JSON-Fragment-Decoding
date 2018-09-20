
import Foundation

fileprivate extension CodingUserInfoKey {
  static let fragmentBoxedType = CodingUserInfoKey(
    rawValue: "CodingUserInfoKey.fragmentBoxedType"
  )!
}

extension JSONDecoder {
  private struct FragmentDecodingBox<T : Decodable> : Decodable {
    var value: T
    init(from decoder: Decoder) throws {
      let type = decoder.userInfo[.fragmentBoxedType] as! T.Type
      var container = try decoder.unkeyedContainer()
      self.value = try container.decode(type)
    }
  }

  private func copy() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = dataDecodingStrategy
    decoder.dateDecodingStrategy = dateDecodingStrategy
    decoder.keyDecodingStrategy = keyDecodingStrategy
    decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
    decoder.userInfo = userInfo
    return decoder
  }

  public func decode<T : Decodable>(
    _ type: T.Type, from data: Data, allowFragments: Bool
  ) throws -> T {
    // If we're not allowing fragments, just delegate to decode(_:from:).
    guard allowFragments else { return try decode(type, from: data) }

    // Box the JSON object in an array so we can pass it off to JSONDecoder.
    // The round-tripping through JSONSerialization isn't ideal, but it
    // ensures we do The Right Thing regardless of the encoding of `data`.
    //
    // FIX-ME: Try to detect encoding and add the '[]' delimeters directly to
    // the data without going through `JSONSerialization`.
    let jsonObject = try JSONSerialization
      .jsonObject(with: data, options: .allowFragments)
    let boxedData = try JSONSerialization.data(withJSONObject: [jsonObject])

    // Copy the decoder so we can mutate the userInfo without having to worry
    // about data races.
    let decoder = copy()
    decoder.userInfo[.fragmentBoxedType] = type

    // Use FragmentDecodingBox to decode the underlying fragment from the
    // array.
    //
    // We're intentionally *not* doing `decode([T].self, ...)` here, as
    // that loses the dynamic type passed – breaking things like:
    //
    // class C : Decodable {}
    // class D {}
    //
    // let type: C.Type = D.self
    // let data = ...
    // let decoded = try JSONDecoder().decode(type, from: data, allowFragments: true)
    //
    // The above would decode a `C` instead of a `D` if we didn't preserve
    // the dynamic type.
    //
    // (Admittedly this is a bit of contrived example, as by default such types
    //  would decode using keyed containers and therefore not be fragments –
    //  nontheless it is possible for them to implement their decoding such that
    //  they use a single value container).
    return try decoder.decode(FragmentDecodingBox<T>.self, from: boxedData).value
  }
}
