
//
//  MDPageControl.swift
//  MDPageControl-swift
//
//  Created by issam on 13/06/2016.
//  Copyright © 2016 issam khalloufi. All rights reserved.
//
import UIKit
public struct MDPageControlAlignment {
    var value: UInt32
    init(_ val: UInt32) { value = val }
}
public let MDPageControlAlignmentLeft = MDPageControlAlignment(0)
public let MDPageControlAlignmentCenter = MDPageControlAlignment(1)
public let MDPageControlAlignmentRight = MDPageControlAlignment(2)

public struct MDPageControlVerticalAlignment {
    var value: UInt32
    init(_ val: UInt32) { value = val }
}
public let MDPageControlVerticalAlignmentTop = MDPageControlVerticalAlignment(0)
public let MDPageControlVerticalAlignmentMiddle = MDPageControlVerticalAlignment(1)
public let MDPageControlVerticalAlignmentBottom = MDPageControlVerticalAlignment(2)

public struct MDPageControlTapBehavior {
    var value: UInt32
    init(_ val: UInt32) { value = val }
}
public let MDPageControlTapBehaviorStep = MDPageControlTapBehavior(0)
public let MDPageControlTapBehaviorJump = MDPageControlTapBehavior(1)

public struct MDPageControlImageType {
    var value: UInt32
    init(_ val: UInt32) { value = val }
}
public let MDPageControlImageTypeNormal = MDPageControlImageType(0)
public let MDPageControlImageTypeCurrent = MDPageControlImageType(1)
public let MDPageControlImageTypeMask = MDPageControlImageType(2)


let DEFAULT_INDICATOR_WIDTH:CGFloat = 6.0
let DEFAULT_INDICATOR_MARGIN:CGFloat = 10.0

let DEFAULT_INDICATOR_WIDTH_LARGE:CGFloat = 7.0
let DEFAULT_INDICATOR_MARGIN_LARGE:CGFloat = 9.0
let DEFAULT_MIN_HEIGHT_LARGE:CGFloat =  36.0


public class MDPageControl: UIControl {
    public var numberOfPages:NSInteger = 0  //总数
    
    public var indicatorMargin:CGFloat = 0
    public var indicatorDiameter:CGFloat = 0
    public var minHeight:CGFloat = 0
    
    public var alignment:MDPageControlAlignment = MDPageControlAlignmentCenter
    public var verticalAlignment:MDPageControlVerticalAlignment = MDPageControlVerticalAlignmentMiddle
    
    public var currentPage:NSInteger = 0
    
    public var pageIndicatorImage:UIImage!
    public var pageIndicatorMaskImage:UIImage!
    public var pageIndicatorTintColor:UIColor!
    
    public var currentPageIndicatorImage:UIImage!
    public var currentPageIndicatorTintColor:UIColor!
    
    public var hidesForSinglePage:Bool = false
    public var defersCurrentPageDisplay:Bool = false
    
    public var tapBehavior:MDPageControlTapBehavior = MDPageControlTapBehaviorStep
    
    private var displayedPage:NSInteger = 0
    private var measuredIndicatorWidth:CGFloat = 0
    private var measuredIndicatorHeight:CGFloat = 0
    private var pageImageMask:CGImage!
    
    private var pageNames = [NSInteger: String]()
    private var pageImages = [NSInteger: UIImage]()
    private var currentPageImages = [NSInteger: UIImage]()
    private var pageImageMasks = [NSInteger: UIImage]()
    private var cgImageMasks = [NSInteger: CGImage]()
    private var pageRects = [CGRect]()
    
