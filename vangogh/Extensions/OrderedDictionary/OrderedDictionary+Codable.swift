///
/// OrderedDictionary
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension OrderedDictionary: Encodable where Key: Encodable, Value: Encodable {

    public func encode(to encoder: Encoder) throws {

        var container = encoder.unkeyedContainer()

        for (key, value) in self {
            try container.encode(key)
            try container.encode(value)
        }
    }
}

extension OrderedDictionary: Decodable where Key: Decodable, Value: Decodable {

    public init(from decoder: Decoder) throws {

        self.init()

        var container = try decoder.unkeyedContainer()

        while !container.isAtEnd {
            let key = try container.decode(Key.self)
            guard !container.isAtEnd else {
                throw DecodingError.unkeyedContainerReachedEndBeforeValue(decoder.codingPath)
            }
            let value = try container.decode(Value.self)

            self[key] = value
        }
    }
}

extension DecodingError {

    fileprivate static func unkeyedContainerReachedEndBeforeValue(_ codingPath: [CodingKey]) -> DecodingError {

        return DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Unkeyed container reached end before value in key-value pair.")
        )
    }
}
