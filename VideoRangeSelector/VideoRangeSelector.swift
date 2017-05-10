//
//  VideoRangeSelector.swift
//  VideoRangeSelector
//
//  Created by Yuki Horiguchi on 2017/05/09.
//  Copyright © 2017年 Yuki Horiguchi. All rights reserved.
//

import UIKit
import AVFoundation

class VideoRangeSelector: UIView {
  
  // MARK: Components
  fileprivate var scrollView: UIScrollView!
  fileprivate var thumbnailView: UIImageView!
  fileprivate var rangeRectangleView: UIView!
  fileprivate var rangeHandle: EasyTouchView!

  // MARK: Params
  let rangeRectangleMargin: CGFloat = 20
  let rangeRectangleBoarderWidth: CGFloat = 2
  let rangeHandleWidth: CGFloat = 20
  let rangeHandleInsets = UIEdgeInsetsMake(0,20,0,20)
  let rangeColor: UIColor = .magenta
  let rangeHandleSlitColor: UIColor = .darkGray
  let rangeHandleSlitWidth: CGFloat = 4
  let rangeHandleSlitMargin: CGFloat = 15
  
  let pixPerSec: CGFloat = 15
  let minSec: Float = 3
  
  public var asset: AVAsset? {
    didSet {
      setAsset()
    }
  }
  
  // MARK: - Override methods
  override func awakeFromNib() {
    super.awakeFromNib()
    prepare()
  }
  
  override func willRemoveSubview(_ subview: UIView) {
    super.willRemoveSubview(subview)
  }
  
  
  // MARK: - for Prepare
  fileprivate func prepare() {
    
    // scrollView
    scrollView = UIScrollView.init(frame: self.bounds)
    scrollView.delegate = self
    
    thumbnailView = UIImageView.init()
    thumbnailView.contentMode = .topLeft
    self.addSubview(scrollView)
    
    // range
    let rectRect = CGRect.init(x: rangeRectangleMargin,
                               y: CGFloat(0),
                               width: self.bounds.width - rangeRectangleMargin * 2,
                               height: self.bounds.height)
    rangeRectangleView = UIView.init(frame: rectRect)
    rangeRectangleView.layer.borderColor = rangeColor.cgColor
    rangeRectangleView.layer.borderWidth = rangeRectangleBoarderWidth
    self.addSubview(rangeRectangleView)
    
    // handle
    let handleRect = CGRect.init(x: self.bounds.width - rangeRectangleMargin - rangeHandleWidth,
                                 y: CGFloat(0),
                                 width: rangeHandleWidth,
                                 height: self.bounds.height)
    rangeHandle = EasyTouchView.init(frame: handleRect)
    rangeHandle.insets = rangeHandleInsets
    rangeHandle.backgroundColor = rangeColor
    
    let slitRect = CGRect.init(x: (rangeHandleWidth - rangeHandleSlitWidth) / 2,
                               y: rangeHandleSlitMargin,
                               width: rangeHandleSlitWidth,
                               height: self.bounds.height - rangeHandleSlitMargin * 2)
    let slit = UIView.init(frame: slitRect)
    slit.layer.cornerRadius = rangeHandleSlitWidth / 2
    slit.backgroundColor = rangeHandleSlitColor

    rangeHandle.addSubview(slit)
    self.addSubview(rangeHandle)
    
    // handle guesture
    let guesture = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
    rangeHandle.addGestureRecognizer(guesture)

  }

  
  fileprivate func setAsset() {
    
  }
  
  
  func panHandle(_ sender: UIPanGestureRecognizer) {
    var x = sender.location(in: self).x
    let minX = (CGFloat(minSec) * pixPerSec) + rangeRectangleMargin
    let maxX = self.bounds.width - rangeRectangleMargin - rangeHandleWidth

    x = x < minX ? minX : x
    x = x > maxX ? maxX : x

    rangeHandle.frame.origin.x = x
    let rect = CGRect.init(x: rangeRectangleMargin,
                           y: CGFloat(0),
                           width: x - rangeRectangleMargin,
                           height: self.bounds.height)
    rangeRectangleView.frame = rect
    
  }
  
}

// MARK: - UIScrollViewDelegate
extension VideoRangeSelector: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
  }
}

class EasyTouchView: UIView {
  var insets = UIEdgeInsetsMake(0, 0, 0, 0)
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    var rect = bounds
    rect.origin.x -= insets.left
    rect.origin.y -= insets.top
    rect.size.width += insets.left + insets.right
    rect.size.height += insets.top + insets.bottom
    
    return rect.contains(point)
  }
}

class ReelImageGenerator {

  let asset: AVAsset
  let generator: AVAssetImageGenerator
  var backgroundColor = UIColor.clear
  
  init(_ asset: AVAsset){
    self.asset = asset
    generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
  }

  func reelImage(size: CGSize, frameWidth: CGFloat) -> UIImage {
    let frameSize = CGSize(width: frameWidth, height: size.height)
    let frameCount = Int((size.width / frameWidth).rounded(.up))
    let secPerFrame = asset.duration.seconds / Double(frameCount)
    let times:[CMTime] = (0..<frameCount).map { CMTimeMakeWithSeconds(Double($0) * secPerFrame, 1) }
    let images:[UIImage] = times.map { thumbnail($0, size: frameSize) }
    
    UIGraphicsBeginImageContext(size)
    var x: CGFloat = 0
    for image in images {
      image.draw(in: CGRect(origin: CGPoint(x: x, y: 0), size: frameSize))
      x += frameWidth
    }
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
  }
  
  private func thumbnail(_ time: CMTime, size: CGSize) -> UIImage {
    let cgimage: CGImage
    do {
      cgimage = try generator.copyCGImage(at: time, actualTime: nil)
    } catch {
      UIGraphicsBeginImageContext(size)
      let context = UIGraphicsGetCurrentContext()!
      context.setFillColor(backgroundColor.cgColor)
      context.fill(CGRect(origin: .zero, size: size))
      let outputImage = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      return outputImage
    }
    
    let image = UIImage(cgImage: cgimage)
    
    let outputWidthRatio = size.width / size.height
    let imageWidthRatio = image.size.width / image.size.height
    var drawSize: CGSize = size
    var drawPoint: CGPoint = .zero
    if outputWidthRatio < imageWidthRatio {
      // キャプチャ画像より出力画像のほうが縦長い
      drawSize = CGSize(width: imageWidthRatio * size.height, height: size.height)
      drawPoint = CGPoint(x: (size.width - drawSize.width) / 2, y: 0)
    } else {
      // キャプチャ画像より出力画像のほうが横長い
      drawSize = CGSize(width: size.width, height: size.width / imageWidthRatio)
      drawPoint = CGPoint(x: 0, y: (size.height - drawSize.height) / 2)
    }

    UIGraphicsBeginImageContext(size)
    image.draw(in: CGRect(origin: drawPoint, size: drawSize) )
    let thumbnail = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return thumbnail
  }
  
}
