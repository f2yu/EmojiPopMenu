//
//  ViewController.swift
//  EmojiPopMenu
//
//  Created by f2yu on 04/11/2022.
//  Copyright (c) 2022 f2yu. All rights reserved.
//

import UIKit
import EmojiPopMenu

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        emojiConfig()
        
        let gotoNormalButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 40))
        gotoNormalButton.setTitle("normal", for: .normal)
        gotoNormalButton.backgroundColor = .blue
        gotoNormalButton.addTarget(self, action: #selector(gotoNoraml), for: .touchUpInside)
        view.addSubview(gotoNormalButton)
        
        
        let gotoTableButton = UIButton(frame: CGRect(x: 100, y: 250, width: 100, height: 40))
        gotoTableButton.setTitle("table", for: .normal)
        gotoTableButton.backgroundColor = .red
        gotoTableButton.addTarget(self, action: #selector(gotoTable), for: .touchUpInside)
        view.addSubview(gotoTableButton)
    }
    
    @objc func gotoNoraml() {
        navigationController?.pushViewController(NormalViewController(), animated: true)
    }
    
    @objc func gotoTable() {
        navigationController?.pushViewController(TableViewController(), animated: true)
    }
    
    func emojiConfig() {
        let iv = EmojiPopMenu.shared.menuView.anchorImageView
        iv.image = UIImage(named: "anchor")
        let v = EmojiPopMenu.shared.menuView.backgroundView
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowRadius = 5
        v.layer.shadowOpacity = 0.3
        v.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        let gif = try? Data(contentsOf: Bundle.main.url(forResource: "cry", withExtension: "gif")!)
        let imageName = ["black", "haha", "like", "sleep", "smile"]
        EmojiPopMenu.shared.update([EmojiPopMenuGifItem("1", image: UIImage(named: "cry")!, title: "cry", gif: gif),
                                    EmojiPopMenuItem("2", image: UIImage(named: imageName[0])!, title: imageName[0]),
                                    EmojiPopMenuItem("3", image: UIImage(named: imageName[1])!, title: imageName[1]),
                                    EmojiPopMenuItem("4", image: UIImage(named: imageName[2])!, title: imageName[2]),
                                    EmojiPopMenuItem("5", image: UIImage(named: imageName[3])!, title: imageName[3]),
                                    EmojiPopMenuItem("6", image: UIImage(named: imageName[4])!, title: imageName[4])])
    }
}
