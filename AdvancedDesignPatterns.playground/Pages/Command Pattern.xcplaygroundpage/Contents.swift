// MARK: - 命令模式

import Foundation

// MARK: - Receiver
public class Door {
    public var isOpen = false
}

// MARK: - Command
public class DoorCommand {
    public let door: Door
    
    public init(_ door: Door) {
        self.door = door
    }
    
    public func execute() {
        
    }
}

public class OpenCommand: DoorCommand {
    public override func execute() {
        print("opening the door")
        door.isOpen = true
    }
}

public class CloseCommand: DoorCommand {
    public override func execute() {
        print("close the door")
        door.isOpen = false
    }
}

// MARK: - Invoker
// 1
public class Doorman  {
    // 2
    let commands: [DoorCommand]
    let door: Door
    // 3
    init(door: Door) {
        let commandCount = arc4random_uniform(10) + 1
        self.commands = (0..<commandCount).map { index in
            return index % 2 == 0 ? OpenCommand(door) : CloseCommand(door)
        }
        self.door = door
    }
    // 4
    func execute() {
        print("Doorman is...")
        commands.forEach { $0.execute() }
    }
}

// MARK: - Example
public let isOpen = true
print("You predict the door will be " + "\(isOpen ? "open" : "closed").")
print("")

let door = Door()
let doorman = Doorman(door: door)
doorman.execute()
print("")
