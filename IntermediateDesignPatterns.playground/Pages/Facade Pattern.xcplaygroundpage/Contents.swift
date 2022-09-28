// 外观模式

import Foundation

// MARK: - 依赖项
public struct Customer {
    public let identifier: String
    public let address: String
    public let name: String
}

extension Customer: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func ==(lhs: Customer, rhs: Customer) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

public struct Product {
    public let identifier: String
    public let name: String
    public var cost: Double
}

extension Product: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

public class InventoryDatabase {
    public var inventory: [Product: Int] = [:]
    
    public init(inventory: [Product: Int]) {
        self.inventory = inventory
    }
}

public class ShippingDatabase {
    public var pendingShipments: [Customer: [Product]] = [:]
}

// MARK: - 外观
public class OrderFacade {
    public let inventoryDatabase: InventoryDatabase
    public let shippingDatabase: ShippingDatabase
    
    public init(inventoryDatabase: InventoryDatabase, shippingDatabase: ShippingDatabase) {
        self.inventoryDatabase = inventoryDatabase
        self.shippingDatabase = shippingDatabase
    }
    
    func placeOrder(for product: Product, by customer: Customer) {
        // 1 您首先将 product.name 和 customer.name 打印到控制台。
        print("Place order for '\(product.name)' by '\(customer.name)'")
        // 2
        let count = inventoryDatabase.inventory[product, default: 0]
        guard count > 0 else {
            print("'\(product.name)' is out of stock!")
            return
        }
        // 3
        inventoryDatabase.inventory[product] = count - 1
        // 4
        var shipments = shippingDatabase.pendingShipments[customer, default: []]
        shipments.append(product)
        shippingDatabase.pendingShipments[customer] = shipments
        // 5
        print("Order placed for '\(product.name)' " + "by '\(customer.name)'")
    }
}

/**
 1. 您首先将 product.name 和 customer.name 打印到控制台。
 2. 在完成订单之前，您要确保inventoryDatabase.inventory 中至少有一种给定的产品。 如果没有，则打印该产品缺货。
 3. 由于至少有一种产品可用，您可以完成订单。 因此，您可以将inventoryDatabase.inventory 中的产品计数减一。
 4. 然后将产品添加到给定客户的 shippingDatabase.pendingShipments 中。
 5. 最后，您打印订单已成功下达。
 */

// MARK: - Example
// 1
let rayDoodle = Product(identifier: "product-001", name: "Ray's doodle", cost: 0.25)
let vickiPoodle = Product(identifier: "product-002", name: "Vicki's prized poodle", cost: 1000)
// 2
let inventoryDatabase = InventoryDatabase(inventory: [rayDoodle: 50, vickiPoodle : 1])
// 3
let orderFacade = OrderFacade(inventoryDatabase: inventoryDatabase, shippingDatabase: ShippingDatabase())
// 4
let customer = Customer(identifier: "customer-001", address: "1600 Pennsylvania Ave, Washington, DC 20006", name: "Johnny Appleseed")
orderFacade.placeOrder(for: vickiPoodle, by: customer)

/**
 这是这样做的：
 1. 首先，您设置了两个产品。rayDoodle 是 Ray 的画作，vickiPoodle 是 Vicki 的珍贵宠物贵宾犬。 甚至不要让我开始谈论贵宾犬涂鸦！
 2. 接下来，您使用产品创建inventoryDatabase。有很多 rayDoodles（显然他喜欢涂鸦），只有一个 vickiPoodle。毕竟，这是她珍贵的贵宾犬！
 3. 然后，您使用 inventoryDatabase 和一个新的 ShippingDatabase 创建 orderFacade。
 4. 最后，您创建一个客户并调用 orderFacade.placeOrder(for:by:)。当然，您订购的是 Vicki 珍贵的贵宾犬。
 它很贵，但值得！
 */

// Place order for 'Vicki's prized poodle' by 'Johnny Appleseed'
// Order placed for 'Vicki's prized poodle' by 'Johnny Appleseed'
