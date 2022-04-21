///
/// OrderedDictionary
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension OrderedDictionary {

    @available(*, deprecated, message: "Please use init(values:uniquelyKeyedBy:).", renamed: "init(values:uniquelyKeyedBy:)")
    public init<S: Sequence>(values: S, keyedBy extractKey: (Value) -> Key) where S.Element == Value {

        self.init(values: values, uniquelyKeyedBy: extractKey)
    }

    @available(*, deprecated, message: "Please use init(values:uniquelyKeyedBy:).", renamed: "init(values:uniquelyKeyedBy:)")
    public init(values: [Value], keyedBy keyPath: KeyPath<Value, Key>) {

        self.init(values: values, uniquelyKeyedBy: keyPath)
    }

    @available(*, deprecated, message: "Please use init(uniqueKeysWithValues:).", renamed: "init(uniqueKeysWithValues:)")
    public init<S: Sequence>(_ elements: S) where S.Element == Element {

        self.init(uniqueKeysWithValues: elements)
    }

    @available(*, deprecated, message: "Use canInsert(key:) with the element's key instead.")
    public func canInsert(_ newElement: Element) -> Bool {

        return canInsert(key: newElement.key)
    }

    @available(*, deprecated, message: "Since the concrete behavior of the element movement highly depends on concrete use cases, its official support will be dropped in the future. Please use the public API for modeling a move operation instead.")
    @discardableResult
    public mutating func moveElement(forKey key: Key, to newIndex: Index) -> Index? {

        // Load the previous index and return nil if the index is not found
        guard let previousIndex = index(forKey: key) else { return nil }

        // If the previous and new indices match, treat it as if the movement was already performed
        guard previousIndex != newIndex else { return previousIndex }

        // Remove the value for the key at its original index
        let value = removeValue(forKey: key)!

        // Validate the new index
        precondition(canInsert(at: newIndex), "Cannot move to invalid index in OrderedDictionary")

        // Insert the element at the new index
        insert((key: key, value: value), at: newIndex)

        return previousIndex
    }
}
