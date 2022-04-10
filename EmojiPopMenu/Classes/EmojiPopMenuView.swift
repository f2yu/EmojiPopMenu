//
//  EmojiPopMenuView.swift
//  emojiPopmenu
//
//  Created by f2yu on 2022/2/28.
//

#if os(macOS)
import AppKit
private var imagesKey: Void?
private var durationKey: Void?
#else
import UIKit
import MobileCoreServices
private var imageSourceKey: Void?
#endif

#if !os(watchOS)
import CoreImage
#endif

import CoreGraphics
import ImageIO

public class EmojiPopMenuView: UIView {
    private(set) var items: [EmojiPopMenuItem] = []
    private var itemViews: [EmojiPopMenuItemView] = []
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    //图片背景图，配置阴影、背景色等
    public lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.clipsToBounds = false
        return view
    }()
    
    //锚点视图，配置锚点样式
    public lazy var anchorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 12, height: 8)
        return imageView
    }()
    
    private var config: EmojiPopMenuConfig = .default
    
    //视图距屏幕距离
    private let screenHorizontalMargin: CGFloat = 30
    
    private var currentIndex = -1
    
    private var beginFrame: CGRect = .zero
    private var endFrame: CGRect = .zero
    
    private var selectedBlock: ((_ item: EmojiPopMenuItem?) -> ())?
    
    private var direction: EmojiPopMenuDirection = .top
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .clear
        clipsToBounds = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_ :)))
        addGestureRecognizer(tap)
    }
    
    func updateLayout(_ config: EmojiPopMenuConfig, items: [EmojiPopMenuItem]) {
        self.config = config
        self.items = items
        EmojiPopMenuSelectedLocus.share.updateConfig(config)
        self.subviews.forEach { view in
            view.removeFromSuperview()
        }
        addSubview(contentView)
        
        contentView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        itemViews.removeAll()
        
        let width = config.contentEdge.left + config.contentEdge.right + CGFloat(items.count) * config.itemSize.width + CGFloat((max(1, items.count) - 1)) * config.itemSpace
        let height = config.contentEdge.top + config.contentEdge.bottom + config.itemSize.height
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        contentView.frame = rect
        backgroundView.frame = contentView.bounds
        backgroundView.layer.cornerRadius = height / 2
        contentView.addSubview(backgroundView)
        contentView.addSubview(anchorImageView)
        
        for (i, eItem) in items.enumerated() {
            let iv = EmojiPopMenuItemView(frame: CGRect(x: config.contentEdge.left + CGFloat(i) * (config.itemSize.width + config.itemSpace), y: config.contentEdge.top, width: config.itemSize.width, height: config.itemSize.height), config: config)
            let gif: Data?
            if let v = eItem as? EmojiPopMenuItemGifable {
                gif = v.gif
            } else {
                gif = nil
            }
            iv.config(image: eItem.image, title: eItem.title, gif: gif)
            iv.syncFrame(iv.frame)
            addItem(iv)
        }
    }
    
    func showOn(_ point: CGPoint, selectedBlock: ((_ item: EmojiPopMenuItem?) -> ())?) {
        self.selectedBlock = selectedBlock
        
        frame = UIScreen.main.bounds
        EmojiPopMenu.currentWindow?.addSubview(self)
        
        let x: CGFloat
        let y: CGFloat
        let anchorY: CGFloat
        
        if point.x + contentView.frame.width / 2 > UIScreen.main.bounds.width - screenHorizontalMargin {
            x = UIScreen.main.bounds.width - screenHorizontalMargin - contentView.frame.width
        } else if point.x - contentView.frame.width / 2 < screenHorizontalMargin {
            x = screenHorizontalMargin
        } else {
            x =  point.x - contentView.frame.width / 2
        }
        
        if point.y < UIScreen.main.bounds.height / 5 * 2 {
            y = point.y + config.distanceToTarget
            anchorY =  -anchorImageView.bounds.height / 2
            if config.isAnchorViewAutoRotation {
                anchorImageView.transform = .init(rotationAngle: CGFloat.pi)
            } else {
                anchorImageView.transform = .identity
            }
            direction = .top
        } else {
            y = point.y - config.distanceToTarget - contentView.frame.height
            anchorY = contentView.frame.height + anchorImageView.bounds.height / 2
            anchorImageView.transform = .identity
            direction = .bottom
        }
        
        contentView.alpha = 0
        beginFrame = CGRect(x: x, y: point.y, width: contentView.frame.width, height: contentView.frame.height)
        endFrame = CGRect(x: x, y: y, width: contentView.frame.width, height: contentView.frame.height)
        contentView.frame = beginFrame
        let inContentViewPoint = EmojiPopMenu.currentWindow?.convert(point, to: contentView) ?? .zero
        anchorImageView.center = CGPoint(x: inContentViewPoint.x, y: anchorY)
        if anchorImageView.frame.minX < contentView.bounds.height / 2 || anchorImageView.frame.maxX > contentView.bounds.width - contentView.bounds.height / 2 {
            anchorImageView.isHidden = true
        } else {
            anchorImageView.isHidden = false
        }
        
        updateIndex(-1)
        
        UIView.animate(withDuration: 0.33) {
            self.contentView.frame = self.endFrame
            self.contentView.alpha = 1
        }
    }
    
    func showOn(_ view: UIView, selectedBlock: ((_ item: EmojiPopMenuItem?) -> ())?) {
        EmojiPopMenuSelectedLocus.share.updateTo(view)
        let rect = view.convert(view.bounds, to: EmojiPopMenu.currentWindow)
        var point: CGPoint = .zero
        point.x = rect.midX
        if rect.minY < UIScreen.main.bounds.height / 5 * 2 {
            point.y = rect.maxY
        } else {
            point.y = rect.minY
        }
        showOn(point, selectedBlock: selectedBlock)
    }
    
    func hide() {
        UIView.animate(withDuration: 0.33) {
            self.contentView.frame = self.beginFrame
            self.contentView.alpha = 0
        } completion: { isFinished in
            if self.currentIndex >= 0 {
                self.selectedBlock?(self.items[self.currentIndex])
                EmojiPopMenuSelectedLocus.share.start(self.direction)
            } else {
                self.selectedBlock?(nil)
            }
            self.updateIndex(-1, animated: false)
            self.removeFromSuperview()
        }
    }
    
    //point 为在屏幕上的点
    func touchMove(_ point: CGPoint, isContainExt: Bool = true, animated: Bool = true) {
        let rect = convert(contentView.frame, to: EmojiPopMenu.currentWindow)
        let ext = isContainExt ? config.touchInZoomVerticalExt : 0
        if point.x < rect.minX ||
            point.x > rect.maxX ||
            point.y < rect.minY - ext ||
            point.y > rect.maxY + ext {
            updateIndex(-1, animated: animated)
        } else {
            var index = Int(floor((point.x - rect.minX) / (config.itemSize.width + config.itemSpace)))
            index = max(0, min(index, itemViews.count - 1))
            updateIndex(index, animated: animated)
        }
    }
    
    func updateIndex(_ index: Int, animated: Bool = true) {
        if currentIndex != index {
            currentIndex = index
            // 改变选中
            let centers = index >= 0 ? config.ownSelectedCenters(itemViews.count, selectedIndex: index, direction: direction) : config.normalCenters(itemViews.count)
            for (index, v) in itemViews.enumerated() {
                if index == currentIndex {
                    v.selected(animated: animated, toCenter: centers[index], direction: direction)
                } else {
                    v.unSelected(animated: animated, toCenter: centers[index], currentSelectedIndex: currentIndex)
                }
            }
        }
    }
    
    private func addItem(_ view: EmojiPopMenuItemView) {
        itemViews.append(view)
        contentView.addSubview(view)
    }
    
    @objc private func tapGesture(_ tap: UITapGestureRecognizer) {
        touchMove(tap.location(in: self), isContainExt: false, animated: false)
        hide()
    }
}

