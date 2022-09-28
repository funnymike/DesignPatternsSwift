// MARK: - 责任链模式

import Foundation

// MARK: - Models

///  钱币的基类 1
public class Coin {
    // 2 直径
    public class var standardDiameter: Double {
        return 0
    }
    public class var standardWeight: Double {
        return 0
    }
    // 3
    public var centValue: Int {
        return 0
    }
    public final var dollarValue: Double {
        return Double(centValue) / 100
    }
    // 4
    public final let diameter: Double, weight: Double
    // 5
    public required init(diameter: Double, weight: Double) {
        self.diameter = diameter
        self.weight = weight
    }
    // 6
    public convenience init() {
        let diameter = type(of: self).standardDiameter
        let weight = type(of: self).standardWeight
        self.init(diameter: diameter, weight: weight)
    }
}

extension Coin: CustomStringConvertible {
    public var description: String {
        return String(format:"%@ {diameter: %0.3f, dollarValue: $%0.2f, weight: %0.3f}", "\(type(of: self))", diameter, dollarValue, weight)
    }
}

/// 便士
public class Penny: Coin {
    public override class var standardDiameter: Double {
        return 19.05
    }
    
    public override class var standardWeight: Double {
        return 2.5
    }
    
    public override var centValue: Int {
        return 1
    }
}

public class Nickel: Coin {
    public override class var standardDiameter: Double {
        return 21.21
    }
    public override class var standardWeight: Double {
        return 5.0
    }
    public override  var centValue: Int {
        return 5
    }
}

public class Dime: Coin {
    public override class var standardDiameter: Double {
        return 17.91
    }
    public override class var standardWeight: Double {
        return 2.268
    }
    public override  var centValue: Int {
        return 10
    }
}

public class Quarter: Coin {
    public override class var standardDiameter: Double {
        return 24.26
    }
    public override class var standardWeight: Double {
        return 5.670
    }
    public override  var centValue: Int {
        return 25
    }
}



/**
 让我们一步一步来看看：
 1. 首先为 Coin 创建一个新类，将其用作所有硬币类型的超类。
 2. 然后将standardDiameter 和standardWeight 声明为类属性。您将在每个特定的硬币子类中覆盖这些，稍后您将在创建硬币验证器时使用它们。
 3. 将 centValue 和 DollarValue 声明为计算属性。您将覆盖 centValue 以返回每个特定硬币的正确值。由于 1 美元总是有 100 美分，因此您将 DollarValue 设为最终属性。
 4. 您创建直径和重量作为存储属性。随着硬币年龄的增长，它们会被弄脏和磨损。因此，它们的直径和重量往往会随着时间的推移而略微减小。稍后您将在创建硬币验证器时将硬币的直径和重量与标准进行比较。
 5. 你创建一个指定的初始化器来接受特定硬币的直径和重量。重要的是，这是一个必需的初始化程序：您将使用它来创建子类，方法是在 Coin.Type 实例上调用它 - 即 Coin 的类型。
 6. 最后创建一个便利初始化器。这将使用 type(of: self) 创建一个标准硬币，以获得 standardDiameter 和 standardWeight。这样，您就不必为每个特定的硬币子类重写此初始化程序。
 */

// MARK: - HandlerProtocol
public protocol CoinHandlerProtocol {
    var next: CoinHandlerProtocol? {
        get
    }
    
    func handleCoinValidation(_ unknownCoin: Coin) -> Coin?
}

// MARK: - Concrete Handler
// 1
public class CoinHandler {
    // 2
    public var next: CoinHandlerProtocol?
    public var coinType: Coin.Type
    public let diameterRange: ClosedRange<Double>
    public let weightRange: ClosedRange<Double>
    
    init(coinType: Coin.Type,
         diameterVariation: Double = 0.05,
         weightVariation: Double = 0.05) {
        self.coinType = coinType
        let standardDiameter = coinType.standardDiameter
        self.diameterRange = (1 - diameterVariation) * standardDiameter ... (1 + diameterVariation) * standardDiameter
        
        let standardWeight = coinType.standardWeight
        self.weightRange = (1 - weightVariation) * standardWeight ... (1 + weightVariation) * standardWeight
    }
}

