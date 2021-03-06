import PureSwiftJSONParsing

struct JSONSingleValueDecodingContainter: SingleValueDecodingContainer {
  
  let impl      : JSONDecoderImpl
  let value     : JSONValue
  let codingPath: [CodingKey]
  
  init(impl: JSONDecoderImpl, codingPath: [CodingKey], json: JSONValue) {
    self.impl       = impl
    self.codingPath = codingPath
    self.value      = json
  }
  
  func decodeNil() -> Bool {
    return value == .null
  }
  
  func decode(_ type: Bool.Type) throws -> Bool {
    guard case .bool(let bool) = value else {
      throw createTypeMismatchError(type: Bool.self, value: value)
    }
    
    return bool
  }
  
  func decode(_ type: String.Type) throws -> String {
    guard case .string(let string) = value else {
      throw createTypeMismatchError(type: String.self, value: value)
    }
    
    return string
  }
  
  func decode(_ type: Double.Type) throws -> Double {
    return try self.decodeLosslessStringConvertible()
  }
  
  func decode(_ type: Float.Type) throws -> Float {
    return try self.decodeLosslessStringConvertible()
  }
  
  func decode(_ type: Int.Type) throws -> Int {
    return try self.decodeFixedWithInteger()
  }
  
  func decode(_ type: Int8.Type) throws -> Int8 {
    return try self.decodeFixedWithInteger()
  }
  
  func decode(_ type: Int16.Type) throws -> Int16 {
    return try self.decodeFixedWithInteger()
  }
  
  func decode(_ type: Int32.Type) throws -> Int32 {
    return try self.decodeFixedWithInteger()
  }
  
  func decode(_ type: Int64.Type) throws -> Int64 {
    return try self.decodeFixedWithInteger()
  }
  
  func decode(_ type: UInt.Type) throws -> UInt {
    return try self.decodeFixedWithInteger()
  }
  
  func decode(_ type: UInt8.Type) throws -> UInt8 {
    return try self.decodeFixedWithInteger()
  }
  
  func decode(_ type: UInt16.Type) throws -> UInt16 {
    return try self.decodeFixedWithInteger()
  }
  
  func decode(_ type: UInt32.Type) throws -> UInt32 {
    return try self.decodeFixedWithInteger()
  }
  
  func decode(_ type: UInt64.Type) throws -> UInt64 {
    return try self.decodeFixedWithInteger()
  }
  
  func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
    return try T.init(from: impl)
  }
}

extension JSONSingleValueDecodingContainter {
  
  @inline(__always) private func createTypeMismatchError(type: Any.Type, value: JSONValue) -> DecodingError {
    return DecodingError.typeMismatch(type, .init(
      codingPath: codingPath,
      debugDescription: "Expected to decode \(type) but found \(value.debugDataTypeDescription) instead."))
  }
  
  @inline(__always) private func decodeFixedWithInteger<T: FixedWidthInteger>() throws
    -> T
  {
    guard case .number(let number) = value else {
      throw createTypeMismatchError(type: T.self, value: value)
    }
    
    guard let integer = T(number) else {
      throw DecodingError.dataCorruptedError(
        in: self,
        debugDescription: "Parsed JSON number <\(number)> does not fit in \(T.self).")
    }
    
    return integer
  }
  
  @inline(__always) private func decodeLosslessStringConvertible<T: LosslessStringConvertible>()
    throws -> T
  {
    guard case .number(let number) = value else {
      throw createTypeMismatchError(type: T.self, value: value)
    }
    
    guard let floatingPoint = T(number) else {
      throw DecodingError.dataCorruptedError(
        in: self,
        debugDescription: "Parsed JSON number <\(number)> does not fit in \(T.self).")
    }
    
    return floatingPoint
  }
}