class EmojiPopMenuItemView: UIView {
    
    private var title: String?
    private var image: UIImage = UIImage()
    private var gif: Data?
    
    private(set) var isSelected: Bool = false
    
    private var selectedScale: CGFloat = 1.55 //选中时的放大尺寸
    private var otherScale: CGFloat = 0.88 //当自己被选中时，其他的缩小尺寸
    private var config: EmojiPopMenuConfig = EmojiPopMenuConfig()
    private var direction: EmojiPopMenuDirection = .top
    
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var topTitleLabel: UILabel = createLabel()
    
    private lazy var bottomTitleLabel: UILabel = createLabel()
        
    init(frame: CGRect, config: EmojiPopMenuConfig) {
        super.init(frame: frame)
        self.config = config
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        clipsToBounds = false
        addSubview(imageView)
        addSubview(topTitleLabel)
        addSubview(bottomTitleLabel)
    }
    
    private func layoutUI() {
        imageView.frame = bounds
        
        let maxWidth = UIScreen.main.bounds.width / 3
        let titleHeight = config.titleLabelConfig.height
        let textWidth = max(titleHeight / 3 * 2, min(title?.boundingRect(with: CGSize(width: maxWidth, height: titleHeight), context: nil).width ?? 0, maxWidth))
        let titleWidth = textWidth + config.titleLabelConfig.horizontalMargin * 2
        let rect = CGRect(x: (frame.width - titleWidth) / 2, y: 0, width: titleWidth, height: titleHeight)
        topTitleLabel.frame = CGRect(x: rect.minX, y: -config.titleLabelConfig.distanceToImage - titleHeight, width: rect.width, height: rect.height)
        topTitleLabel.layer.cornerRadius = titleHeight / 2
        
        bottomTitleLabel.frame = CGRect(x: rect.minX, y: imageView.frame.maxY + config.titleLabelConfig.distanceToImage, width: rect.width, height: rect.height)
        bottomTitleLabel.layer.cornerRadius = titleHeight / 2
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutUI()
    }
    
