//
//  AddBarViewController.swift
//  V.I.P Nashville
//
//  Created by Vijay Rathore on 29/09/22.
//

import UIKit
import UIKit
import CropViewController
import FirebaseFirestoreSwift
import Firebase
import FirebaseFirestore


class AddBarViewController : UIViewController {
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var selectCity: UITextField!
  
    @IBOutlet weak var barNameTF: UITextField!
    @IBOutlet weak var barImage: UIImageView!
    @IBOutlet weak var barRatingTF: UITextField!
    @IBOutlet weak var aboutBarTV: UITextView!
    @IBOutlet weak var webUrlTF: UITextField!
    @IBOutlet weak var addBarBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barAddress: UITextField!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    var places : [Place] = []
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var isLocationSelected : Bool = false
    var barId = ""
    var downloadURL  = ""
    var cityId = 2
    override func viewDidLoad() {
        
        
        barImage.layer.cornerRadius = 8
        barImage.isUserInteractionEnabled = true
        barImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        barNameTF.layer.cornerRadius = 8
        barNameTF.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        barNameTF.layer.borderWidth = 1.4
        barNameTF.setLeftPaddingPoints(12)
        barNameTF.setRightPaddingPoints(12)
        barNameTF.delegate = self
        
        selectCity.layer.cornerRadius = 8
        selectCity.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        selectCity.layer.borderWidth = 1.4
        selectCity.setLeftPaddingPoints(12)
        selectCity.setRightPaddingPoints(12)
        selectCity.delegate = self
        selectCity.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectCityClicked)))
        
        barRatingTF.layer.cornerRadius = 8
        barRatingTF.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        barRatingTF.layer.borderWidth = 1.4
        barRatingTF.setLeftPaddingPoints(12)
        barRatingTF.setRightPaddingPoints(12)
        barRatingTF.delegate = self
        
        webUrlTF.layer.cornerRadius = 8
        webUrlTF.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        webUrlTF.layer.borderWidth = 1.4
        webUrlTF.setLeftPaddingPoints(12)
        webUrlTF.setRightPaddingPoints(12)
        webUrlTF.delegate = self
        
        barAddress.layer.cornerRadius = 8
        barAddress.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        barAddress.layer.borderWidth = 1.4
        barAddress.setLeftPaddingPoints(12)
        barAddress.setRightPaddingPoints(12)
        barAddress.delegate = self
        barAddress.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.contentInsetAdjustmentBehavior = .never
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44
        
        aboutBarTV.contentInset = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 6)
        aboutBarTV.layer.cornerRadius = 8
        aboutBarTV.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        aboutBarTV.layer.borderWidth = 1.4
        aboutBarTV.delegate = self
        
        addBarBtn.isUserInteractionEnabled = true
        addBarBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func selectCityClicked(){
        let alert = UIAlertController(title: "Select City", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Midtown", style: .default,handler: { action in
            self.selectCity.text = "Midtown"
            self.cityId = 1
        }))
        alert.addAction(UIAlertAction(title: "Broadway", style: .default,handler: { action in
            self.selectCity.text = "Broadway"
            self.cityId = 2
        }))
        alert.addAction(UIAlertAction(title: "Printers Alley", style: .default,handler: { action in
            self.selectCity.text = "Printers Alley"
            self.cityId = 3
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
    @objc func textFieldDidChange(textField : UITextField){
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.places.removeAll()
            
            self.tableView.reloadData()
            return
        }
        
        
        GooglePlacesManager.shared.findPlaces(query: query ) { result in
            switch result {
            case .success(let places) :
                self.places = places
                print(self.places)
                self.tableView.reloadData()
                break
            case .failure(let error) :
                print(error)
            }
        }
    }
    @objc func locationCellClicked(myGesture : MyGesture){
        tableView.isHidden = true
        view.endEditing(true)
        
        
        let place = places[myGesture.index]
        barAddress.text = place.name ?? ""
        
        self.isLocationSelected = true
        
        
        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            switch result {
            case .success(let coordinates) :
                self.latitude = coordinates.latitude
                self.longitude = coordinates.longitude
                
                break
            case .failure(let error) :
                print(error)
                
            }
        }
    }
    
    @objc func imageViewClicked(){
        chooseImageFromPhotoLibrary()
    }
    
    func chooseImageFromPhotoLibrary(){
        
        let image = UIImagePickerController()
        image.delegate = self
        image.title = title
        image.sourceType = .photoLibrary
        self.present(image,animated: true)
    }
    
    
    public func updateTableViewHeight(){
        
        self.tableHeight.constant = self.tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func addBarClicked(_ sender: Any) {
        
        if downloadURL == "" {
            self.showSnack(messages: "Upload Bar Image")
            return
        }
        let sName = barNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sAddress = barAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sRating = barRatingTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sAbout = aboutBarTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sUrl = webUrlTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sName == "" {
            self.showSnack(messages: "Enter Bar Name")
            return
        }
        if sAddress == "" && !isLocationSelected {
            self.showSnack(messages: "Enter Bar Address")
            return
        }
        if sRating == "" {
            self.showSnack(messages: "Enter Bar Rating")
            return
        }
        if sAbout == "" {
            self.showSnack(messages: "Enter About Bar")
            return
        }
        if sUrl == "" {
            self.showSnack(messages: "Enter Bar URL")
            return
        }
        else {
            self.ProgressHUDShow(text: "Adding...")
            let barModel = BarModel()
            barModel.id = self.barId
            barModel.name = sName
            barModel.address = sAddress
            barModel.image = downloadURL
            barModel.about = sAbout
            barModel.rating = Double(sRating ?? "0.0")
            barModel.cityId = cityId
            barModel.webUrl = sUrl
            barModel.latitude = latitude
            barModel.longitude = longitude
            barModel.createDate = Date()
            
            try? Firestore.firestore().collection("Bars").document(barId).setData(from: barModel,completion: { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showSnack(messages: "Added")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            })
        }
    }
    
}
extension AddBarViewController : UITextViewDelegate, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == selectCity {
            return false
        }
        return true
    }
}

