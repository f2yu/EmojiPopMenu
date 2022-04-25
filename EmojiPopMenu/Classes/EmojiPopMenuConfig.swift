//
//  EmojiPopMenuConfig.swift
//  emojiPopmenu
//
//  Created by f2yu on 2022/2/28.
//

import UIKit

public class EmojiPopMenuConfig {
    
    public static let `default` = EmojiPopMenuConfig()
    public static let autoCornerRadius: CGFloat = -1
    
    //缩放动画时间、选中后轨迹动画时间
    public var animationTime: TimeInterval = 0.33
    //true -> 轨迹会根据目标视图进行大小缩放，false ->默认缩放
    public var isTraceTargetView: Bool = true
    //表情间距
    public var itemSpace: CGFloat = 10
    //表情大小
    public var itemSize: CGSize = CGSize(width: 34, height: 34)
    //表情位于选中状态放大倍数
    public var itemZoomInScale: CGFloat = 1.55
    //其他表情位于选中状态时，表情的缩小倍数
    public var itemZoomOutScale: CGFloat = 0.88
    //表情托盘padding
    public var contentEdge: UIEdgeInsets = .init(top: 10, left: 12, bottom: 10, right: 12)
    //长按移动时垂直区域额外触发距离
    public var touchInZoomVerticalExt: CGFloat = 20
    //显示的title配置
    public var titleLabelConfig: EmojiPopMenuTitleLabelConfig = EmojiPopMenuTitleLabelConfig()
    //锚点视图是否根据上下边显示自动旋转
    public var isAnchorViewAutoRotation = true
    //距离目标point的距离，point为屏幕坐标
    public var distanceToTarget: CGFloat = 12
    //表情托盘圆角，autoCornerRadius，为高度的一半
    public var cornerRadius: CGFloat = EmojiPopMenuConfig.autoCornerRadius
    
    func normalCenters(_ totalCount: Int) -> [CGPoint] {
        var centers: [CGPoint] = []
        if totalCount == 0 {
            return centers
        }
        for i in 0..<totalCount {
            let point = CGPoint(x: contentEdge.left + itemSize.width / 2 + (itemSize.width + itemSpace) * CGFloat(i), y: contentEdge.top + itemSize.height / 2)
            centers.append(point)
        }
        return centers
    }
    
    func ownSelectedCenters(_ totalCount: Int, selectedIndex: Int, direction: EmojiPopMenuDirection) -> [CGPoint] {
        var centers: [CGPoint] = []
        if totalCount == 0 {
            return centers
        }
        //表情所占的宽度（不包括边距）
        let width = CGFloat(totalCount) * (itemSize.width + itemSpace) - itemSpace
        let itemSpace = (width - (CGFloat(totalCount - 1) * itemSize.width * itemZoomOutScale + itemSize.width * itemZoomInScale)) / CGFloat(totalCount - 1)
        var beginX = contentEdge.left
        for i in 0..<totalCount {
            let point: CGPoint
            if selectedIndex == i {
                let y = direction == .top ?
                contentEdge.top + itemSize.height / 2 * itemZoomInScale :
                contentEdge.top + itemSize.height / 2 * (2 - itemZoomInScale)
                point = CGPoint(x: beginX + itemSize.width * itemZoomInScale / 2, y: y)
                beginX += itemSize.width * itemZoomInScale
            } else {
                let y = direction == .top ?
                contentEdge.top + itemSize.height / 2 * itemZoomOutScale :
                contentEdge.top + itemSize.height / 2 * (2 - itemZoomOutScale)
                point = CGPoint(x: beginX + itemSize.width * itemZoomOutScale / 2, y: y)
                beginX += itemSize.width * itemZoomOutScale
            }
            beginX += itemSpace
            centers.append(point)
        }
        return centers
    }
}

public class EmojiPopMenuTitleLabelConfig {
    // font，需除以缩放倍数  11 / 1.55
    public var font: UIFont = UIFont.systemFont(ofSize: 11 / 1.55)
    public var textColor: UIColor = .white
    public var textAlignment: NSTextAlignment = .center
    public var backgroundColor: UIColor = .black.withAlphaComponent(0.5)
    public var height: CGFloat = 20 / 1.55
    //距离 background 的水平边距
    public var horizontalMargin: CGFloat = 6 / 1.55
    //离表情的距离
    public var distanceToImage: CGFloat = 5.5 / 1.55
}