    private var accessibilityPageControl:UIPageControl = UIPageControl.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initialize()
    }
    override public var frame: CGRect {
        get {
            return super.frame
        }
        set (frame) {
            super.frame = frame
            setNeedsDisplay()
        }
    }
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func draw(_ rect: CGRect) {
        if (numberOfPages < 2 && hidesForSinglePage) {
            return;
        }
        let context = UIGraphicsGetCurrentContext()
        var _pageRects = [CGRect]()
        let left:CGFloat = leftOffset()
        var xOffset:CGFloat = left
        var yOffset:CGFloat = 0.0
        var fillColor:UIColor
        var image:UIImage?
        var maskingImage:CGImage?
        var maskSize:CGSize = CGSize.zero
        
        
        
        
        for indexNumber in 0..<numberOfPages {
            if (indexNumber == displayedPage) {
                fillColor = (currentPageIndicatorTintColor != nil) ? currentPageIndicatorTintColor : UIColor.white
                image = currentPageImages[indexNumber]
                if  nil == image {
                    image = currentPageIndicatorImage
                }
            } else {
                fillColor = (pageIndicatorTintColor != nil) ? pageIndicatorTintColor : UIColor.white.withAlphaComponent(0.3)
                image = pageImages[indexNumber]
                if nil == image {
                    image = pageIndicatorImage
                }
            }
            // If no finished images have been set, try a masking image
            if nil == image {
                if let originalImage:UIImage = pageImageMasks[indexNumber]{
                    maskSize = originalImage.size
                }
                
                maskingImage = cgImageMasks[indexNumber]
                // If no per page mask is set, try for a global page mask!
                if (nil == maskingImage) {
                    maskingImage = pageImageMask
                    if pageIndicatorMaskImage != nil{
                        maskSize = pageIndicatorMaskImage.size
                    }
                }
            }
            fillColor.set()
            var indicatorRect:CGRect;
            if (image != nil) {
                yOffset = topOffsetForHeight(height: image!.size.height,rect: rect)
                let centeredXOffset:CGFloat = xOffset + floor((measuredIndicatorWidth - image!.size.width) / 2.0)
                image!.draw(at: CGPoint(x: centeredXOffset, y: yOffset))
                indicatorRect = CGRect(x: centeredXOffset, y: yOffset, width: image!.size.width, height: image!.size.height)
            } else if (maskingImage != nil) {
                yOffset = topOffsetForHeight(height: maskSize.height, rect: rect)
                let centeredXOffset:CGFloat = xOffset + floor((measuredIndicatorWidth - maskSize.width) / 2.0)
                indicatorRect = CGRect(x: centeredXOffset, y: yOffset, width: maskSize.width, height: maskSize.height)
                context?.draw(maskingImage!, in: indicatorRect)
            } else {
                yOffset = topOffsetForHeight(height: indicatorDiameter, rect: rect)
                let centeredXOffset:CGFloat = xOffset + floor((measuredIndicatorWidth - indicatorDiameter) / 2.0);
                indicatorRect = CGRect(x: centeredXOffset, y: yOffset, width: indicatorDiameter, height: indicatorDiameter)
                context?.fillEllipse(in: indicatorRect)
            }
            _pageRects.append(indicatorRect)
            maskingImage = nil
            xOffset += measuredIndicatorWidth + indicatorMargin;
        }
        
        pageRects = _pageRects;
    }
    func initialize() {
        self.backgroundColor = UIColor.clear
        setStyleWithDefaults()
        self.isAccessibilityElement = true
        self.accessibilityTraits = UIAccessibilityTraitUpdatesFrequently
        self.contentMode = UIViewContentMode.redraw
    }
    func updateCurrentPageDisplay(){
        displayedPage = currentPage
        self.setNeedsLayout()
    }
    func leftOffset() -> CGFloat {
        let rect:CGRect = self.bounds;
        let size:CGSize = sizeForNumberOfPages(pageCount: numberOfPages)
        if alignment.value == MDPageControlAlignmentCenter.value {
            return ceil(rect.midX - CGFloat(size.width / 2.0))
        }
        if alignment.value == MDPageControlAlignmentRight.value {
            return rect.maxX - size.width
        }
        return 0;
    }
    func topOffsetForHeight(height:CGFloat, rect:CGRect) -> CGFloat {
        if verticalAlignment.value == MDPageControlVerticalAlignmentMiddle.value{
            return rect.midY - (height / 2.0);
        }
        if verticalAlignment.value == MDPageControlVerticalAlignmentBottom.value{
            return rect.maxY - height;
        }
        return 0;
    }
    func sizeForNumberOfPages(pageCount:NSInteger) -> CGSize {
        let marginSpace = CGFloat(max(0,pageCount - 1)) * indicatorMargin
        let indicatorSpace = CGFloat(pageCount) * measuredIndicatorWidth
        
        return CGSize(width: marginSpace + indicatorSpace, height: measuredIndicatorHeight)
    }
    func rectForPageIndicator(pageIndex : NSInteger) -> CGRect {
        if (pageIndex < 0 || pageIndex >= numberOfPages) {
            return CGRect.zero;
        }
        let left:CGFloat = leftOffset()
        let size:CGSize =  sizeForNumberOfPages(pageCount: pageIndex + 1)
        return CGRect(x: left + size.width - measuredIndicatorWidth, y: 0, width: measuredIndicatorWidth, height: measuredIndicatorWidth)
    }
    public func setImage(image:UIImage!,pageIndex:NSInteger,type:MDPageControlImageType){
        if (pageIndex < 0 || pageIndex >= numberOfPages) {
            return;
        }
        switch type.value {
        case MDPageControlImageTypeCurrent.value:
            if (image != nil){
                currentPageImages[pageIndex] = image
            }else{
                currentPageImages.removeValue(forKey: pageIndex)
            }
            break
        case MDPageControlImageTypeNormal.value:
            if (image != nil){
                pageImages[pageIndex] = image
            }else{
                pageImages.removeValue(forKey: pageIndex)
            }
            break
        case MDPageControlImageTypeMask.value:
            if (image != nil){
                pageImageMasks[pageIndex] = image
            }else{
                pageImageMasks.removeValue(forKey: pageIndex)
            }
            break
        default:
            break
        }
        
    }
    public func setImage(image:UIImage, pageIndex:NSInteger){
        setImage(image: image, pageIndex: pageIndex, type: MDPageControlImageTypeNormal)
        updateMeasuredIndicatorSizes()
    }
    public func setCurrentImage(image:UIImage,pageIndex:NSInteger){
        setImage(image: image, pageIndex: pageIndex, type: MDPageControlImageTypeCurrent)
        updateMeasuredIndicatorSizes()
    }
    public func setImageMask(image:UIImage?, pageIndex:NSInteger) {
        setImage(image: image, pageIndex: pageIndex, type: MDPageControlImageTypeMask)
        
        if nil == image{
            cgImageMasks.removeValue(forKey: pageIndex)
            return
        }
        cgImageMasks[pageIndex] = createMaskForImage(image: image!)
        updateMeasuredIndicatorSizeWithSize(size: image!.size)
        setNeedsDisplay()
    }
    override public func sizeThatFits(_ size:CGSize) -> CGSize {
        var sizeThatFits:CGSize = sizeForNumberOfPages(pageCount: numberOfPages)
        sizeThatFits.height = max(sizeThatFits.height,minHeight)
        return sizeThatFits
    }
    override public var intrinsicContentSize: CGSize{
        get{
            if (numberOfPages < 1 || (numberOfPages < 2 && hidesForSinglePage)) {
                return CGSize(width: UIViewNoIntrinsicMetric, height: 0.0)
            }
            return CGSize(width: UIViewNoIntrinsicMetric, height: max(measuredIndicatorHeight, minHeight))
        }
    }
