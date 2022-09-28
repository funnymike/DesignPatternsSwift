// MARK: - 中介者模式

import Foundation
// 1
open class Mediator<ColleagueType> {
    // 2
    private class ColleagueWrapper {
        var strongColleague: AnyObject?
        weak var weakColleague: AnyObject?
        // 3
        var colleague: ColleagueType? {
            (weakColleague ?? strongColleague) as? ColleagueType
        }
        // 4
        init(strongColleague: ColleagueType) {
            self.strongColleague = strongColleague as AnyObject
            self.weakColleague = nil
        }
        
        init(weakColleague: ColleagueType) {
            self.weakColleague = weakColleague as AnyObject
            self.strongColleague = nil
        }
    }
    // 1
    private var colleagueWrappers: [ColleagueWrapper] = []
    // 2
    public var colleagues: [ColleagueType] {
        var colleagues: [ColleagueType] = []
        colleagueWrappers = colleagueWrappers.filter {
            guard let  colleague = $0.colleague else {
                return false
            }
            colleagues.append(colleague)
            return true
        }
        return colleagues
    }
    //MARK: - Object Lifecycle
    // 3
    public init() {
        
    }
    
    /**
     以下是这段代码中发生的事情：
     1. 首先，您将 Mediator 定义为一个泛型类，它接受任何 ColleagueType 作为泛型类型。您还可以将 Mediator 声明为 open 以允许其他模块中的类对其进行子类化。
     2. 接下来，将ColleagueWrapper 定义为一个内部类，并在其上声明两个存储属性：strongColleague 和weakColleague。在某些用例中，您会希望 Mediator 留住同事，但在其他用例中，您不希望这样做。因此，您声明了weak 和strong 属性来支持这两种情况。
     不幸的是，Swift 没有提供一种方法来将泛型类型参数仅限于类协议。因此，您将 strongColleague 和 weakColleague 声明为 AnyObject?而不是 ColleagueType?。
     3. 接下来，将 colleague 声明为计算属性。这是一个便利属性，它首先尝试解开 weakColleague，如果它为 nil，那么它会尝试解开 strongColleague。
     4. 最后，声明两个指定的初始化器，init(weakColleague:) 和 init(strongColleague:)，用于设置 weakColleague 或 strongColleague。
     */
    
    // MARK: - Colleague Management
    // 1
    public func addColleage(_ colleage: ColleagueType, strongReference: Bool = true) {
        let wrapper: ColleagueWrapper
        if strongReference {
            wrapper = ColleagueWrapper(strongColleague: colleage)
        } else {
            wrapper = ColleagueWrapper(weakColleague: colleage)
        }
        colleagueWrappers.append(wrapper)
    }
    // 2
    public func removeColleage(_ colleage: ColleagueType) {
        guard let index = colleagues.firstIndex(where: {
            ($0 as AnyObject) === (colleage as AnyObject)
        }) else {
            return
        }
        colleagueWrappers.remove(at: index)
    }
    
    public func invokeColleagues(closure: (ColleagueType) -> Void) {
        colleagues.forEach(closure)
    }
    
    public func invokeColleagues(by colleague: ColleagueType, closure: (ColleagueType) -> Void) {
        colleagues.forEach {
            guard ($0 as AnyObject) !== (colleague as AnyObject) else {
                return
            }
            closure($0)
        }
    }
    
}






