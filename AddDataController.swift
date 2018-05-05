//
//  AddDataController.swift
//  TestBanner
//
//  Created by 創意遊玩 on 2018/5/3.
//  Copyright © 2018年 田腾飞. All rights reserved.
//

import UIKit
import SQLite3
import AVKit

class AddDataController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    var getUIImage: UIImage? = nil
    var dbDelegate = DatabaseController()
    
    @IBAction func picButtonOnClick(_ sender: Any) {
        
        //dbDelegate.saveImageDocumentDirectory(imageName: dbDelegate.getWiFiAddress()! + ".jpg", imageFile: getUIImage!)
        
        photoLibrary()
        
    }
    @IBAction func submitOnCLick(_ sender: UIButton) {
        
        //   dbDelegate.saveImageDocumentDirectory(imageName: <#T##String#>, imageFile: <#T##UIImage#>)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func photoLibrary()
    {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        let videoURL = info[UIImagePickerControllerMediaURL] as? URL
        let compatible: Bool = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum((videoURL?.path)!)
        
        if compatible{
            UISaveVideoAtPathToSavedPhotosAlbum((videoURL?.path)!, self, nil, nil)
            print("video_path: \(videoURL?.path as Any)")
        }
        
        //self.getUIImage = image
        let videoPlayer = AVPlayer(url: videoURL!)
        videoPlayer.actionAtItemEnd = .none
        let videoLayer = AVPlayerLayer(player: videoPlayer)
        videoLayer.frame = CGRect(x: CGFloat(0) * kScreenWidth, y: 0, width: kScreenWidth, height: 250)
        
        
        picker.dismiss(animated: true, completion: nil);
    }
    
}
