//
//  UIProgressHUD.swift
//  UIProgressHUD
//
//  Created by Emiaostein on 17/01/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import Foundation

public protocol HUDFactory {
    func makeHUD() -> UIViewController
    func update(factory: HUDFactory)->Bool
    func equal(to factory: HUDFactory)->Bool
}

public enum HUDState {
    
    case presenting
    case cancelling
    case dismissing
    case dismissed
}

var currentFactory: HUDFactory?

public class UIProgressHUD {
    
    static var state: HUDState = .dismissed
    static var sentryCount: Int = 0
    static weak var hudContainer: HUDContainerViewController?
    static var topest: UIViewController? {
        var top = UIApplication.shared.keyWindow?.rootViewController
        while top?.presentedViewController != nil {
            top = top?.presentedViewController
        }
        return top
    }
    
    public static func present<T: HUDFactory>(_ factory: T,
                               dismissAfter after: TimeInterval = .infinity,
                               completed:(()->())? = nil) {
        DispatchQueue.main.async {
            guard let top = topest else { return }
            if let current = currentFactory {
                guard !current.equal(to: factory) else {return}
            }
            
            func began<T: HUDFactory>(new1: HUDContainerViewController, top1: UIViewController, factory1: T, after1: TimeInterval, completed1:(()->())?) {
                willPresent(new: new1, top: top1)
                currentFactory = factory1
                willDismiss(after: after1, completed: completed1)
            }
            
            switch state {
            case .presenting:
                // cancel and present
                let container = HUDContainerViewController(hud: factory.makeHUD())
                willCancel {
                    began(new1: container,
                          top1: top,
                          factory1: factory,
                          after1: after) {
                            hudContainer = nil
                            currentFactory = nil
                    }
                }
                
            case .cancelling:
                return
            case .dismissing:
                // cancel and present
                let container = HUDContainerViewController(hud: factory.makeHUD())
                willCancel {
                    began(new1: container,
                          top1: top,
                          factory1: factory,
                          after1: after) {
                            hudContainer = nil
                            currentFactory = nil
                    }
                }
            case .dismissed:
                // present
                let container = HUDContainerViewController(hud: factory.makeHUD())
                began(new1: container,
                      top1: top,
                      factory1: factory,
                      after1: after) {
                        hudContainer = nil
                        currentFactory = nil
                }
            }
        }
    }
    
    public static func update<T: HUDFactory>(_ factory: T) {
        if currentFactory?.update(factory: factory) ?? false {
            currentFactory = factory
        }
    }
    
    public static func dismiss(after: TimeInterval = 0.0, completed:(()->())? = nil) {
        if hudContainer != nil {
            willDismiss(after: after) {
                hudContainer = nil
                currentFactory = nil
            }
        }
        
    }
}

extension UIProgressHUD {
    
    // cancel
    static func willCancel(completed:@escaping ()->()) {
        state = .cancelling
        sentryCount += 1
        let i = sentryCount
        if let old = hudContainer {
            old.disappear(completed: { (theOld) in
                theOld.view.removeFromSuperview()
                theOld.removeFromParentViewController()
                hudContainer = nil
                guard i == sentryCount else {return}
                completed()
            })
        } else {
            completed()
        }
    }
    
    static func willPresent(new: HUDContainerViewController, top: UIViewController) {
        state = .presenting
        if let old = hudContainer {
            old.view.removeFromSuperview()
            old.removeFromParentViewController()
        }
        
        top.addChildViewController(new)
        top.view.addSubview(new.view)
        
        hudContainer = new
    }
    
    static func willDismiss(after: TimeInterval, completed:(()->())?) {
        let i = sentryCount
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            guard i == sentryCount else {return}
            state = .dismissing
            if let c = hudContainer {
                c.disappear(completed: { (vc) in
                    vc.view.removeFromSuperview()
                    vc.removeFromParentViewController()
                    hudContainer = nil
                    guard i == sentryCount else {return}
                    state = .dismissed
                    completed?()
                })
            } else {
                state = .dismissed
                completed?()
            }
        }
    }
}

class HUDContainerViewController: UIViewController {
    
    let hud: UIViewController
    
    init(hud: UIViewController) {
        self.hud = hud
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
        addChildViewController(hud)
        view.addSubview(hud.view)
        hidden()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        weak var sf = self
        UIView.animate(withDuration: 0.2, animations: {
            sf?.show()
        }, completion: nil)
    }
    
    func disappear(completed:@escaping (UIViewController)->()) {
        weak var sf = self
        UIView.animate(withDuration: 0.2, animations: {
            sf?.hidden()
        }) { (finished) in
            guard let s = sf else {return}
            completed(s)
        }
    }
    
    private func show() {
        hud.view.alpha = 1.0
        hud.view.transform = .identity
    }
    
    private func hidden() {
        hud.view.alpha = 0.0
        hud.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
}
