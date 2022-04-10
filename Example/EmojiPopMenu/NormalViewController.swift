//
//  NormalViewController.swift
//  EmojiPopMenu
//
//  Created by f2yu on 2022/4/10.
//

import UIKit
import EmojiPopMenu

class NormalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        let v1 = UIView(frame: CGRect(x: 100, y: 100, width: 40, height: 40))
        v1.backgroundColor = .red
        view.addSubview(v1)
        
        let v2 = UIView(frame: CGRect(x: 300, y: 400, width: 40, height: 40))
        v2.backgroundColor = .red
        view.addSubview(v2)
        
        EmojiPopMenu.shared.register(view: v1) { item in
            print("v1 -> \(item?.id ?? "-1")")
        }
        EmojiPopMenu.shared.register(view: v2) { item in
            print("v2 -> \(item?.id ?? "-1")")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
