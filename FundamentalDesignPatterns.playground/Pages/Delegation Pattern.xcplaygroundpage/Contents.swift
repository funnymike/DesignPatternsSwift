import UIKit

public protocol MenuViewControllerDelegate: AnyObject {
    
    func menuViewController(_ menuViewController: MenuViewController, didSelectItemAtIndex index: Int)
}

public class MenuViewController: UIViewController {
    public weak var delegate: MenuViewControllerDelegate?
    
    
}
