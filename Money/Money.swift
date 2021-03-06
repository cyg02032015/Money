//
//  Money.swift
//  Money
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Daniel Thorpe
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation
import ValueCoding

/**
 # MoneyType
 `MoneyType` is a protocol which refines `DecimalNumberType`. It
 adds a generic type for the currency.
*/
public protocol MoneyType: DecimalNumberType, ValueCoding {
    typealias Currency: CurrencyType

    /// Access the underlying decimal
    var decimal: _Decimal<Currency> { get }

    init(_: _Decimal<Currency>)
}

/**
 # Money
 `_Money` is a value type, conforming to `MoneyType`, which is generic over the currency type.
 
 To work in whatever the local currency is, use `Money`. It should not
 be necessary to use `_Money` directly, instead, use a currency
 typealias, such as `USD` or `GBP`.
*/
public struct _Money<C: CurrencyType>: MoneyType {
    
    public typealias DecimalNumberBehavior = C
    public typealias Currency = C

    /// Access the underlying decimal.
    /// - returns: the `_Decimal<C>`
    public let decimal: _Decimal<C>

    /// Access the underlying decimal storage.
    /// - returns: the `_Decimal<C>.DecimalStorageType`
    public var storage: _Decimal<C>.DecimalStorageType {
        return decimal.storage
    }

    /// Flag to indicate if the decimal number is less than zero
    public var isNegative: Bool {
        return decimal.isNegative
    }

    /// The negative of Self.
    /// - returns: a `_Money<C>`
    public var negative: _Money {
        return _Money(decimal.negative)
    }

    /**
     Initialize a new value using an underlying decimal.

     - parameter value: a `_Decimal<C>` defaults to zero.
     */
    public init(_ value: _Decimal<C> = _Decimal<C>()) {
        decimal = value
    }

    /**
     Initialize a new value using the underlying decimal storage.
     At the moment, this is a `NSDecimalNumber`.

     - parameter storage: a `_Decimal<C>.DecimalStorageType`
     */
    public init(storage: _Decimal<C>.DecimalStorageType) {
        decimal = _Decimal<DecimalNumberBehavior>(storage: storage)
    }

    /**
     Initialize a new value using a `FloatLiteralType`

     - parameter floatLiteral: a `FloatLiteralType` for the system, probably `Double`.
     */
    public init(integerLiteral value: IntegerLiteralType) {
        decimal = _Decimal<DecimalNumberBehavior>(integerLiteral: value)
    }

    /**
     Initialize a new value using a `IntegerLiteralType`

     - parameter integerLiteral: a `IntegerLiteralType` for the system, probably `Int`.
     */
    public init(floatLiteral value: FloatLiteralType) {
        decimal = _Decimal<DecimalNumberBehavior>(floatLiteral: value)
    }

    /**
     Subtract a matching `_Money<C>` from the receiver.

     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func subtract(other: _Money) -> _Money {
        return _Money(decimal.subtract(other.decimal))
    }

    /**
     Add a matching `_Money<C>` from the receiver.

     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func add(other: _Money) -> _Money {
        return _Money(decimal.add(other.decimal))
    }

    /**
     Multiply a matching `_Money<C>` from the receiver.

     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */

    @warn_unused_result
    public func multiplyBy(other: _Money) -> _Money {
        return _Money(decimal.multiplyBy(other.decimal))
    }

    /**
     Divide a matching `_Money<C>` from the receiver.

     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func divideBy(other: _Money) -> _Money {
        return _Money(decimal.divideBy(other.decimal))
    }

    /**
     The remainder of dividing another `_Money<C>` into the receiver.

     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func remainder(other: _Money) -> _Money {
        return _Money(decimal.remainder(other.decimal))
    }
}

// MARK: - Equality

public func ==<C: CurrencyType>(lhs: _Money<C>, rhs: _Money<C>) -> Bool {
    return lhs.decimal == rhs.decimal
}

// MARK: - Comparable

public func <<C: CurrencyType>(lhs: _Money<C>, rhs: _Money<C>) -> Bool {
    return lhs.decimal < rhs.decimal
}

// MARK: - Consumption Types

/// The current locale money
public typealias Money = _Money<Currency.Local>

// MARK: - CustomStringConvertible

extension _Money: CustomStringConvertible {

    /**
     Returns the result of the `formatted` function using
     NSNumberFormatterStyle.CurrencyStyle.
    */
    public var description: String {
        return formatted(.CurrencyStyle)
    }

    /**
     ### Localized Formatted String
     This function will format the Money type into a string suitable
     for the current localization. It accepts an parameter for the 
     style `NSNumberFormatterStyle`. Note that iOS 9 and OS X 10.11
     added new styles which are relevant for currency.
     
     These are `.CurrencyISOCodeStyle`, `.CurrencyPluralStyle`, and 
     `.CurrencyAccountingStyle`.
    */
    public func formatted(style: NSNumberFormatterStyle) -> String {
        return C.formatter.formattedStringWithStyle(style)(decimal)
    }
}


// MARK: - MoneyType Extension

public extension MoneyType where DecimalStorageType == BankersDecimal.DecimalStorageType {

    /**
     Use a `BankersDecimal` to convert the receive into another `MoneyType`. To use this
     API the underlying `DecimalStorageType`s between the receiver, the other `MoneyType` 
     must both be the same a that of `BankersDecimal` (which luckily they are).
    */
    @warn_unused_result
    func convertWithRate<Other: MoneyType where Other.DecimalStorageType == BankersDecimal.DecimalStorageType>(rate: BankersDecimal) -> Other {
        return multiplyBy(Other(storage: rate.storage))
    }
}

// MARK: - Value Coding

extension _Money: ValueCoding {
    public typealias Coder = _MoneyCoder<C>
}

/**
 Coding class to support `_Decimal` `ValueCoding` conformance.
 */
public final class _MoneyCoder<C: CurrencyType>: NSObject, NSCoding, CodingType {

    public let value: _Money<C>

    public required init(_ v: _Money<C>) {
        value = v
    }

    public init?(coder aDecoder: NSCoder) {
        let decimal = _Decimal<C>.decode(aDecoder.decodeObjectForKey("decimal"))
        value = _Money<C>(decimal!)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.decimal.encoded, forKey: "decimal")
    }
}