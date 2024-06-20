//
//  ShowBarDetailsViewController.swift
//  V.I.P Nashville
//
//  Created by Apple on 24/09/22.
//

import UIKit
import MapKit
import EventKitUI
import SDWebImage
import GoogleMobileAds

class ShowBarDetailsViewController : UIViewController {
  
    
    @IBOutlet weak var barAddress: UILabel!
    
    @IBOutlet weak var barRating: UILabel!
    @IBOutlet weak var barName: UILabel!
    @IBOutlet weak var barImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var openWebBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var barAbout: UILabel!
  
    @IBOutlet weak var bannerView: GADBannerView!
    var barModel : BarModel?
    override func viewDidLoad() {
        
        guard let barModel = barModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
    
        bannerView.adUnitID = "ca-app-pub-3746780957747656/3083376642"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
      
        openWebBtn.layer.cornerRadius = 18
        openWebBtn.dropShadow()
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        
        moreView.isUserInteractionEnabled = true
        moreView.layer.cornerRadius = 8
        moreView.dropShadow()
        
        moreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moreOptionClicked)))
        
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        mapView.delegate = self
        let coordinates = CLLocationCoordinate2D(latitude: -33.948612, longitude: 18.455107)
        
        if let image = barModel.image, !image.isEmpty {
            barImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, completed: .none)
        }
        barName.text = barModel.name ?? "Error"
        barRating.text = String(format: "%.1f", barModel.rating ?? 0.0)
        barAddress.text = barModel.address ?? "Error"
        barAbout.text = barModel.about ?? "Error"
        
        setCoordinatesOnMap(with: coordinates)
       
    }
    
    func setCoordinatesOnMap(with coordinates : CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
    
        let anonation = mapView.annotations
        mapView.removeAnnotations(anonation)
        
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(
                            center: coordinates,
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.02,
                                longitudeDelta: 0.02)),
                            animated: true)
        mapView.isScrollEnabled = false
        
        
        
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
        
    }
    
    @objc func moreOptionClicked(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
//        alert.addAction(UIAlertAction(title: "Share", style: .default,handler: { action in
//            //CODE
//        }))
        alert.addAction(UIAlertAction(title: "Bar Direction", style: .default,handler: { action in
            self.showOpenMapPopup()
        }))
      
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @IBAction func openWebClicked(_ sender: Any) {
        performSegue(withIdentifier: "openwebseg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openwebseg" {
            if let destination = segue.destination as? OpebWebViewController{
                destination.webUrl = barModel!.webUrl ?? "https://www.softment.in"
                destination.barName = barModel!.name ?? "VIP Nashville"
            }
        }
    }
    
    func showOpenMapPopup(){
        let alert = UIAlertController(title: "", message: "Open in maps", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { action in
            
            let coordinate = CLLocationCoordinate2DMake(self.barModel!.latitude!,self.barModel!.longitude!)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "Bar Location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }))
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { action in
                
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(self.barModel!.latitude!),\(self.barModel!.longitude!)&zoom=14&views=traffic&q=\(self.barModel!.latitude!),\(self.barModel!.longitude!)")!, options: [:], completionHandler: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}


extension ShowBarDetailsViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       
            self.showOpenMapPopup()
            
        
        
    }
}
