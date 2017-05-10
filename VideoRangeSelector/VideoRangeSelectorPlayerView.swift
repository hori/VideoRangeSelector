//
//  VideoRangeSelectorPlayerView.swift
//  VideoRangeSelector
//
//  Created by Yuki Horiguchi on 2017/05/10.
//  Copyright © 2017年 Yuki Horiguchi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoRangeSelectorPlayerView: UIView {
  var player: AVPlayer? {
    get {
      return playerLayer.player
    }
    set {
      playerLayer.player = newValue
    }
  }
  
  var playerLayer: AVPlayerLayer {
    return layer as! AVPlayerLayer
  }
  
  override static var layerClass: AnyClass {
    return AVPlayerLayer.self
  }
}
