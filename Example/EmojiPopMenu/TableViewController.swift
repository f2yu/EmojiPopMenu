//
//  TableViewController.swift
//  EmojiPopMenu
//
//  Created by f2yu on 2022/4/10.
//

import UIKit
import EmojiPopMenu

class ItemModel {
    var id1: String?
    var image1: UIImage?
    
    var id2: String?
    var image2: UIImage?
}

class TableViewCell: UITableViewCell {
    lazy var idLabel1: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var iv1: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .yellow.withAlphaComponent(0.3)
        return imageView
    }()
    
    lazy var idLabel2: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var iv2: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .blue.withAlphaComponent(0.3)
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(idLabel1)
        contentView.addSubview(iv1)
        
        contentView.addSubview(idLabel2)
        contentView.addSubview(iv2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        idLabel1.frame = CGRect(x: 20, y: 0, width: 100, height: 40)
        iv1.frame = CGRect(x: 80, y: 5, width: 30, height: 30)
        
        idLabel2.frame = CGRect(x: frame.maxX - 150, y: 0, width: 100, height: 40)
        iv2.frame = CGRect(x: frame.maxX - 60, y: 5, width: 30, height: 30)
    }
}

class TableViewController: UIViewController {

    private var source: [ItemModel] = {
        var source = [ItemModel]()
        for i in 0..<100 {
            source.append(ItemModel())
        }
        return source
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 130), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.rowHeight = 40
        tableView.separatorStyle = .singleLine
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "identifier")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
    }

}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier") as? TableViewCell
        let model = source[indexPath.row]
        cell?.idLabel1.text = "id: \(model.id1 ?? "no")"
        cell?.iv1.image = model.image1
        cell?.idLabel2.text = "id: \(model.id2 ?? "no")"
        cell?.iv2.image = model.image2
        if let iv = cell?.iv1 {
            EmojiPopMenu.shared.register(view: iv) { item in
                model.id1 = item?.id
                model.image1 = item?.image
                tableView.reloadData()
            }
        }
        if let iv = cell?.iv2 {
            EmojiPopMenu.shared.register(view: iv) { item in
                model.id2 = item?.id
                model.image2 = item?.image
                tableView.reloadData()
            }
        }
        return cell ?? UITableViewCell()
    }
}
