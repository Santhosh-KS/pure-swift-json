import XCTest
@testable import PureSwiftJSONParsing
@testable import PureSwiftJSONCoding

class JSONUnkeyedDecodingContainerTests: XCTestCase {
  
  // MARK: - Null -
  
  func testDecodeNull() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.null]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decodeNil()
      XCTAssertEqual(result, true)
      XCTAssertEqual(container.currentIndex, 1)
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testDecodeNullFromArray() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.object([:])]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decodeNil()
      XCTAssertEqual(result, false)
      XCTAssertEqual(container.currentIndex, 0)
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  // MARK: - String -
  
  func testDecodeString() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.string("hello world")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(String.self)
      XCTAssertEqual(result, "hello world")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testDecodeStringFromNumber() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("123")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(String.self)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.typeMismatch(let type, let context) {
      // expected
      XCTAssertTrue(type == String.self)
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? ArrayKey, ArrayKey(index: 0))
      XCTAssertEqual(context.debugDescription, "Expected to decode String but found a number instead.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  // MARK: - Bool -
  
  func testDecodeBool() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.bool(false)]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(Bool.self)
      XCTAssertEqual(result, false)
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testDecodeBoolFromNumber() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.string("hallo")]), codingPath: [])

    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(Bool.self)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.typeMismatch(let type, let context) {
      // expected
      XCTAssertTrue(type == Bool.self)
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? ArrayKey, ArrayKey(index: 0))
      XCTAssertEqual(context.debugDescription, "Expected to decode Bool but found a string instead.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  // MARK: - Integer -
  
  func testGetUInt8FromTooLargeNumber() {
    let number = 312
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(UInt8.self)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.dataCorrupted(let context) {
      // expected
      XCTAssertEqual(context.codingPath.count, 1)
      guard let codingKey = context.codingPath.first else {
        XCTFail("Expected to get one coding key")
        return
      }
      XCTAssertEqual(codingKey.intValue, 0)
      XCTAssertEqual(context.debugDescription, "Parsed JSON number <\(number)> does not fit in UInt8.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt8FromFloat() {
    let number = -3.14
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(UInt8.self)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.dataCorrupted(let context) {
      // expected
      XCTAssertEqual(context.codingPath.count, 1)
      guard let codingKey = context.codingPath.first else {
        XCTFail("Expected to get one coding key")
        return
      }
      XCTAssertEqual(codingKey.intValue, 0)
      XCTAssertEqual(context.debugDescription, "Parsed JSON number <\(number)> does not fit in UInt8.")
      print(context)
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt8TypeMismatch() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.bool(false)]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(UInt8.self)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.typeMismatch(let type, let context) {
      // expected
      XCTAssertTrue(type == UInt8.self)
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? ArrayKey, ArrayKey(index: 0))
      XCTAssertEqual(context.debugDescription, "Expected to decode UInt8 but found bool instead.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testGetUInt8Success() {
    let number = 25
    let type = UInt8.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt16Success() {
    let number = 25
    let type = UInt16.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt32Success() {
    let number = 25
    let type = UInt32.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt64Success() {
    let number = 25
    let type = UInt64.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUIntSuccess() {
    let number = 25
    let type = UInt.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetInt8Success() {
    let number = -25
    let type = Int8.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetInt16Success() {
    let number = -25
    let type = Int16.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetInt32Success() {
    let number = -25
    let type = Int32.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetInt64Success() {
    let number = -25
    let type = Int64.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetIntSuccess() {
    let number = -25
    let type = Int.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
    
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  // MARK: - Floats -
  
  func testGetFloatSuccess() {
    let number = -3.14
    let type = Float.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
      
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetDoubleSuccess() {
    let number = -3.14e12
    let type = Double.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
      
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetFloatTooPreciseButNoProblemo() {
    let number = 3.14159265358979323846264338327950288419716939937510582097494459230781640
    let type = Float.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("\(number)")]), codingPath: [])
      
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetFloat1000e1000() {
    let type = Float.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.number("1000e1000")]), codingPath: [])
      
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.dataCorrupted(let context) {
      // expected
      XCTAssertEqual(context.codingPath.count, 1)
      guard let codingKey = context.codingPath.first else {
        XCTFail("Expected to get one coding key")
        return
      }
      XCTAssertEqual(codingKey.intValue, 0)
      XCTAssertEqual(context.debugDescription, "Parsed JSON number <1000e1000> does not fit in Float.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetFloatTypeMismatch() {
    let type = Float.self
    let impl = JSONDecoderImpl(userInfo: [:], from: .array([.object([:])]), codingPath: [])
      
    do {
      var container = try impl.unkeyedContainer()
      let result = try container.decode(type.self)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.typeMismatch(let type, let context) {
      // expected
      XCTAssertTrue(type == Float.self)
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? ArrayKey, ArrayKey(index: 0))
      XCTAssertEqual(context.debugDescription, "Expected to decode Float but found a dictionary instead.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }


}