extension AddBarViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count > 0 {
            tableView.isHidden = false
        }
        else {
            tableView.isHidden = true
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "placescell", for: indexPath) as? Google_Places_Cell {
            
            
            cell.name.text = places[indexPath.row].name ?? "Something Went Wrong"
            cell.mView.isUserInteractionEnabled = true
            
            let myGesture = MyGesture(target: self, action: #selector(locationCellClicked(myGesture:)))
            myGesture.index = indexPath.row
            cell.mView.addGestureRecognizer(myGesture)
            
            let totalRow = tableView.numberOfRows(inSection: indexPath.section)
            if(indexPath.row == totalRow - 1)
            {
                DispatchQueue.main.async {
                    self.updateTableViewHeight()
                }
            }
            return cell
        }
        
        return Google_Places_Cell()
    }
    
    
    
}


extension AddBarViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            
            
            
            self.dismiss(animated: true) {
                
                let cropViewController = CropViewController(image: editedImage)
                
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 5  , height: 3)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true, completion: nil)
            }
            
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        self.ProgressHUDShow(text: "Uploading...")
        
        barImage.image = image
        
        
        barId = Firestore.firestore().collection("Bars").document().documentID
        uploadImageOnFirebase(barId: barId){ downloadURL in
            
            self.ProgressHUDHide()
            self.downloadURL = downloadURL
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(barId : String,completion : @escaping (String) -> Void ) {
        
        let storage = Storage.storage().reference().child("BarImages").child(barId).child("\(barId).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        
        
        uploadData = (self.barImage.image?.jpegData(compressionQuality: 0.5))!
        
        
        
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error == nil {
                storage.downloadURL { (url, error) in
                    if error == nil {
                        downloadUrl = url!.absoluteString
                    }
                    completion(downloadUrl)
                    
                }
            }
            else {
                print(error!.localizedDescription)
                completion(downloadUrl)
            }
            
        }
    }
}


