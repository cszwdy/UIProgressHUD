//
//  ViewController.swift
//  Example
//
//  Created by Emiaostein on 17/01/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import UIKit
import UIProgressHUD

class ViewController: UIViewController {
    
    let items:[(String, String, TimeInterval, HUD)] = [
        ("Success",
         "Success will dismiss after 1.3 second.", 1.3,
         HUD(.success, "Success", "You have finished task successfully.")),
        
        ("Failture",
         "Failture will dismiss after 1.3 second.", 1.3,
         HUD(.failture, "Failture", "You fail to finished task.")),
        
        ("Like",
         "Like will dismiss after 1.3 second.", 1.3,
         HUD(.like, "Like", "You hava liked this song.")),
        
        ("Star",
         "Star will dismiss after 1.3 second.", 1.3,
         HUD(.star, "Star", "You hava stared this article.")),
        
        ("Send",
         "Send will dismiss after 1.3 second.", 1.3,
         HUD(.send, "Send", "Your feedback have sent.")),
        
        ("Loading",
         "Loadin will dismiss after 1.3 second.", 1.3,
         HUD(.loading, "Loading", "Please pay attention for the requst to finish.")),
        
        ("Progress",
         "Progress to 50% and will dismiss after 1.3 second.", 1.3,
         HUD(.progress(0.5), "50%", "You have finished task at 50%.")),
        
        ("Progress",
         "Progress to 60% and will dismiss after 10 scond.", 10,
         HUD(.progress(0.6), "60%", "You have finished task at 60%.")),
        ]
    
    let appends: [(String, String)] = [
        ("Update", "Progress will update to 100% and dismiss after 1 second."),
        ("Dimiss", "Any HUD will dismiss."),
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIProgressHUD.isUserInteractionEnabled = false
        
    }
    @IBAction func action_isUserInteractionEnabled(_ sender: UIButton) {
        UIProgressHUD.isUserInteractionEnabled = !UIProgressHUD.isUserInteractionEnabled
        
        let touchable = UIProgressHUD.isUserInteractionEnabled == false
        sender.isSelected = touchable
        
        if (touchable) {
            UIProgressHUD.present(HUD(.success, "Enabled", "You can interact during HUD appear."), dismissAfter: 1.5, completed: nil)
        } else {
            UIProgressHUD.present(HUD(.failture, "Disabled", "You can't interact during HUD appear."), dismissAfter: 1.5, completed: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + appends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let titleLabel = cell.viewWithTag(100) as! UILabel
        let subTitleLabel = cell.viewWithTag(101) as! UILabel
        
        if indexPath.item < items.count {
            let i = indexPath.item
            titleLabel.text = items[i].0
            subTitleLabel.text = items[i].1
        } else {
            let i = indexPath.item - items.count
            titleLabel.text = appends[i].0
            subTitleLabel.text = appends[i].1
        }
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item < items.count {
            let i = indexPath.item
            UIProgressHUD.present(items[i].3, dismissAfter: items[i].2) {
                print("Did dismiss.")
            }
        } else {
            let i = indexPath.item - items.count
            switch i {
            case 0:
                UIProgressHUD.updateTo(HUD(.progress(0.7), "70%", "Downloading..."))
                UIProgressHUD.updateTo(HUD(.progress(0.8), "80%", "Downloading..."), after: 1.0, completed: nil)
                UIProgressHUD.updateTo(HUD(.progress(0.9), "90%", "Downloading..."), after: 2.0, completed: nil)
                UIProgressHUD.updateTo(HUD(.progress(1.0), "100%", "Done! You have finished downloading file."), after: 3.0, completed: nil)
                
                UIProgressHUD.dismiss(after: 4.0, completed: nil)
                
            case 1:
                UIProgressHUD.dismiss()
            default:
                ()
            }
        }
        
        
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (finished) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                cell?.transform = .identity
            }, completion: nil)
        }
    }
}

