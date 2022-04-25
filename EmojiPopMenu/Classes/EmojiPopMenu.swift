//
//  EmojiPopmenu.swift
//  emojiPopmenu
//
//  Created by f2yu on 2022/2/28.
//

import UIKit

class EOMLongPressGestureRecognizer: UILongPressGestureRecognizer {}

private class EventItem {
    typealias SelectedBlock = ((_ item: EmojiPopMenuItem?) -> ())
    
    var selectedBlock: SelectedBlock?
    
    init(_ selectedBlock: SelectedBlock?) {
        self.selectedBlock = selectedBlock
    }
}

enum EmojiPopMenuDirection {
    case top
    case bottom
}

public class EmojiPopMenu {
    
    public static let shared: EmojiPopMenu = {
        return EmojiPopMenu()
    }()
    
    private var isChanged = false
    public var config: EmojiPopMenuConfig = EmojiPopMenuConfig.default
    
    public lazy var menuView: EmojiPopMenuView = {
        let view = EmojiPopMenuView()
        return view
    }()
    
    private var selectedBlocks = NSMapTable<UIView, EventItem>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    
    private var registerViews = NSHashTable<UIView>(options: .weakMemory)
    
    //配置、更新表情资源
    public func update(_ items: [EmojiPopMenuItem]) {
        menuView.updateLayout(config, items: items)
    }
    
    //注册视图，将给视图添加触发手势，处理手势不中断的情况下选择表情的问题
    public func register(view: UIView, selectedBlock: ((_ item: EmojiPopMenuItem?) -> ())?) {
        view.isUserInteractionEnabled = true
        registerViews.add(view)
        selectedBlocks.setObject(EventItem(selectedBlock), forKey: view)
        var isHasGesture = false
        for gesture in view.gestureRecognizers ?? [] {
            if gesture.isKind(of: EOMLongPressGestureRecognizer.self) {
                isHasGesture = true
                break;
            }
        }
        if isHasGesture == false {
            let long = EOMLongPressGestureRecognizer(target: self, action: #selector(longGesture(_ :)))
            view.addGestureRecognizer(long)
        }
    }
    
    //取消接管
    public func resign(view: UIView) {
        for gesture in view.gestureRecognizers ?? [] {
            if gesture.isKind(of: EOMLongPressGestureRecognizer.self) {
                view.removeGestureRecognizer(gesture)
                break;
            }
        }
        registerViews.remove(view)
        selectedBlocks.removeObject(forKey: view)
    }
    
    //主动触发表情控件方法
    public func showOn(_ view: UIView, selectedBlock: ((_ item: EmojiPopMenuItem?) -> ())?) {
        menuView.showOn(view, selectedBlock: selectedBlock)
    }
        
    @objc private func longGesture(_ long: EOMLongPressGestureRecognizer) {
        guard let view = long.view else {
            return
        }
        let point = long.location(in: EmojiPopMenu.currentWindow)
        switch long.state {
        case .began:
            isChanged = false
            menuView.showOn(view) { [weak self] item in
                guard let self = self else { return }
                self.selectedBlocks.object(forKey: view)?.selectedBlock?(item)
            }
        case .changed:
            isChanged = true
            menuView.touchMove(point)
            break
        default:
            if isChanged {
                menuView.hide()
            }
            break
        }
    }
}

extension EmojiPopMenu {
    static var currentWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first{
                return window
            }else if let window = UIApplication.shared.delegate?.window{
                return window
            }else{
                return nil
            }
        } else {
            if let window = UIApplication.shared.delegate?.window {
                return window
            }else{
                return nil
            }
        }
    }
}
