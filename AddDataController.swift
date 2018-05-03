//
//  AddDataController.swift
//  TestBanner
//
//  Created by 創意遊玩 on 2018/5/3.
//  Copyright © 2018年 田腾飞. All rights reserved.
//

import UIKit

class AddDataController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    var getUIImage: UIImage? = nil
    
    @IBAction func picButtonOnClick(_ sender: Any) {
        
        photoLibrary()
        
    }
    @IBAction func submitOnCLick(_ sender: UIButton) {

        
        
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
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.getUIImage = image
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
}
