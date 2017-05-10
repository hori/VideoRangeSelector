//
//  ReelImageGenerator.swift
//  VideoRangeSelector
//
//  Created by Yuki Horiguchi on 2017/05/10.
//  Copyright © 2017年 Yuki Horiguchi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ReelImageGenerator {
  
  let asset: AVAsset
  let generator: AVAssetImageGenerator
  var backgroundColor = UIColor.clear
  
  init(_ asset: AVAsset){
    self.asset = asset
    generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
  }
  
  func reelImage(size: CGSize, frameWidth: CGFloat) -> UIImage {
    let frameSize = CGSize(width: frameWidth, height: size.height)
    let frameCount = Int((size.width / frameWidth).rounded(.up))
    let secPerFrame = asset.duration.seconds / Double(frameCount)
    let times:[CMTime] = (0..<frameCount).map { CMTimeMakeWithSeconds(Double($0) * secPerFrame, Int32(NSEC_PER_SEC)) }
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
      // OutputImage is longer verticaly
      drawSize = CGSize(width: imageWidthRatio * size.height, height: size.height)
      drawPoint = CGPoint(x: (size.width - drawSize.width) / 2, y: 0)
    } else {
      // OutputImage is longer horizontally
      drawSize = CGSize(width: size.width, height: size.width / imageWidthRatio)
      drawPoint = CGPoint(x: 0, y: (size.height - drawSize.height) / 2)
    }
    
    UIGraphicsBeginImageContext(size)
    image.draw(in: CGRect(origin: drawPoint, size: drawSize) )
    let outputImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return outputImage
  }
  
}
