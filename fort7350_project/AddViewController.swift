//
//  ViewController.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-02.
//

import UIKit
import AVFoundation
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate,
                      UIPickerViewDataSource {
                         
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameValidationLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var numberValidationLabel: UILabel!
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var manufacturerValidationLabel: UILabel!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var qtyValidationLabel: UILabel!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryValidationLabel: UILabel!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var unitValidationLabel: UILabel!
    @IBOutlet weak var shelfTextField: UITextField!
    @IBOutlet weak var shelfValidationLabel: UILabel!
    @IBOutlet weak var binTextField: UITextField!
    @IBOutlet weak var binValidationLabel: UILabel!
    @IBOutlet weak var barcodeButton: UIButton!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var imagePickerController: UIImagePickerController!
    let pickerView:UIPickerView = UIPickerView()
    
    
    let context = AppDelegate.viewContext
    let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    var categories: [String]? = []
    let qtyItems = [Int](1...100)
    var shelfItems: [String]? = []
    var binItems: [Int32]? = []
    var plantStorageUnits: [String]? = []
    
    var segueID:String = "ShowAddBarcode"
    var returnSegueID:String = "ScanAdd"
    
    

    enum pickerTextField {
        case quantity
        case category
        case unit
        case shelf
        case bin
        case none
        
    }
    
    var selectedPickerTextField = pickerTextField.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        numberTextField.delegate = self
        manufacturerTextField.delegate = self
        
        setupPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        qtyTextField.inputView = pickerView
        categoryTextField.inputView = pickerView
        unitTextField.inputView = pickerView
        shelfTextField.inputView = pickerView
        binTextField.inputView = pickerView
        
        qtyTextField.delegate = self
        categoryTextField.delegate = self
        unitTextField.delegate = self
        shelfTextField.delegate = self
        binTextField.delegate = self
        
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library or camera.
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        photoImageView.isUserInteractionEnabled = true
        let imageTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(recognizer:)))
        imageTap.numberOfTapsRequired = 1
        photoImageView.addGestureRecognizer(imageTap)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Tap(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        barcodeLabel.text = "NO BARCODE ADDED"
        
        updateSaveButtonState()
        backgroundContext.parent = context
        
        populateCategoryField()
        populateLocationFields()
        
    }
    
    func getLocation(plant: String, storageUnit: String, shelf:String, bin:Int32) -> Location?{
        let request : NSFetchRequest<Location> = Location.fetchRequest()
        let predicate = NSPredicate(format: "SUBQUERY(shelves, $x, SUBQUERY($x.bins, $y, $y.bin = \(bin) && $x.name > 2005).@count > 0).@count > 0")
        request.predicate = predicate
        
        let locations = try? context.fetch(request)
        if !(locations?.isEmpty ?? true) {
            for location in locations!{
                if location.plant == plant && location.storageUnit == storageUnit {
                    return location
                }
            }
        }
        return nil
        
    }
    
    func populateCategoryField() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        let categoryRecords = try? context.fetch(request)
        if !(categoryRecords?.isEmpty ?? true) {
            for category in categoryRecords! {
                if let name = category.name {
                    categories?.append(name)
                }
            }
        } else {
            self.showAlert(withTitle: "No Categories!", message: "Please import from Utilities page." )
            
        }
        
    }
    
    func populateLocationFields() {
    
        let locationRequest : NSFetchRequest<Location> = Location.fetchRequest()
        locationRequest.sortDescriptors = [NSSortDescriptor(key: "plant", ascending: true),NSSortDescriptor(key: "storageUnit", ascending: true)]
        let locations = try? context.fetch(locationRequest)
        if !(locations?.isEmpty ?? true) {
            for location in locations! {
                if let plant = location.plant {
                    if let unit = location.storageUnit {
                        plantStorageUnits?.append(plant + "," + unit)
                        
                    }
                }
                
            }
        } else {
            self.showAlert(withTitle: "No Locations!", message: "Please import from Utilities page." )
        }
    }
    
    func populateShelfFields(locationFilter: String) {
    
        let locationFilters = locationFilter.split(separator: ",")
        let plant = String(locationFilters.first!)
        let unit = String(locationFilters.last!)
        let locationRequest : NSFetchRequest<Location> = Location.fetchRequest()
        locationRequest.predicate = NSPredicate(format:  "plant LIKE %@ AND storageUnit LIKE %@", plant, unit)
        locationRequest.sortDescriptors = [NSSortDescriptor(key: "plant", ascending: true),NSSortDescriptor(key: "storageUnit", ascending: true)]
        let locations = try? context.fetch(locationRequest)

        let shelfRequest : NSFetchRequest<Shelf> = Shelf.fetchRequest()
        shelfRequest.predicate = NSPredicate(format:  "location IN %@ ", locations!)
        shelfRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let shelves = try? context.fetch(shelfRequest)
    
        if !(shelves?.isEmpty ?? true){
            var found = Set<String>()
            shelfItems = []
            for shelf in shelves! {
                if !found.contains(shelf.name!){
                    shelfItems?.append(shelf.name!)
                    found.insert(shelf.name!)
                }
            }
        } else {
            self.showAlert(withTitle: "No Shelves!", message: "No shelves defined for this location" )
        }
    }
    
    func populateBinFields(locationFilter: String, shelfFilter: String) {
    
        let locationFilters = locationFilter.split(separator: ",")
        let plant = String(locationFilters.first!)
        let unit = String(locationFilters.last!)
        let locationRequest : NSFetchRequest<Location> = Location.fetchRequest()
        locationRequest.predicate = NSPredicate(format:  "plant LIKE %@ AND storageUnit LIKE %@", plant, unit)
        locationRequest.sortDescriptors = [NSSortDescriptor(key: "plant", ascending: true),NSSortDescriptor(key: "storageUnit", ascending: true)]
        let locations = try? context.fetch(locationRequest)

        if !(locations?.isEmpty ?? true) {
            let shelfRequest : NSFetchRequest<Shelf> = Shelf.fetchRequest()
            shelfRequest.predicate = NSPredicate(format:  "name LIKE %@ AND location IN %@ ", shelfFilter, locations!)
            shelfRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let shelves = try? context.fetch(shelfRequest)
        
            if !(shelves?.isEmpty ?? true) {
                let bins = shelves![0].bins?.sortedArray(using: [NSSortDescriptor(key: "bin", ascending: true)]) as? [Bin]
                
                binItems = []
                if !(bins?.isEmpty ?? true){
                    for bin in bins! {
                        binItems?.append(bin.bin)
                    }
                } else {
                    self.showAlert(withTitle: "No Bins!", message: "No bins defined for this shelf" )
                }
            } else {
                self.showAlert(withTitle: "No Shelves!", message: "No shelves defined for this location" )
            }
        } else {
            self.showAlert(withTitle: "No Locations!", message: "Please import from Utilities page." )
        }
    }
   
    func setupPickerView(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        qtyTextField.inputAccessoryView = toolBar
        categoryTextField.inputAccessoryView = toolBar
        unitTextField.inputAccessoryView = toolBar
        shelfTextField.inputAccessoryView = toolBar
        binTextField.inputAccessoryView = toolBar
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        numberTextField.resignFirstResponder()
        manufacturerTextField.resignFirstResponder()
        qtyTextField.resignFirstResponder()
    }
    
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true) {
        }
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
        switch textField {
        case qtyTextField:
            selectedPickerTextField = .quantity
            if let index = Int(qtyTextField.text!) {
                self.pickerView.selectRow(index + qtyItems.startIndex, inComponent: 0, animated: true)
            } else {
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        case categoryTextField:
            selectedPickerTextField = .category
            if let index = categories!.firstIndex(of: categoryTextField.text ?? "") {
                self.pickerView.selectRow(index, inComponent: 0, animated: true)
            } else {
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        case unitTextField:
            selectedPickerTextField = .unit
            if let index = plantStorageUnits!.firstIndex(of: unitTextField.text ?? "") {
                self.pickerView.selectRow(index, inComponent: 0, animated: true)
            } else {
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        case shelfTextField:
            selectedPickerTextField = .shelf
            if let index = Int(shelfTextField.text!) {
                self.pickerView.selectRow(index + shelfItems!.startIndex, inComponent: 0, animated: true)
            } else {
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        case binTextField:
            selectedPickerTextField = .bin
            if let index = Int(binTextField.text!) {
                self.pickerView.selectRow(index + binItems!.startIndex, inComponent: 0, animated: true)
            } else {
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        default:
            selectedPickerTextField = .none
        }
        
        pickerView.reloadAllComponents()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        switch textField {
        case nameTextField:
            hideValidationLabel(nameValidationLabel)
        case numberTextField:
            hideValidationLabel(numberValidationLabel)
        case manufacturerTextField:
            hideValidationLabel(manufacturerValidationLabel)
        case qtyTextField:
            hideValidationLabel(qtyValidationLabel)
        case categoryTextField:
            hideValidationLabel(categoryValidationLabel)
        case unitTextField:
            hideValidationLabel(unitValidationLabel)
            
        case shelfTextField:
            hideValidationLabel(shelfValidationLabel)
        case binTextField:
            hideValidationLabel(binValidationLabel)
        default:
            selectedPickerTextField = .none
        }
            
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case nameTextField:
                // Validate Text Field
                let (valid, message) = validate(textField)

                if valid {
                    numberTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(nameValidationLabel, message: message ?? "")
                }
            case numberTextField:
                // Validate Text Field
                let (valid, message) = validate(textField)

                if valid {
                    manufacturerTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(numberValidationLabel, message: message ?? "")
                }
            case manufacturerTextField:
                // Validate Text Field
                let (valid, message) = validate(textField)

                if valid {
                    qtyTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(manufacturerValidationLabel, message: message ?? "")
                }
            case qtyTextField:
                // Validate Text Field
                let (valid, message) = validate(textField)

                if !valid {
                    displayValidationLabel(qtyValidationLabel, message: message ?? "")
                }
            default:
                    qtyTextField.resignFirstResponder()
        }

            return true
        
    }
    
    func displayValidationLabel( _ label: UILabel, message: String){
        label.text = message
        UIView.animate(withDuration: 0.25, animations: { label.isHidden = false
        })
    }
    
    func hideValidationLabel( _ label: UILabel){
        UIView.animate(withDuration: 0.25, animations: { label.isHidden = true
        })
    }
    
    
    func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }

        if textField == qtyTextField && text.count > 0 {
            return (text.isInt, "Quantity must be an integer")
        }

        return (text.count > 0, "This field cannot be empty.")
    }
    
    func validateTextField(textField: UITextField) -> Bool {
        switch textField {
            case nameTextField:
                // Validate Text Field
                let (valid, message) = validate(textField)

                if valid {
                    numberTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(nameValidationLabel, message: message ?? "")
                }
                return valid
            case numberTextField:
                // Validate Text Field
                let (valid, message) = validate(textField)

                if valid {
                    manufacturerTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(numberValidationLabel, message: message ?? "")
                }
                return valid
            case manufacturerTextField:
                // Validate Text Field
                let (valid, message) = validate(textField)

                if valid {
                    qtyTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(manufacturerValidationLabel, message: message ?? "")
                }
                return valid
            default:
                return false
        }
        
    }
    
    func validateAll() -> Bool {
        var allValid:Bool = true
        var (valid, message) = validate(binTextField)
        if !valid{
            binTextField.becomeFirstResponder()
            allValid = false
            displayValidationLabel(binValidationLabel, message: message ?? "")
        }

        (valid,message) = validate(shelfTextField)
        if !valid{
            shelfTextField.becomeFirstResponder()
            allValid = false
            displayValidationLabel(shelfValidationLabel, message: message ?? "")
        }


        (valid, message) = validate(unitTextField)
        if !valid{
            shelfTextField.becomeFirstResponder()
            allValid = false
            displayValidationLabel(binValidationLabel, message: message ?? "")
        }
        
        (valid, message) = validate(categoryTextField)
        if !valid{
            categoryTextField.becomeFirstResponder()
            allValid = false
            displayValidationLabel(categoryValidationLabel, message: message ?? "")
        }
        
        (valid, message) = validate(qtyTextField)
        if !valid{
            allValid = false
            displayValidationLabel(qtyValidationLabel, message: message ?? "")
        }
        
        (valid, message) = validate(nameTextField)
        if !valid{
            allValid = false
            displayValidationLabel(nameValidationLabel, message: message ?? "")
        }
        
        (valid, message) = validate(numberTextField)
        if !valid{
            allValid = false
            displayValidationLabel(numberValidationLabel, message: message ?? "")
        }

        (valid, message) = validate(manufacturerTextField)
        if !valid{
            allValid = false
            displayValidationLabel(manufacturerValidationLabel, message: message ?? "")
        }
        return allValid
    }

    @objc func Tap(_ sender: Any) {
        nameTextField.resignFirstResponder()
        numberTextField.resignFirstResponder()
        manufacturerTextField.resignFirstResponder()
        
    }


    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let nameText = nameTextField.text ?? ""
        let numberText = numberTextField.text ?? ""
        let manufacturerText = manufacturerTextField.text ?? ""
        let qtyText = qtyTextField.text ?? ""
        
        saveButton.isEnabled = !nameText.isEmpty && !numberText.isEmpty && !manufacturerText.isEmpty && !qtyText.isEmpty
    }

    //MARK: UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedPickerTextField{
        case .quantity:
            return qtyItems.count
        case .category:
            return categories?.count ?? 0
        case .unit:
            return plantStorageUnits?.count ?? 0
        case .shelf:
            return shelfItems?.count ?? 0
        case .bin:
            return binItems?.count ?? 0
        default:
            return 0
        }
    
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row:Int, forComponent component:Int) -> String? {
        switch selectedPickerTextField{
        case .quantity:
            return String(qtyItems[row])
        case .category:
            return categories?[row] ?? ""
        case .unit:
            return plantStorageUnits?[row] ?? ""
        case .shelf:
            return String(shelfItems?[row] ?? "")
        case .bin:
            return String((binItems?[row])!)
        default:
            return ""
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selectedPickerTextField{
        case .quantity:
            qtyTextField.text = String(qtyItems[row])
        case .category:
            if let count = categories?.count{
                if count > row {
                    categoryTextField.text = String(categories?[row] ?? "")
                }
            }
        case .unit:
            if let count = plantStorageUnits?.count{
                if count > row {
                    unitTextField.text = String(plantStorageUnits?[row] ?? "")
                    populateShelfFields(locationFilter: unitTextField.text ?? "")
                }
            }
        case .shelf:
            if let count = shelfItems?.count{
                if count > row {
                    shelfTextField.text = String(shelfItems?[row] ?? "")
                    populateBinFields(locationFilter: unitTextField.text ?? "", shelfFilter:shelfTextField.text ?? "")
                }
            }
        case .bin:
            if let count = binItems?.count{
                if count > row {
                    binTextField.text = String(binItems?[row] ?? 0)
                }
            }
        default:
            print("not found")
        }
        
    }
    
    @objc func action() {
        view.endEditing(true)
        switch selectedPickerTextField {
            case .quantity:
                // Validate Text Field
                let (valid, message) = validate(qtyTextField)

                if valid {
                    categoryTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(qtyValidationLabel, message: message ?? "")
                }
            case .category:
                // Validate Text Field
                let (valid, message) = validate(categoryTextField)

                if valid {
                    unitTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(categoryValidationLabel, message: message ?? "")
                }
            case .unit:
                // Validate Text Field
                let (valid, message) = validate(unitTextField)

                if valid {
                    shelfTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(unitValidationLabel, message: message ?? "")
                }
            case .shelf:
                // Validate Text Field
                let (valid, message) = validate(shelfTextField)

                if valid {
                    binTextField.becomeFirstResponder()
                } else {
                    displayValidationLabel(shelfValidationLabel, message: message ?? "")
                }
            case .bin:
                // Validate Text Field
                let (valid, message) = validate(binTextField)

                if !valid {
                    displayValidationLabel(binValidationLabel, message: message ?? "")
                }
            default:
                qtyTextField.resignFirstResponder()
                categoryTextField.resignFirstResponder()
                unitTextField.resignFirstResponder()
                shelfTextField.resignFirstResponder()
                binTextField.resignFirstResponder()
        }
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(recognizer: UIGestureRecognizer) {
    
        print("image clicked")

        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.openGallery()
        }))

        self.present(alert, animated: true, completion: nil)
              

    }
    
    func openCamera(){
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)

        } else {
            let alert = UIAlertController(title: "Warning", message: "Camera not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
        
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
            dismiss(animated: true, completion: nil)
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let button = sender as? UIBarButtonItem, button == saveButton
        else {
            return true
        }
        
        if validateAll() {
            return true
        }
        
        return false
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let button = sender as? UIBarButtonItem, button == saveButton
        else {
            if segue.identifier == segueID {
                let barcodeVC = segue.destination as! BarcodeViewController
                barcodeVC.modalPresentationStyle = .fullScreen
                barcodeVC.addBarcode = true
            }
            return
        }
         
        nameTextField.resignFirstResponder()
        numberTextField.resignFirstResponder()
        manufacturerTextField.resignFirstResponder()
 
        let name = nameTextField.text
        let locationArray = unitTextField.text?.components(separatedBy: ",")
        let imageData = (photoImageView.image?.pngData())!
        let plant = String((locationArray?[0]) ?? "")
        let storageUnit = String((locationArray?[1]) ?? "")
        let manufacturer = manufacturerTextField.text ?? ""
        let partNumber = numberTextField.text ?? ""
        let quantity = Int16(qtyTextField.text ?? "0")!
        let barcode = barcodeLabel.text ?? ""
        let category = categoryTextField.text ?? ""
        let shelf = shelfTextField.text ?? ""
        let bin = Int(binTextField.text ?? "0")!
        
        Part.addPart(name: name!, manufacturer: manufacturer, partNumber: partNumber, image: imageData, quantity: quantity, barcode: barcode, plant: plant, unit: storageUnit, shelf: shelf, bin: bin, category: category)
        
        nameTextField.text = ""
        unitTextField.text = ""
        photoImageView.image = UIImage(contentsOfFile: "no_image")
        manufacturerTextField.text = ""
        numberTextField.text = ""
        qtyTextField.text = ""
        barcodeLabel.text = "NO BARCODE ADDED"
        categoryTextField.text = ""
        shelfTextField.text = ""
        binTextField.text = ""
            
    }
        
    
    @IBAction func unwindToAddPart(segue: UIStoryboardSegue){
        guard let sourceVC = segue.source as? BarcodeViewController else { return }
            barcodeLabel.text = sourceVC.getBarcode()
        
    }

}

