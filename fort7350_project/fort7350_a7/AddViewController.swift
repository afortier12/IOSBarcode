//
//  AddViewController.swift
//  fort7350_a4
//
//  Created by Adam Fortier on 2021-03-07.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var card: Card?
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answerTextField: UITextField!
    var imagePickerController: UIImagePickerController!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    func getCard() -> Card? {
        return self.card
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        questionTextField.delegate = self
        answerTextField.delegate = self
       
        photoImageView.isUserInteractionEnabled = true

        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = self
        
        //register gesture recognizer
        //Reference:
        //      https:\\stackoverflow.com/questions/11330544/uiimageview-as-button/11330696
        
        let imageTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(recognizer:)))
        imageTap.numberOfTapsRequired = 1
        photoImageView.addGestureRecognizer(imageTap)

        self.view.addSubview(photoImageView)
        updateSaveButtonState()
    }
    
    
    @IBAction func cancelAdd(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let button = sender as? UIBarButtonItem, button == saveButton
        else {
            return
        }
        
        let image = photoImageView?.image
        let question = questionTextField.text
        let answer = answerTextField.text

        card = Card(image: image, question: question ?? "", answer: answer ?? "")
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        
    
    }
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let questionText = questionTextField.text ?? ""
        let answerText = answerTextField.text ?? ""
        saveButton.isEnabled = !questionText.isEmpty && !answerText.isEmpty
        
        if !questionText.isEmpty {
            self.navigationItem.title = questionText
        } else {
            self.navigationItem.title = "Add Card"
        }
        
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        questionTextField.resignFirstResponder()
        answerTextField.resignFirstResponder()
    }
    
    @objc func imageTapped(recognizer: UIGestureRecognizer) {
        print("image clicked")
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
            dismiss(animated: true, completion: nil)
            updateSaveButtonState()
        }
    }
        
}

