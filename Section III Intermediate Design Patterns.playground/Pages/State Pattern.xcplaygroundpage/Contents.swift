import UIKit
import PlaygroundSupport

// MARK: - Context
class TrafficLight: UIView {
    // MARK: - Instance Properties
    // 1
    private(set) var canisterLayers: [CAShapeLayer] = []
    
    public private(set) var currentState: TrafficLightState
    public private(set) var states: [TrafficLightState]
    
    // MARK: - Object Lifecycle
    // 2
    @available(*, unavailable, message: "Use init(canisterCount: frame:) instead")
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    // 3
    public init(canisterCount: Int = 3,
                frame: CGRect = CGRect(x: 0, y: 0, width: 160, height: 420),
                states: [TrafficLightState]) {
        // 3.1
        guard !states.isEmpty else {
            fatalError("states should not be empty")
        }
        self.currentState = states.first!
        self.states = states
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.86, green: 0.64, blue: 0.25, alpha: 1)
        createCanisterLayers(count: canisterCount)
        transition(to: currentState)
    }
    // 4
    private func createCanisterLayers(count: Int) {
        // 4.1
        let paddingPercentage: CGFloat = 0.2
        let yTotalPadding = paddingPercentage * bounds.height
        let yPadding = yTotalPadding / CGFloat(count + 1)
        // 4.2
        let canisterHeight = (bounds.height - yTotalPadding) / CGFloat(count)
        let xPadding = (bounds.width - canisterHeight) / 2.0
        var canisterFrame = CGRect(x: xPadding, y: yPadding, width: canisterHeight, height: canisterHeight)
        // 4.3
        for _ in 0..<count {
            let canisterShape = CAShapeLayer()
            canisterShape.path = UIBezierPath(ovalIn: canisterFrame).cgPath
            canisterShape.fillColor = UIColor.black.cgColor
            layer.addSublayer(canisterShape)
            canisterLayers.append(canisterShape)
            canisterFrame.origin.y += (canisterFrame.height + yPadding)
        }
    }
    
    private func transition(to state: TrafficLightState) {
        removeCanisterSublayers()
        currentState = state
        currentState.apply(to: self)
    }
    
    private func removeCanisterSublayers() {
        canisterLayers.forEach {
            $0.sublayers?.forEach{
                $0.removeFromSuperlayer()
            }
        }
    }
}

// MARK: - State Protocol
protocol TrafficLightState: AnyObject {
    // MARK: - Properties
    // 1
    var delay: TimeInterval { get }
    // MARK: - Instance Methods
    // 2
    func apply(to context: TrafficLight)
}

// MARK: - Concrete States
public class SolidTrafficLightState {
    // MARK: - Properties
    public let canisterIndex: Int
    public let color: UIColor
    public let delay: TimeInterval
    // MARK: - Object Lifecycle
    public init(canisterIndex: Int,
                color: UIColor,
                delay: TimeInterval) {
        self.canisterIndex = canisterIndex
        self.color = color
        self.delay = delay
    }
}

extension SolidTrafficLightState: TrafficLightState {
    func apply(to context: TrafficLight) {
        let canisterLayer = context.canisterLayers[canisterIndex]
        let circleShape = CAShapeLayer()
        circleShape.path = canisterLayer.path!
        circleShape.fillColor = color.cgColor
        circleShape.strokeColor = color.cgColor
        canisterLayer.addSublayer(circleShape)
    }
}

// MARK: - Convenience Constructors
extension SolidTrafficLightState {
    public class func greenLight(color: UIColor = UIColor(red: 0.21, green: 0.78, blue: 0.35, alpha: 1),
                                 canisterIndex: Int = 2,
                                 delay: TimeInterval = 1.0) -> SolidTrafficLightState {
        return SolidTrafficLightState(canisterIndex: canisterIndex, color: color, delay: delay)
    }
    
    public class func yellowLight(color: UIColor = UIColor(red: 0.98, green: 0.91, blue: 0.07, alpha: 1),
                                  canisterIndex: Int = 1,
                                  delay: TimeInterval = 0.5) -> SolidTrafficLightState {
        return SolidTrafficLightState(canisterIndex: canisterIndex, color: color, delay: delay)
    }
    
    public class func redLight(color: UIColor = UIColor(red: 0.88, green: 0, blue: 0.04, alpha: 1),
                               canisterIndex: Int = 0,
                               delay: TimeInterval = 2.0) -> SolidTrafficLightState {
        return SolidTrafficLightState(canisterIndex: canisterIndex, color: color, delay: delay)
    }
}

let greenYellowRed: [SolidTrafficLightState] = [.greenLight(), .yellowLight(), .redLight()]
let trafficLight = TrafficLight(states: greenYellowRed)
PlaygroundPage.current.liveView = trafficLight

/**
 这是这样做的：
 1. 首先为 canisterLayers 定义一个属性。 这将保留“交通灯罐”层。 这些层将保持绿色/黄色/红色状态作为子层。
 2. 为了让操场简单，你不会支持 init(coder:)。
 3. 您将 init(canisterCount:frame:) 声明为指定的初始化程序，并为 canisterCount 和 frame 提供默认值。 您还将 backgroundColor 设置为淡黄色并调用 createCanisterLayers(count:)。
 您将在 createCanisterLayers(count:) 中完成真正的工作。 将以下内容添加到此方法中：
 4.1. 您首先将 yTotalPadding 计算为 bounds.height 的百分比，然后使用结果确定每个 yPadding 空间。 “填充空间”的总数等于 count（罐的数量）+ 1（底部多出一个空间）。
 4.2. 使用 yPadding，计算 canisterHeight。 为了使容器保持方形，您可以使用 canisterHeight 作为每个容器的高度和宽度。 然后，您使用 canisterHeight 计算使每个容器居中所需的 xPadding。
 最终，您使用 xPadding、yPadding 和 canisterHeight 来创建
 canisterFrame，它表示第一个容器的框架。
 4.3. 使用 canisterFrame，您从 0 循环到 count 以创建所需数量的容器的 canisterShape，由 count 给出。 创建每个 canisterShape 后，将其添加到 canisterLayers。 通过保留对每个容器层的引用，您稍后可以向它们添加“交通灯状态”子层。
 */