    func selected(animated: Bool, toCenter: CGPoint, direction: EmojiPopMenuDirection) {
        isSelected = true
        EmojiPopMenuSelectedLocus.share.updateFrom(self, image: image)
        if direction == .top {
            topTitleLabel.isHidden = true
            bottomTitleLabel.isHidden = false
        } else {
            topTitleLabel.isHidden = false
            bottomTitleLabel.isHidden = true
        }
        if animated {
            startZoomInAnimation(toCenter)
        } else {
            stopAnimation(toCenter)
        }
    }
    
    func unSelected(animated: Bool, toCenter: CGPoint, currentSelectedIndex: Int) {
        isSelected = false
        if animated && currentSelectedIndex >= 0 {
            startZoomOutAnimation(toCenter)
        } else {
            stopAnimation(toCenter)
        }
    }
    
    private func startZoomInAnimation(_ toCenter: CGPoint) {
        UIView.animate(withDuration: config.animationTime) {
            self.transform = .init(scaleX: self.selectedScale, y: self.selectedScale)
            self.topTitleLabel.alpha = 1
            self.bottomTitleLabel.alpha = 1
            self.center = toCenter
        }
    }
    
    private func startZoomOutAnimation(_ toCenter: CGPoint) {
        UIView.animate(withDuration: config.animationTime) {
            self.transform = .init(scaleX: self.otherScale, y: self.otherScale)
            self.topTitleLabel.alpha = 0
            self.bottomTitleLabel.alpha = 0
            self.center = toCenter
        }
    }
    
    private func stopAnimation(_ toCenter: CGPoint) {
        UIView.animate(withDuration: config.animationTime) {
            self.transform = .identity
            self.topTitleLabel.alpha = 0
            self.bottomTitleLabel.alpha = 0
            self.center = toCenter
        }
    }
    
    func syncFrame(_ frame: CGRect, selectedScale: CGFloat = 1.55, otherScale: CGFloat = 0.88) {
        self.frame = frame
        self.selectedScale = selectedScale
        self.otherScale = otherScale
        imageView.layer.cornerRadius = frame.height / 2
    }
    
    func config(image: UIImage, title: String? = nil, gif: Data? = nil) {
        self.image = image
        self.title = title
        self.gif = gif
        imageView.image = image
        imageView.layer.removeAllAnimations()
        
        topTitleLabel.text = title
        bottomTitleLabel.text = title
        if let gif = gif {
            imageView.startGif(gif)
        }
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.font = config.titleLabelConfig.font
        label.textColor = config.titleLabelConfig.textColor
        label.textAlignment = config.titleLabelConfig.textAlignment
        label.backgroundColor = config.titleLabelConfig.backgroundColor
        label.layer.masksToBounds = true
        label.alpha = 0
        return label
    }
}

