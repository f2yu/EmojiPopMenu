//
//  VSEmojiPopMenuItem.swift
//  emojiPopmenu
//
//  Created by f2yu on 2022/2/28.
//

import UIKit

public protocol EmojiPopMenuItemGifable {
    var gif: Data? { get }
}

public class EmojiPopMenuItem {
    public private(set) var id: String
    public private(set) var image: UIImage
    public private(set) var title: String?
    
    public init(_ id: String, image: UIImage, title: String? = nil) {
        self.id = id
        self.image = image
        self.title = title
    }
}

public class EmojiPopMenuGifItem: EmojiPopMenuItem, EmojiPopMenuItemGifable {
    public private(set) var gif: Data?
    
    public init(_ id: String, image: UIImage, title: String? = nil, gif: Data?) {
        self.gif = gif
        super.init(id, image: image, title: title)
    }
}
