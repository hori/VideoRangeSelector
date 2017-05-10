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
  public weak var previewView: VideoRangeSelectorPlayerView?

  fileprivate var scrollView: UIScrollView!
  fileprivate var reelImageView: UIImageView!
  fileprivate var rangeRectangleView: UIView!
  fileprivate var rangeHandle: EasyTouchView!
  fileprivate var indicatorView: UIActivityIndicatorView!
  
  fileprivate var player: AVPlayer?
  
  // MARK: Params
  let rangeRectangleMargin: CGFloat = 20
  let rangeRectangleBoarderWidth: CGFloat = 2
  let rangeHandleWidth: CGFloat = 20
  let rangeHandleInsets = UIEdgeInsetsMake(0,20,0,20)
  let rangeColor: UIColor = .magenta
  let rangeHandleSlitColor: UIColor = .darkGray
  let rangeHandleSlitWidth: CGFloat = 4
  let rangeHandleSlitMargin: CGFloat = 15
  let reelFrameWidth: CGFloat = 40
  
  let pxPerSec: CGFloat = 15 / 1
  let secPerPx: CGFloat = 1 / 15
  let minSec: Float = 3
  
  public var rangeBegin: CMTime?
  public var rangeEnd: CMTime?
  
  public var asset: AVAsset? {
    willSet {
      reelImageView.image = nil
    }
    didSet {
      setAsset()
      play()
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
    reelImageView = UIImageView.init()
    reelImageView.contentMode = .topLeft
    scrollView.addSubview(reelImageView)
    scrollView.showsHorizontalScrollIndicator = false
    self.addSubview(scrollView)
    
    // range
    let rectRect = CGRect.init(x: rangeRectangleMargin,
                               y: CGFloat(0),
                               width: self.bounds.width - rangeRectangleMargin * 2,
                               height: self.bounds.height)
    rangeRectangleView = UIView.init(frame: rectRect)
    rangeRectangleView.layer.borderColor = rangeColor.cgColor
    rangeRectangleView.layer.borderWidth = rangeRectangleBoarderWidth
    rangeRectangleView.isUserInteractionEnabled = false
    scrollView.contentInset = UIEdgeInsetsMake(0, rangeRectangleMargin, 0, rangeRectangleMargin)
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
    
    // indicator
    indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
    indicatorView.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
    indicatorView.stopAnimating()
    self.addSubview(indicatorView)
    self.bringSubview(toFront: indicatorView)

  }

  
  fileprivate func setAsset() {
    guard let asset = asset else { return }

    indicatorView.startAnimating()

    DispatchQueue.global(qos: .default).async { [unowned self] in
      let reelSize = CGSize(width: self.reelWidth() * UIScreen.main.scale,
                            height: self.bounds.height * UIScreen.main.scale)
      let viewSize = CGSize(width: self.reelWidth(),
                            height: self.bounds.height)
      let generator = ReelImageGenerator(asset)
      let reelImage = generator.reelImage(size: reelSize, frameWidth: self.reelFrameWidth * UIScreen.main.scale)

      DispatchQueue.main.async { [unowned self] in
        self.indicatorView.stopAnimating()
        self.reelImageView.image = reelImage
        self.reelImageView.frame = CGRect(origin: .zero, size: viewSize)
        self.reelImageView.contentMode = .scaleAspectFill
        self.scrollView.contentSize = viewSize
        self.moveHandle(self.frame.width)
      }
    }
  }
  
  func play() {
    guard let asset = asset else { return }
    guard let previewView = previewView else { return }
    
    player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
    previewView.playerLayer.player = player
    player?.play()
  }
  
  
  func panHandle(_ sender: UIPanGestureRecognizer) {
    moveHandle(sender.location(in: self).x)
  }
  
  fileprivate func moveHandle(_ x: CGFloat) {
    var distX = x
    let minX = (CGFloat(minSec) * pxPerSec) + rangeRectangleMargin
    let maxX = min(self.bounds.width - rangeRectangleMargin - rangeHandleWidth,
                   rangeRectangleMargin + reelWidth())
    distX = distX < minX ? minX : distX
    distX = distX > maxX ? maxX : distX
    rangeHandle.frame.origin.x = distX
    let rect = CGRect.init(x: rangeRectangleMargin,
                           y: CGFloat(0),
                           width: distX - rangeRectangleMargin,
                           height: self.bounds.height)
    rangeRectangleView.frame = rect
    scrollView.contentInset = UIEdgeInsetsMake(0, rangeRectangleMargin, 0, self.bounds.width - distX)
  }
  
  fileprivate func reelWidth() -> CGFloat {
    guard let asset = asset else { return 0 }
    return CGFloat(asset.duration.seconds) * pxPerSec
  }
  
  fileprivate func seek(_ x: CGFloat) {
    guard let _ = asset else { return }
    let time = CMTimeMakeWithSeconds(Double(x * secPerPx), Int32(NSEC_PER_SEC))
    
    player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter:  kCMTimeZero)
  }
  
}

// MARK: - UIScrollViewDelegate
extension VideoRangeSelector: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    var x = scrollView.contentOffset.x + scrollView.contentInset.left
    x = x < 0 ? 0 : x
    print(x)
    seek(x)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    player?.play()
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    player?.pause()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      player?.play()
    }
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
