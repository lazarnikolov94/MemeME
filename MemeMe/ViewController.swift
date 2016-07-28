//
//  ViewController.swift
//  MemeMe
//
//  Created by Lazar Nikolov on 7/21/16.
//  Copyright © 2016 Lazar Nikolov. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var memeTopTextField: UITextField!
    @IBOutlet weak var memeBottomTextField: UITextField!
    
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    var memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
        NSStrokeWidthAttributeName: -6.0
    ]
    
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        
        memeTopTextField.delegate = self
        memeBottomTextField.delegate = self
        
        shareButton.enabled = false
        
        self.cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.albumButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if(memeBottomTextField.isFirstResponder()) {
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            self.view.frame.origin.y -= keyboardSize.CGRectValue().height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(memeBottomTextField.isFirstResponder()) {
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            self.view.frame.origin.y += keyboardSize.CGRectValue().height
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        memeTopTextField.defaultTextAttributes = memeTextAttributes
        memeTopTextField.contentVerticalAlignment = .Center
        memeTopTextField.contentHorizontalAlignment = .Center
        memeTopTextField.textAlignment = .Center
        memeTopTextField.adjustsFontSizeToFitWidth = true
        
        memeBottomTextField.defaultTextAttributes = memeTextAttributes
        memeBottomTextField.contentVerticalAlignment = .Center
        memeBottomTextField.contentHorizontalAlignment = .Center
        memeBottomTextField.textAlignment = .Center
        memeBottomTextField.adjustsFontSizeToFitWidth = true
    }

    @IBAction func pickImage(sender: AnyObject) {
        presentImagePicker(UIImagePickerControllerSourceType.PhotoLibrary)
    }

    @IBAction func openCamera(sender: AnyObject) {
        presentImagePicker(UIImagePickerControllerSourceType.Camera)
    }
    
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController.sourceType = sourceType
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
            dismissViewControllerAnimated(true, completion: nil)
            shareButton.enabled = true
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func generateMemedImage() -> UIImage {
        var memedImage: UIImage?
        
        topBar.hidden = true
        bottomBar.hidden = true
        
        let rect = self.view.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        let context = UIGraphicsGetCurrentContext()!
        self.view.layer.renderInContext(context)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        topBar.hidden = false
        bottomBar.hidden = false
        
        return memedImage!
    }
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        
        let shareItems = [memedImage]
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            // TODO: Save memed image
            activityViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelMeme() {
        imageView.image = nil
        memeTopTextField.text = "TOP"
        memeBottomTextField.text = "BOTTOM"
    }
}

