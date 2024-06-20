//
//  AdminDashboardConroller.swift
//  V.I.P Nashville
//
//  Created by Vijay Rathore on 29/09/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import SDWebImage

class AdminDashboardConroller : UIViewController {
    
    @IBOutlet weak var no_bars_available: UIStackView!
    @IBOutlet weak var printersAlleyBtn: UIButton!
    @IBOutlet weak var broadwayBtn: UIButton!
    @IBOutlet weak var midtownBtn: UIButton!
    @IBOutlet weak var addBtn: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var barItems = Array<BarModel>()
    var cityBarItems = Array<BarModel>()
    var selectedCityID = 2
    let slideVC = AdminOverlayController()
    override func viewDidLoad() {
        profilePic.isUserInteractionEnabled = true
        profilePic.layer.cornerRadius = 12
        profilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profilePicClicked)))
        
        
        addBtn.isUserInteractionEnabled = true
        addBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addBtnClicked)))
        
        
        midtownBtn.layer.cornerRadius = 8
        midtownBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
        midtownBtn.layer.borderWidth = 1
        midtownBtn.backgroundColor = UIColor.white
        
        
        printersAlleyBtn.layer.cornerRadius = 8
        printersAlleyBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
        printersAlleyBtn.layer.borderWidth = 1
        printersAlleyBtn.backgroundColor = UIColor.white
        
        broadwayBtn.layer.cornerRadius = 8
        broadwayBtn.backgroundColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getAllBar()
        
    }
    
    @objc func profilePicClicked(){
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    func getAllBar() {
        ProgressHUDShow(text: "Loading...")
        Firestore.firestore().collection("Bars").order(by: "createDate",descending: true).addSnapshotListener { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.barItems.removeAll()
             
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let barModel = try? qdr.data(as: BarModel.self) {
                            self.barItems.append(barModel)
                        }
                    }
                }
                
             
                self.getDataFor(cityId: 2)
               
            }
        }
        
        
    }
    
    func getDataFor(cityId : Int) {
        
   
        self.cityBarItems.removeAll()
    
            for cityBarItem in barItems {
                if cityBarItem.cityId == cityId {
                    self.cityBarItems.append(cityBarItem)
                }
            }
        
        
        self.tableView.reloadData()
    }
    
    @objc func addBtnClicked(){
        
        performSegue(withIdentifier: "addbarseg", sender: nil)
    }
    
    @IBAction func midtownBtnClicked(_ sender: Any) {
                  broadwayBtn.layer.cornerRadius = 8
                 broadwayBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
                 broadwayBtn.layer.borderWidth = 1
                 broadwayBtn.backgroundColor = UIColor.white
                 broadwayBtn.setTitleColor(UIColor.black, for: .normal)
         
                 printersAlleyBtn.layer.cornerRadius = 8
                    printersAlleyBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
        printersAlleyBtn.layer.borderWidth = 1
        printersAlleyBtn.backgroundColor = UIColor.white
        printersAlleyBtn.setTitleColor(UIColor.black, for: .normal)
         
                midtownBtn.layer.cornerRadius = 8
                 midtownBtn.backgroundColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1)
                  midtownBtn.setTitleColor(UIColor.white, for: .normal)
        
        self.getDataFor(cityId: 1)
    }
    
    @IBAction func broadWayBtnClicked(_ sender: Any) {
        
        broadwayBtn.layer.cornerRadius = 8
        broadwayBtn.backgroundColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1)
        broadwayBtn.setTitleColor(UIColor.white, for: .normal)
        
        midtownBtn.layer.cornerRadius = 8
        midtownBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
        midtownBtn.layer.borderWidth = 1
        midtownBtn.backgroundColor = UIColor.white
        midtownBtn.setTitleColor(UIColor.black, for: .normal)


        printersAlleyBtn.layer.cornerRadius = 8
        printersAlleyBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
        printersAlleyBtn.layer.borderWidth = 1
        printersAlleyBtn.backgroundColor = UIColor.white
        printersAlleyBtn.setTitleColor(UIColor.black, for: .normal)
        
        self.getDataFor(cityId: 2)
    }
    
    @IBAction func printersAlleyBtnClicked(_ sender: Any) {
                midtownBtn.layer.cornerRadius = 8
                midtownBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
                midtownBtn.layer.borderWidth = 1
                midtownBtn.backgroundColor = UIColor.white
                midtownBtn.setTitleColor(UIColor.black, for: .normal)
        
                broadwayBtn.layer.cornerRadius = 8
                broadwayBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
                broadwayBtn.layer.borderWidth = 1
                broadwayBtn.backgroundColor = UIColor.white
                broadwayBtn.setTitleColor(UIColor.black, for: .normal)
        
                printersAlleyBtn.layer.cornerRadius = 8
        printersAlleyBtn.backgroundColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1)
        printersAlleyBtn.setTitleColor(UIColor.white, for: .normal)
        
        self.getDataFor(cityId: 3)
        
    }
    @objc func barClicked(value : MyGesture){
        performSegue(withIdentifier: "editbarseg", sender: value.barModel!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editbarseg" {
            if let destination = segue.destination as? EditBarViewController {
                if let barModel = sender as? BarModel {
                    destination.barModel = barModel
                }
         
            }
        }
    }
    
}

extension AdminDashboardConroller : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cityBarItems.count > 0 {
            self.no_bars_available.isHidden = true
        }
        else {
            self.no_bars_available.isHidden = false
        }
        return cityBarItems.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "barcell", for: indexPath) as? BarTableViewCell {
            
            cell.barImage.layer.cornerRadius = 8
            cell.nextBtn.layer.cornerRadius = 8
            cell.nextBtn.dropShadow()
            
            let barModel = cityBarItems[indexPath.row]
            
            if let image = barModel.image, !image.isEmpty {
                cell.barImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, completed: .none)
            }
            cell.barName.text = barModel.name ?? "Error"
            cell.barRating.text = String(format: "%.1f", barModel.rating ?? 0.0)
            cell.barAddress.text = barModel.address ?? "Error"
            cell.barDescription.text = barModel.about ?? "Error"
            cell.mView.isUserInteractionEnabled = true
            let myGest = MyGesture(target: self, action: #selector(barClicked(value: )))
            myGest.barModel = barModel
            cell.mView.addGestureRecognizer(myGest)
       
            return cell
        }
        
        return BarTableViewCell()
    }
 
}
extension AdminDashboardConroller : UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        
   

        return AdminPresentationController(presentedViewController: presented, presenting: presenting,adminVC: self)
       
 
    }
    
    
    

}

