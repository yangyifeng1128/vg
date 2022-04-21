///
/// MetaGameEngine
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

class MetaGameEngine {

    private var rules: [MetaRule] = []

    init(rules: [MetaRule]) {

        self.rules = rules
    }

    func run(facts: [MetaFact]) {

        for rule in rules {

            rule.run(facts: facts)
        }
    }
}
