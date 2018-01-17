//
//  HUD.swift
//  UIProgressHUD
//
//  Created by Emiaostein on 17/01/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import Foundation

struct HUD: HUDFactory {
    
    func makeHUD() -> UIViewController {
        let hud = UIStoryboard(name: "HUD", bundle: Bundle(for: UIProgressHUD.self)).instantiateViewController(withIdentifier: "HUD")
        
        return hud
    }
    
    func update(factory: HUDFactory) {
        guard let hud = factory as? HUD else { return }
    }
}
