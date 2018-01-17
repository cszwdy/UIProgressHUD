//
//  HUD.swift
//  UIProgressHUD
//
//  Created by Emiaostein on 17/01/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import Foundation

public struct HUD: HUDFactory {
    
    static weak var hud: UIViewController?
    
    public static var update:(HUD, HUD, UIViewController)->Bool = updateHUD // old, new, HUD from makeHUD()
    public static var attach:(Resource)->(UIImageView)->() = attachResource
    
    public enum Resource: Equatable {
        case success
        case failture
        case like
        case star
        case send
        case loading
        case progress(CGFloat)
        
        public static func ==(lhs: HUD.Resource, rhs: HUD.Resource) -> Bool {
            switch (lhs, rhs) {
            case (HUD.Resource.progress(let lp), HUD.Resource.progress(let rp)):
                return lp == rp
            default:
                return true
            }
        }
    }
    
    let title: String
    let subTitle: String
    let resource: Resource

    public init(_ resource: Resource, _ title: String, _ subTitle: String) {
        self.resource = resource
        self.title = title
        self.subTitle = subTitle
    }
    
    public func makeHUD() -> UIViewController {
        let hud = UIStoryboard(name: "HUD", bundle: Bundle(for: UIProgressHUD.self)).instantiateViewController(withIdentifier: "HUD")
        
        let imageView = hud.view.viewWithTag(100) as! UIImageView
        let titleLabel = hud.view.viewWithTag(101) as! UILabel
        let subTitlelabel = hud.view.viewWithTag(102) as! UILabel
        
        titleLabel.text = title
        subTitlelabel.text = subTitle
        HUD.attach(resource)(imageView)
        
        HUD.hud = hud
        
        return hud
    }
    
    public func equal(to factory: HUDFactory) -> Bool {
        guard let hud = factory as? HUD else { return false}
        return hud.title == title && hud.subTitle == subTitle && hud.resource == resource
    }
    
    public func update(factory: HUDFactory) -> Bool {
        guard !equal(to: factory) else {
            return false
        }
        
        guard let hud = HUD.hud, let f = factory as? HUD else {
            return false
        }
        
        return updateHUD(old: self, new: f, hud: hud)
    }
}

func updateHUD(old: HUD, new: HUD, hud: UIViewController)->Bool {
    
    let titleUpdate = old.title != new.title
    let subTitleUpdate = old.subTitle != new.subTitle
    
    let titleLabel = hud.view.viewWithTag(101) as! UILabel
    let subTitlelabel = hud.view.viewWithTag(102) as! UILabel
    
    switch (old.resource, new.resource) {
    case (.progress(let cp), .progress(let p)):
        let progressUpdate = cp != p
        titleLabel.text = new.title
        subTitlelabel.text = new.subTitle
        if let progressView = hud.view.viewWithTag(200) as? ProgressView {
            progressView.play(from: cp, to: p)
        }
        return titleUpdate || subTitleUpdate || progressUpdate
    default:
        return false
    }
    
    
}

func attachResource(resource: HUD.Resource)->(UIImageView)->() {
    return { (imageView: UIImageView) in
        let bundle = Bundle(for: UIProgressHUD.self)
        switch resource {
        case .success:
            imageView.image = UIImage(named: "hud-success", in: bundle, compatibleWith: nil)
        case .failture:
            imageView.image = UIImage(named: "hud-failture", in: bundle, compatibleWith: nil)
        case .like:
            imageView.image = UIImage(named: "hud-like", in: bundle, compatibleWith: nil)
        case .star:
            imageView.image = UIImage(named: "hud-star", in: bundle, compatibleWith: nil)
        case .send:
            imageView.image = UIImage(named: "hud-send", in: bundle, compatibleWith: nil)
        case .loading:
            imageView.animationImages = (0..<8).map{UIImage(named: "hud-loading-\($0)", in: bundle, compatibleWith: nil)!}
            imageView.animationDuration = 0.5
            imageView.startAnimating()
        case .progress(let p):
            let s1: CGFloat = 60
            let s2 = imageView.bounds.size
            let frame = imageView.bounds.insetBy(dx: (s2.width-s1)/2, dy: (s2.height-s1)/2)
            let progessView = ProgressView(frame: frame)
            progessView.tag = 200
            imageView.addSubview(progessView)
            progessView.play(from: 0, to: min(1, max(p, 0)), duration: 0.0)
        }
    }
}

class ProgressView: UIView {
    
    var progress: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI(frame: bounds)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createUI(frame: bounds)
    }
    
    func createUI(frame: CGRect) {
        let lineWidth: CGFloat = 3
        let inset: CGFloat = lineWidth / 2.0
        
        let oval = CAShapeLayer()
        self.layer.addSublayer(oval)
        oval.fillColor   = nil
        let v: CGFloat = 68.0/255.0
        oval.strokeColor = UIColor(red: v, green: v, blue: v, alpha: 1.0).cgColor
        oval.lineWidth   = lineWidth
        let ovalFrame = bounds.insetBy(dx: inset, dy: inset)
        oval.frame = ovalFrame
        oval.position = CGPoint(x: bounds.midX, y: bounds.midY)
        oval.path  = UIBezierPath(ovalIn: bounds).cgPath
        
        let len: CGFloat = 1
        let raduis: CGFloat = bounds.insetBy(dx: lineWidth + len, dy: lineWidth + len).width / 2
        let inset2: CGFloat = raduis/2 + lineWidth + len
        let oval2 = CAShapeLayer()
        self.layer.addSublayer(oval2)
        //        oval2.lineCap     = kCALineCapRound
        //        oval2.lineJoin    = kCALineJoinRound
        oval2.fillColor   = nil
        oval2.strokeColor = UIColor(red: v, green: v, blue: v, alpha: 1.0).cgColor
        oval2.lineWidth   = raduis
        oval2.strokeStart = 0
        oval2.strokeEnd = 0
        let oval2Frame = bounds.insetBy(dx: inset2, dy: inset2)
        oval2.frame = oval2Frame
        oval2.position = CGPoint(x: bounds.midX, y: bounds.midY)
        oval2.path  = UIBezierPath(ovalIn: CGRect(x: lineWidth / 2, y: lineWidth / 2, width: oval2Frame.width, height: oval2Frame.height)).cgPath
        
        progress = oval2
        
        self.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi * 0.5))
    }
    
    func play(from: CGFloat, to: CGFloat, duration: TimeInterval = 0.3) {
        
        if duration > 0 {
            ////Oval animation
            let ovalStrokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
            ovalStrokeEndAnim.values   = [min(1, from), min(1, to)]
            ovalStrokeEndAnim.keyTimes = [0, 1]
            ovalStrokeEndAnim.duration = duration
            ovalStrokeEndAnim.fillMode = kCAFillModeForwards
            ovalStrokeEndAnim.isRemovedOnCompletion = false
            
            progress.add(ovalStrokeEndAnim, forKey:"ovalUntitled1Anim")
        } else {
            progress.strokeStart = from
            progress.strokeEnd = to
        }
    }
}
