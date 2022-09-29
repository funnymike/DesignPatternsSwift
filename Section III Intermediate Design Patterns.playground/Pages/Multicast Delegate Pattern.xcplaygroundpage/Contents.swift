import Foundation

// 1
public class MulticastDelegate<ProtocolType> {
    // MARK: - DelegateWrapper
    // 2
    private class DelegateWrapper {
        weak var delegate: AnyObject?
        
        init(_ delegate: AnyObject) {
            self.delegate = delegate
        }
    }
    
    // MARK: - Instance Properties
    // 1
    private var delegateWrappers: [DelegateWrapper]
    // 2
    var delegates: [ProtocolType] {
        delegateWrappers = delegateWrappers.filter {
            $0.delegate != nil
        }
        return delegateWrappers.map {
            $0.delegate!
        } as! [ProtocolType]
    }
    
    // MARK: - Object Lifecycle
    public init(delegate: [ProtocolType] = []) {
        delegateWrappers = delegate.map {
            DelegateWrapper($0 as AnyObject)
        }
    }
    
    // MARK: - Delegate Management
    // 1
    public func addDelegate(_ delegate: ProtocolType) {
        let wrapper = DelegateWrapper(delegate as AnyObject)
        delegateWrappers.append(wrapper)
    }
    // 2
    public func removeDelegate(_ delegate: ProtocolType) {
        guard let index = delegateWrappers.firstIndex(where: {
            $0.delegate === (delegate as AnyObject)
        }) else {
            return
        }
        delegateWrappers.remove(at: index)
    }
    
    public func invokeDelegates(_ closure: (ProtocolType) -> ()) {
        delegates.forEach {
            closure($0)
        }
    }
}

// MARK: - Delegate Protocol
public protocol EmergencyResponding {
    func notifyFire(at location: String)
    func notifyCarCrash(at location: String)
}

// MARK: - Delegate
//
public class FireStation: EmergencyResponding {
    public func notifyFire(at location: String) {
        print("Firefighters were notified about a fire at " + location)
    }
    
    public func notifyCarCrash(at location: String) {
        print("Firefighters were notified about a car crash at " + location)
    }
}

public class PoliceStation: EmergencyResponding {
    public func notifyFire(at location: String) {
        print("Police were notified about a fire at " + location)
    }
    public func notifyCarCrash(at location: String) {
        print("Police were notified about a car crash at " + location)
    }
}

class DispatchSystem {
    let multicastDelegate = MulticastDelegate<EmergencyResponding>()
}

// MARK: - Example
let dispatch = DispatchSystem()
var policeStation: PoliceStation? = PoliceStation()
var fireStation: FireStation? = FireStation()
dispatch.multicastDelegate.addDelegate(policeStation!)
dispatch.multicastDelegate.addDelegate(fireStation!)

dispatch.multicastDelegate.invokeDelegates {
    $0.notifyFire(at: "Ray's house")
}
print("")
fireStation = nil
dispatch.multicastDelegate.invokeDelegates {
    $0.notifyFire(at: "Ray's garage")
}
// Police were notified about a fire at Ray's house
// Firefighters were notified about a fire at Ray's house
//
// Police were notified about a fire at Ray's garage

/**
 1. 您将 MulticastDelegate 定义为一个泛型类，它接受任何 ProtocolType 作为泛型类型。 Swift 还没有提供将 <ProtocolType> 限制为仅协议的方法。因此，您可以传递一个具体的类类型而不是 ProtocolType 的协议。 但是，您很可能会使用协议。
 因此，您将泛型类型命名为 ProtocolType 而不仅仅是 Type。
 2. 你将 DelegateWrapper 定义为一个内部类。 您将使用它来将委托对象包装为弱属性。
 通过这种方式，多播委托可以持有强包装实例，而不是直接持有委托。
 
 */