private class EmojiPopMenuSelectedLocus: NSObject, CAAnimationDelegate {
    
    static let share = EmojiPopMenuSelectedLocus()
    
    private var imageView: UIImageView = UIImageView()
    private var fromCenter: CGPoint = .zero
    private var toCenter: CGPoint = .zero
    private var toSize: CGSize = .zero
    private var animationLayer: CALayer?
    private var config: EmojiPopMenuConfig = EmojiPopMenuConfig.default
    
    func updateConfig(_ config: EmojiPopMenuConfig) {
        self.config = config
    }
    
    func updateFrom(_ view: UIView, image: UIImage) {
        let fromRect = view.convert(view.bounds, to: EmojiPopMenu.currentWindow)
        fromCenter = CGPoint(x: fromRect.midX, y: fromRect.midY)
        imageView.frame = view.frame
        imageView.image = image
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = view.frame.height / 2
    }
    
    func updateTo(_ view: UIView) {
        let toRect = view.convert(view.bounds, to: EmojiPopMenu.currentWindow)
        toCenter = CGPoint(x: toRect.midX, y: toRect.midY)
        toSize = toRect.size
    }
    
    func start(_ direction: EmojiPopMenuDirection) {
        let controlY = direction == .top ? fromCenter.y + abs(toCenter.x - fromCenter.x) * 0.5 : fromCenter.y - abs(toCenter.x - fromCenter.x) * 0.5
        let controlPoint1 = CGPoint(x: fromCenter.x + (toCenter.x - fromCenter.x) * 0.25, y: controlY)
        let controlPoint2 = CGPoint(x: fromCenter.x + (toCenter.x - fromCenter.x) * 0.75, y: controlY)
        var toScaleValue = 0.3
        if config.isTraceTargetView &&  toSize.height > 0 {
            toScaleValue = imageView.frame.height / toSize.height
        }
        animationLayer = createLayer()
        EmojiPopMenu.currentWindow?.layer.addSublayer(animationLayer!)
        
        let path = UIBezierPath()
        path.move(to: fromCenter)
        path.addCurve(to: toCenter, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.path = path.cgPath

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = toScaleValue
        
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.isRemovedOnCompletion = false
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0.3

        let groups = CAAnimationGroup()
        groups.animations = [pathAnimation, scaleAnimation, alphaAnimation]
        groups.duration = config.animationTime
        groups.isRemovedOnCompletion = false
        groups.delegate = self
        
        animationLayer?.add(groups, forKey: "group")
        
    }
    
    private func createLayer() -> CALayer {
        let layer = CALayer()
        layer.bounds = imageView.bounds
        layer.position = fromCenter
        layer.masksToBounds = imageView.layer.masksToBounds
        layer.cornerRadius = imageView.layer.cornerRadius
        layer.contents = imageView.layer.contents
        layer.contentsScale = UIScreen.main.scale
        return layer
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationLayer?.removeFromSuperlayer()
        animationLayer = nil
    }
}

extension UIImageView {
    func startGif(_ data: Data) {
        let info = getInfo(data)
        animationImages = info.images
        animationDuration = info.duration
        startAnimating()
    }
    
    func startGif(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            startGif(data)
        } catch {}
    }
    
    private func getInfo(_ data: Data) -> (duration: TimeInterval, images: [UIImage]) {
        var duration: TimeInterval = 0
        var images: [UIImage] = []
        let info: [String: Any] = [
            kCGImageSourceShouldCache as String: true,
            kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF
        ]
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, info as CFDictionary) else {
            return (duration, images)
        }
        let frameCount = CGImageSourceGetCount(imageSource)
        for i in 0 ..< frameCount {
            guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, info as CFDictionary) else {
                return (duration, images)
            }
            if frameCount == 1 {
                duration = Double.infinity
            } else{
                guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil),
                      let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
                    let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else {
                    return (duration, images)
                }
                duration += frameDuration.doubleValue
                // 获取帧的img
                let image = UIImage(cgImage: imageRef , scale: UIScreen.main.scale , orientation: .up)
                // 添加到数组
                images.append(image)
            }
        }
        return (duration, images)
    }
}
