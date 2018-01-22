//
//  MemeEditorViewController.swift
//  Image Picker Experiment
//
//  Created by Vineet Joshi on 1/11/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit



// MARK: Initialize all constants



let TOP_TAG = 0
let BOTTOM_TAG = 1
let DEFAULT_TEXT = ["[TOP TEXT]", "[BOTTOM TEXT]"]
let MEME_TEXT_ATTRIBUTES: [String : Any] = [
    NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
    NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
    NSAttributedStringKey.font.rawValue : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSAttributedStringKey.strokeWidth.rawValue : -4.0
]

class MemeEditorViewController: UIViewController {
    
    
    
    // MARK: Initialize outlets and class variables
    
    
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topMemeField: UITextField!
    @IBOutlet weak var bottomMemeField: UITextField!
    
    // top Toolbar and its outlets:
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // bottom Toolbar and its outlets:
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var chooseImageButton: UIBarButtonItem!
    
    // default value of the final Meme:
    // var finalMeme = Meme(topText: nil, bottomText: nil, originalImage: nil, memedImage: nil)
    
    var bottomEditing = false
    
    
    
    // MARK: Overriden functions from UIViewController
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // if the current device does not have a camera, then disable the Camera button:
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // a 'guard' statement is like 'if not let'!
        
        // sets up the text attributes of the meme Text Fields:
        setupMemeField(topMemeField, with: TOP_TAG)
        setupMemeField(bottomMemeField, with: BOTTOM_TAG)
        
        shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // NSNotifications provide a way to announce information throughout an app, even across classes
        self.subscribeToKeyboardNotifications()
        
        // if user has selected an image and both meme fields are filled, then enable the "Share" Button
        shareButton.isEnabled = (imagePickerView.image != nil && topMemeField.text != DEFAULT_TEXT[TOP_TAG] && bottomMemeField.text != DEFAULT_TEXT[BOTTOM_TAG])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            chooseImageButton.isEnabled = false
        } else {
            chooseImageButton.isEnabled = true
        }
    }
    
    
    
    // MARK: Function to setup the meme Text Fields:
    
    
    
    func setupMemeField(_ textField: UITextField, with tag: Int) {
        textField.tag = tag
        textField.text = DEFAULT_TEXT[tag]
        textField.defaultTextAttributes = MEME_TEXT_ATTRIBUTES
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
    }
    
    
    
    // MARK: Keyboard Notification functions
    
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        // '.UIKeyboardWillShow' is shortened version of 'Notification.Name.UIKeyboardWillShow'
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomEditing {
            // moves the View up by the height of the keyboard: (so the keyboard won't cover up the content!)
            self.view.frame.origin.y = self.getKeyboardHeight(notification) * -1
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomEditing {
            // moves the View up by the height of the keyboard: (so the keyboard won't cover up the content!)
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        // Notifications carry information in the 'userInfo' Dictionary
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue  // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        // '.UIKeyboardWillShow' is shortened version of 'Notification.Name.UIKeyboardWillShow'
    }
    
    
    
    // MARK: Picking an Image
    
    
    
    @IBAction func pickImage(_ sender: Any) {
        // launches a UIImagePickerController
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        // decides whether the camera or "Select Image" Button was pressed:
        if (sender as! UIBarButtonItem).tag == 0 {
            pickerController.sourceType = .camera
        } else {
            pickerController.sourceType = .photoLibrary
        }
        self.present(pickerController, animated: true, completion: nil)
    }
    
    // (see ImagePickerExtensions.swift file for UIImagePickerControllerDelegate functions)
    
    // (see TextFieldExtensions.swift file for UITextFieldDelegate functions)
    
    
    
    // MARK: Saving an Image
    
    
    
    @IBAction func shareImage(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, success, items, error in
            // this only saves the meme if the activity is completed (not if the user cancels)
            if success {
                self.saveMeme()
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    func saveMeme() {
        // create the meme
        let finalMeme = Meme(topText: topMemeField.text!, bottomText: bottomMemeField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        // add this Meme to the shared data
        (UIApplication.shared.delegate as! AppDelegate).memes.append(finalMeme)
    }
    
    // Given by instructor:
    func generateMemedImage() -> UIImage {
        // hides the top/bottom Toolbars:
        hideToolbars(hide: true)
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // shows the top/bottom Toolbars:
        hideToolbars(hide: false)
        
        return memedImage
    }
    
    func hideToolbars(hide: Bool) {
        topToolbar.isHidden = hide
        bottomToolbar.isHidden = hide
    }
    
    @IBAction func cancel(_ sender: Any) {
        // TODO: implement a dialogue box confirming the cancellation
        self.dismiss(animated: true, completion: nil)
    }
}

