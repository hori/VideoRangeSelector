//
//  ViewController.swift
//  VideoRangeSelector
//
//  Created by Yuki Horiguchi on 2017/05/09.
//  Copyright © 2017年 Yuki Horiguchi. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation

class ViewController: UIViewController {

  @IBOutlet weak var rangeSelector: VideoRangeSelector!
  @IBOutlet weak var selectButton: UIButton!
  @IBOutlet weak var previewView: VideoRangeSelectorPlayerView!
  
  fileprivate let imagePickerController = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    rangeSelector.previewView = previewView
  }

  @IBAction func selectVideo(_ sender: AnyObject) {
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.delegate = self
    imagePickerController.mediaTypes = ["public.movie"]
    imagePickerController.allowsEditing = false
    present(imagePickerController, animated: true, completion: nil)
  }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let url = info["UIImagePickerControllerReferenceURL"] as? URL else { return }
    rangeSelector.asset = AVAsset(url: url)
  }
}
