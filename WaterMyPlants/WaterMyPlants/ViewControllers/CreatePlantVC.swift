//
//  CreatePlantVC.swift
//  WaterMyPlants
//
//  Created by Shawn James on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit
import Cloudinary

class CreatePlantVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var addAPhotoLabel: UILabel!
    @IBOutlet weak var uploadThisImageButton: UIButton!
    @IBOutlet weak var uploadProgressBar: CustomProgressView!
    @IBOutlet weak var uploadProgressPercentLabel: UILabel!
    @IBOutlet weak var removeThisImageButton: UIButton!
    @IBOutlet weak var plantNicknameTextField: UITextField!
    @IBOutlet weak var timeIntervalPicker: UIPickerView!
    
    public var imagePicker: UIImagePickerController? // save reference to it
    lazy var cloudinaryConfiguration = CLDConfiguration(cloudName: "dehqhte0i", apiKey: "959718959598545", secure: true)
    lazy var cloudinaryController = CLDCloudinary(configuration: cloudinaryConfiguration)
    var imageURL: String? // this contains the url for the image that was uploaded
    let numbers = ["1", "2", "3", "4", "5", "6", "7"] // picker view
    let calendarComponents = ["days", "weeks"] // picker view
    var selectedTimeInterval: String? // this contains the time interval the user has selected as a string
    var keyboardHeight: CGFloat?
    var keyboardIsOpen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialViews()
        createObservers()
    }
    
    deinit {
        // stop listening to keyboard events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    /// sets up the view to their initial state
    private func setupInitialViews() {
        deactivateButton(uploadThisImageButton)
        deactivateButton(removeThisImageButton)
        uploadProgressBar.alpha = 0
        uploadProgressPercentLabel.alpha = 0
        plantNicknameTextField.addBottomBorder()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)) // handles tap anywhere to dismiss keyboard
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        guard let imageURL = self.imageURL else { return }
        let randomID: Int16 = Int16.random(in: 1...32766)
        let newPlant = Plant(id: Int(randomID), species: "species", nickname: plantNicknameTextField.text ?? "No Name", h2oFreqency: selectedTimeInterval ?? "No Time Interval", userID: String(randomID), imageURL: imageURL ) // FIXME: - <-- this is temporary
        try! CoreDataManager.shared.save() // FIXME: - <-- this is temporary
        // TODO: save to core data and network
        self.dismiss(animated: false)
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        presentPhotoLibraryActionSheet()
    }
    
    private func presentPhotoLibraryActionSheet() {
        // make sure imagePicker is nill
        if self.imagePicker != nil {
            self.imagePicker?.delegate = nil
            self.imagePicker = nil
        }
        // init image picker
        self.imagePicker = UIImagePickerController()
        // action sheet
        let actionSheet = UIAlertController(title: "Select Source Type", message: nil, preferredStyle: .actionSheet)
        // imagePickerActions
        if UIImagePickerController.isSourceTypeAvailable(.camera) { // need to have real device
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.presentImagePicker(controller: self.imagePicker!, sourceType: .camera)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.presentImagePicker(controller: self.imagePicker!, sourceType: .photoLibrary)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            actionSheet.addAction(UIAlertAction(title: "Saved Albums", style: .default, handler: { _ in
                self.presentImagePicker(controller: self.imagePicker!, sourceType: .savedPhotosAlbum)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // present action sheet
        self.present(actionSheet, animated: true)
    }
    
    func presentImagePicker(controller: UIImagePickerController, sourceType: UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = sourceType
        self.present(controller, animated: true)
    }
    
    /// Deactivates irrelevant buttons and calls to upload image
    @IBAction func uploadThisImageButtonPressed(_ sender: UIButton) {
        deactivateButton(removeThisImageButton)
        deactivateButton(uploadThisImageButton)
        uploadImage()
    }
    
    /// moves the keyboard down
    @objc func dismissKeyboard() {
        keyboardIsOpen = false
        view.endEditing(true)
        view.frame.origin.y = 0
        DispatchQueue.main.async {
            self.keyboardIsOpen = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    /// uploads an image and returns a URL of it's location in the imageURL property in the CreatePlantVC
    private func uploadImage() {
        guard let imageData: Data = selectedImage.image?.jpegData(compressionQuality: 1) else { return }
        cloudinaryController.createUploader().upload(data: imageData, uploadPreset: "y1v3bbv4", progress: { (progress) in
            // handle progress
            self.uploadProgressBar.alpha = 1
            self.uploadProgressPercentLabel.alpha = 1
            self.uploadProgressBar.progress = Float(progress.fractionCompleted)
            self.uploadProgressPercentLabel.text = "\(Int(progress.fractionCompleted * 100))%"
        }) { (uploadResult, error) in
            guard (error == nil) else {
                // if an error occurs, show it to the user
                let alert: UIAlertController = UIAlertController(title: "Error",
                                              message: error?.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true) {
                    // error occured. so reset everything
                    self.activateButton(self.uploadThisImageButton)
                    self.activateButton(self.removeThisImageButton)
                    self.uploadProgressBar.alpha = 0
                    self.uploadProgressPercentLabel.alpha = 0
                }
                return // will not finish the task if there is an error. is this a problem? silly errors?
            }
            // the upload has been successful. what now?
            if let imageURL = uploadResult?.secureUrl {
                self.uploadProgressPercentLabel.text = "Success!"
                print("image was uploaded to \(imageURL)")
                self.imageURL = imageURL
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.uploadProgressBar.alpha = 0
                    self.uploadProgressPercentLabel.alpha = 0
                }
            }
        }
    }
    
    /// resets the whole uploading an image process
    @IBAction func removeThisImageButtonPressed(_ sender: UIButton) {
        selectedImage.image = nil // reset image
        activateButton(addPhotoButton)
        addAPhotoLabel.alpha = 1
        deactivateButton(removeThisImageButton)
        deactivateButton(uploadThisImageButton)
    }
    
    /// restores the buttons to visibility and re-enables them to be pressed again
    func activateButton(_ button: UIButton) {
        button.isEnabled = true
        button.alpha = 1
    }
    
    /// hides the buttons and makes them so they can't be pressed
    func deactivateButton(_ button: UIButton) {
        button.isEnabled = false
        button.alpha = 0
    }
    
    func createObservers() {
        // listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    /// moves the keyboard up
    @objc func keyboardWillChange(notification: Notification) {
        print("Keyboard will show: \(notification.name.rawValue)")
        if keyboardIsOpen == true {
            view.frame.origin.y = -(self.keyboardHeight ?? 100)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height
        }
    }

}

extension CreatePlantVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return self.imagePickerControllerDidCancel(picker)
        }
        self.selectedImage.image = image
        picker.dismiss(animated: true) {
            // clean up
            picker.delegate = nil
            self.imagePicker = nil
        }
        deactivateButton(addPhotoButton)
        addAPhotoLabel.alpha = 0
        activateButton(uploadThisImageButton)
        activateButton(removeThisImageButton)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            // clean up
            picker.delegate = nil
            self.imagePicker = nil
        }
    }
    
}

extension CreatePlantVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 { return self.numbers.count }
        else { return self.calendarComponents.count }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return self.numbers[row] }
        else { return self.calendarComponents[row] }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var number = ""
        var calendarComponent = ""
        if component == 0 { number = numbers[row] }
        else { calendarComponent = calendarComponents[row] }
        self.selectedTimeInterval = number + " " + calendarComponent
    }

}

/// Used to set a custom height for UIProgressView
public class CustomProgressView: UIProgressView {
    var height: CGFloat = 4.0
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 30) // We can set the required height
    }
}
