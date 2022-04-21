///
/// OrderedDictionary
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension OrderedDictionary: CustomStringConvertible {

    /// A textual representation of the ordered dictionary
    public var description: String {

        return makeDescription(debug: false)
    }
}

extension OrderedDictionary: CustomDebugStringConvertible {

    /// A textual representation of the ordered dictionary, suitable for debugging
    public var debugDescription: String {

        return makeDescription(debug: true)
    }
}

extension OrderedDictionary {

    fileprivate func makeDescription(debug: Bool) -> String {

        if isEmpty { return "[:]" }

        let printFunction: (Any, inout String) -> () = {
            if debug {
                return { debugPrint($0, separator: "", terminator: "", to: &$1) }
            } else {
                return { print($0, separator: "", terminator: "", to: &$1) }
            }
        }()

        let descriptionForItem: (Any) -> String = { item in
            var description = ""
            printFunction(item, &description)
            return description
        }

        let bodyComponents = map { element in
            return descriptionForItem(element.key) + ": " + descriptionForItem(element.value)
        }

        let body = bodyComponents.joined(separator: ", ")

        return "[\(body)]"
    }
}