extension CoinHandler {
    // 1
    func handleCoinValidation(_ unknownCoin: Coin) -> Coin? {
        guard let coin = createCoin(from: unknownCoin) else {
            return next?.handleCoinValidation(unknownCoin)
        }
        return coin
    }
    
    // 2
    private func createCoin(from unknownCoin: Coin) -> Coin? {
        print("Attempt to create \(coinType)")
        guard diameterRange.contains(unknownCoin.diameter) else {
            print("Invalid diameter")
            return nil
        }
        guard weightRange.contains(unknownCoin.weight) else {
            print("Invalid weight")
            return nil
        }
        let coin = coinType.init(diameter: unknownCoin.diameter, weight: unknownCoin.weight)
        print("Created \(coin)")
        return coin
    }
}
/**
 
 */

// MARK: - Client
// 1
public class VendingMachine {
    // 2
    public let coinHandler: CoinHandler
    public var coins: [Coin] = []
    // 3
    public init(coinHandler: CoinHandler) {
        self.coinHandler = coinHandler
    }
    // 4
    public func insertCoin(_ unknownCoin: Coin) {
        // 4.1
        guard let coin = coinHandler.handleCoinValidation(unknownCoin) else {
            print("Coin rejected: \(unknownCoin)")
            return
        }
        // 2
        print("Coin Accepted: \(coin)")
        coins.append(coin)
        // 3
        let dollarValue = coins.reduce(0, { $0 + $1.dollarValue })
        print("")
        print("Coins Total Value: $\(dollarValue)")
        // 4
        let weight = coins.reduce(0, { $0 + $1.weight })
        print("Coins Total Weight: \(weight) g")
        print("")
    }
}

/**
 1. 您为 VendingMachine 创建了一个新类，它将充当客户端。
 2. 这只有两个属性：coinHandler 和coins。VendingMachine 不需要知道它的 coinHandler 实际上是一个处理程序链，而是简单地将其视为单个对象。您将使用硬币来持有所有有效的、可接受的硬币。
 3. 初始化器也很简单：你只需接受一个传入的 coinHandler 实例。 VendingMachine 不需要了解 CoinHandler 的设置方式，因为它只是使用它。
 4. 一种实际接受硬币的方法。
 4.1. 您首先尝试通过将 unknownCoin 传递给 coinHandler 来创建 Coin。 如果没有创建有效的硬币，您会打印出一条消息，指示硬币被拒绝。
 4.2. 如果创建了一个有效的硬币，您打印一条成功消息并将其附加到硬币上。
 4.3. 然后你得到所有硬币的 DollarValue 并打印出来。
 4.4. 你最后得到所有硬币的重量并打印出来。
 */

// MARK: - Example
// 1
let pennyHandler = CoinHandler(coinType: Penny.self)
let nickleHandler = CoinHandler(coinType: Nickel.self)
let dimeHandler = CoinHandler(coinType: Dime.self)
let quarterHandler = CoinHandler(coinType: Quarter.self)
// 2
pennyHandler.next = nickleHandler as? CoinHandlerProtocol
nickleHandler.next = dimeHandler as? CoinHandlerProtocol
dimeHandler.next = quarterHandler as? CoinHandlerProtocol
// 3
let vendingMachine = VendingMachine(coinHandler: pennyHandler)

let penny = Penny()
vendingMachine.insertCoin(penny)
//Attempt to create Penny
//Created Penny {diameter: 19.050, dollarValue: $0.01, weight: 2.500}
//Coin Accepted: Penny {diameter: 19.050, dollarValue: $0.01, weight: 2.500}
//
//Coins Total Value: $0.01
//Coins Total Weight: 2.5 g

let quarter = Coin(diameter: Quarter.standardWeight, weight: Quarter.standardWeight)
vendingMachine.insertCoin(penny)

