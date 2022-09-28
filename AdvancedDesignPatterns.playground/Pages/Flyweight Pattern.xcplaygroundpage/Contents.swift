// MARK: - 享元模式
import UIKit

let red = UIColor.red
let red2 = UIColor.red
print(red === red2)

// true

let color = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
let color2 = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
print(color === color2)

// false

extension UIColor {
    // 1
    public static var colorStore: [String: UIColor] = [:]
    // 2
    public class func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        let key = "\(red)\(green)\(blue)\(alpha)"
        if let color = colorStore[key] {
            return color
        }
        // 3
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        colorStore[key] = color
        return color
    }
}

/**
 1. 您创建了一个名为 colorStore 的字典来存储 RGBA 值。
 2. 您编写了自己的方法，该方法采用红色、绿色、蓝色和 alpha，就像 UIColor 方法一样。 您将 RGB 值存储在一个名为 key 的字符串中。 如果 colorStore 中已经存在具有该键的颜色，请使用该颜色而不是创建新颜色。
 3. 如果 key 在 colorStore 中不存在，则创建 UIColor 并将其与 key 一起存储。
 */

let flyColor = UIColor.rgba(1, 0, 0, 1)
let flyColor2 = UIColor.rgba(1, 0, 0, 1)
print(flyColor === flyColor2)
// true