//    override func intrinsicContentSize() -> CGSize {
//        if (numberOfPages < 1 || (numberOfPages < 2 && hidesForSinglePage)) {
//            return CGSizeMake(UIViewNoIntrinsicMetric, 0.0)
//        }
//        return CGSizeMake(UIViewNoIntrinsicMetric, max(measuredIndicatorHeight, minHeight))
//    }
    
    
    func updatePageNumberForScrollView(scrollView:UIScrollView) {
        currentPage = NSInteger(floor(scrollView.contentOffset.x / scrollView.bounds.size.width));
    }
    func setScrollViewContentOffsetForCurrentPage(scrollView:UIScrollView,animated:Bool){
        var offset:CGPoint = scrollView.contentOffset
        offset.x = scrollView.bounds.size.width * CGFloat(currentPage)
        scrollView.setContentOffset(offset, animated: animated)
    }
    func setStyleWithDefaults() {
        setIndicatorDiameter(_indicatorDiameter: DEFAULT_INDICATOR_WIDTH_LARGE)
        setIndicatorMargin(_indicatorMargin: DEFAULT_INDICATOR_MARGIN_LARGE)
        pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.2)
        setMinHeight(_minHeight: DEFAULT_MIN_HEIGHT_LARGE)
    }
    //MARK :
    func createMaskForImage(image:UIImage) -> CGImage? {
        let pixelsWide = image.size.width * image.scale
        let pixelsHigh = image.size.height * image.scale
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = image.cgImage?.bitsPerComponent
        let bytesPerRow = pixelsWide * 5
        let context:CGContext? = CGContext.init(data: nil,
                                          width: Int(pixelsWide),
                                          height: Int(pixelsHigh),
                                          bitsPerComponent: bitsPerComponent!,
                                          bytesPerRow: Int(bytesPerRow),
                                          space: colorSpace,
                                          bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)
        
        context?.translateBy(x: 0.0, y: pixelsHigh)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh))
        let maskImage:CGImage? =  context?.makeImage()
        return maskImage
    }
    
    func updateMeasuredIndicatorSizeWithSize(size:CGSize){
        measuredIndicatorWidth = max(measuredIndicatorWidth, size.width);
        measuredIndicatorHeight = max(measuredIndicatorHeight, size.height);
    }
    func updateMeasuredIndicatorSizes(){
        measuredIndicatorWidth = indicatorDiameter;
        measuredIndicatorHeight = indicatorDiameter;
        // If we're only using images, ignore the indicatorDiameter
        if ((pageIndicatorImage != nil || pageIndicatorMaskImage != nil) && currentPageIndicatorImage != nil)
        {
            measuredIndicatorWidth = 0;
            measuredIndicatorHeight = 0;
        }
        
        if (pageIndicatorImage != nil) {
            updateMeasuredIndicatorSizeWithSize(size: pageIndicatorImage.size)
        }
        
        if (currentPageIndicatorImage != nil) {
            updateMeasuredIndicatorSizeWithSize(size: currentPageIndicatorImage.size)
        }
        
        if (pageIndicatorMaskImage != nil) {
            updateMeasuredIndicatorSizeWithSize(size: pageIndicatorMaskImage.size)
        }
        invalidateIntrinsicContentSize()
    }
    @nonobjc
    func setIndicatorDiameter(_indicatorDiameter:CGFloat) {
        if (_indicatorDiameter == indicatorDiameter) {
            return
        }
        indicatorDiameter = _indicatorDiameter
        // Absolute minimum height of the control is the indicator diameter
        if (minHeight < indicatorDiameter) {
            setMinHeight(_minHeight: indicatorDiameter)
        }
        updateMeasuredIndicatorSizes()
        setNeedsDisplay()
    }
    @nonobjc
    func setIndicatorMargin(_indicatorMargin:CGFloat) {
        if (_indicatorMargin == indicatorMargin) {
            return
        }
        indicatorMargin = _indicatorMargin;
        setNeedsDisplay()
    }
    @nonobjc
    func setMinHeight(_minHeight:CGFloat) {
        if (_minHeight == minHeight) {
            return
        }
        minHeight = _minHeight
        if (minHeight < indicatorDiameter) {
            minHeight = indicatorDiameter
        }
        
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        
    }
    @nonobjc
    func setNumberOfPages(_numberOfPages:NSInteger) {
        if _numberOfPages == numberOfPages {
            return;
        }
        accessibilityPageControl.numberOfPages = _numberOfPages
        numberOfPages = _numberOfPages
        self.invalidateIntrinsicContentSize()
        updateAccessibilityValue()
        setNeedsDisplay()
    }
    
    
    
    public func setCurrentPage(_currentPage:NSInteger) {
        setCurrentPage(_currentPage: _currentPage, sendEvent: false, canDefer: false)
    }
    public func setCurrentPage(_currentPage:NSInteger,sendEvent:Bool,canDefer:Bool) {
        currentPage = min(max(0,_currentPage),numberOfPages - 1)
        accessibilityPageControl.currentPage = currentPage
        
        updateAccessibilityValue()
        
        if self.defersCurrentPageDisplay == false || canDefer == false{
            displayedPage = currentPage
            setNeedsDisplay()
        }
        if sendEvent{
            self.sendActions(for: UIControlEvents.valueChanged)
        }
    }
    
    
    
    public func setPageIndicatorImage(currentPageIndicatorImage:UIImage,pageIndicatorImage:UIImage){
        if !currentPageIndicatorImage.isEqual(self.currentPageIndicatorImage) {
            self.currentPageIndicatorImage = currentPageIndicatorImage
        }
        
        if !pageIndicatorImage.isEqual(pageIndicatorMaskImage){
            self.pageIndicatorImage = pageIndicatorImage
        }
        updateMeasuredIndicatorSizes()
        setNeedsDisplay()
    }

    
    @nonobjc
    public func setPageIndicatorMaskImage(_pageIndicatorMaskImage:UIImage) {
        if _pageIndicatorMaskImage.isEqual(pageIndicatorMaskImage){
            return
        }
        pageIndicatorMaskImage = _pageIndicatorMaskImage
        pageImageMask = createMaskForImage(image: pageIndicatorMaskImage)
        updateMeasuredIndicatorSizes()
        setNeedsDisplay()
    }
    // MARK : UIAccessibility
    public func setName(name:String,pageIndex:NSInteger) {
        if (pageIndex < 0 || pageIndex >= numberOfPages) {
            return;
        }
        pageNames[pageIndex] = name;
    }
    func nameForPage(pageIndex:NSInteger) -> String? {
        if (pageIndex < 0 || pageIndex >= numberOfPages) {
            return nil;
        }
        return pageNames[pageIndex];
    }
    
    func updateAccessibilityValue() {
        let pageName = nameForPage(pageIndex: currentPage)
        if pageName != nil{
            self.accessibilityValue = "\(pageName) - \(accessibilityPageControl.accessibilityValue)"
        }else{
            self.accessibilityValue = accessibilityPageControl.accessibilityValue
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch!.location(in: self)
        if(MDPageControlTapBehaviorJump.value == tapBehavior.value){
            var tappedIndicatorIndex:NSInteger = NSNotFound
            for (index, value) in pageRects.enumerated() {
                let indicatorRect:CGRect = value
                if indicatorRect.contains(point){
                    tappedIndicatorIndex = index
                    break
                }
            }
            if NSNotFound != tappedIndicatorIndex{
                setCurrentPage(_currentPage: tappedIndicatorIndex, sendEvent: true, canDefer: true)
                return
            }
        }
        let size = sizeForNumberOfPages(pageCount: numberOfPages)
        let left = leftOffset()
        let middle = left + (size.width / 2)
        if point.x < middle{
            setCurrentPage(_currentPage: currentPage - 1, sendEvent: true, canDefer: true)
        }else{
            setCurrentPage(_currentPage: currentPage + 1, sendEvent: true, canDefer: true)
        }
    }
}
