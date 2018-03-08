//
//  ViewController.swift
//  MemorablePlaces
//
//  Created by Athena on 3/7/18.
//  Copyright © 2018 Sheena Elveus. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var manager = CLLocationManager()
    @IBOutlet var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("loading...")
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(gestureRecognizer:)))
        uilpgr.minimumPressDuration = 2
        map.addGestureRecognizer(uilpgr)
        
        if activePlace == -1{
            
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        }else{
            if places.count > activePlace {
                if let name = places[activePlace]["name"] {
                    if let lat = places[activePlace]["lat"] {
                        if let lon = places[activePlace]["lon"] {
                            if let latitude = Double(lat) {
                                if let longitude = Double(lon){
                                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    let region = MKCoordinateRegion(center: coordinate, span: span)
                                    self.map.setRegion(region, animated: true)
                                    
                                    //make annotation for place
                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = coordinate
                                    
                                    annotation.title = String(name)
                                    print("printing activePlace => \(name)")
                                    self.map.addAnnotation(annotation)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
    }

    
    @objc func longPress(gestureRecognizer: UIGestureRecognizer){
        
        if gestureRecognizer.state == UIGestureRecognizerState.began{
        
            let touchPoint = gestureRecognizer.location(in: self.map)
            let coordinate = map.convert(touchPoint, toCoordinateFrom: self.map)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            var title = ""
            CLGeocoder().reverseGeocodeLocation(location, completionHandler:{
                (placemarks, error) in
                if error != nil{
                    print(error)
                }else{
                    
                    if let placemark = placemarks?[0] {
                        print("placemark not nil")
                        if placemark.subThoroughfare != nil {
                            print("subthoroughfare not nil")
                            title += placemark.subThoroughfare! + " "
                        }
                        
                        if placemark.thoroughfare != nil {
                            print("thoroughfare not nil")
                            title += placemark.thoroughfare!
                        }
                    }
                }
                
                if title == "" {
                    print("title was not set. setting it now!")
                    title = "Added \(NSDate())"
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = title
                self.map.addAnnotation(annotation)
                places.append(["name" : title, "lat" : "\(coordinate.latitude)", "lon":"\(coordinate.longitude)"])
                UserDefaults.standard.set(places, forKey: "placesList")
                print(places)
                
            })
            
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

