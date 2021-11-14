//
//  ViewController.swift
//  2gis
//
//  Created by Darkhan on 24.03.2021.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var userLocation = CLLocation()
    
    var followMe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        let lat:CLLocationDegrees = 37
        let long:CLLocationDegrees = -122
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        annotation.title = "Title"
        annotation.subtitle = "subtitle"
        
        mapView.addAnnotation(annotation)
        
        let latDelta:CLLocationDegrees = 0.01
        let longDelta:CLLocationDegrees = 0.01
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap))
        mapDragRecognizer.delegate = self
        mapView.addGestureRecognizer(mapDragRecognizer)
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction))
        uilpgr.minimumPressDuration = 2
        mapView.addGestureRecognizer(uilpgr)

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        if followMe {
            let latDelta:CLLocationDegrees = 0.01
            let longDelta:CLLocationDegrees = 0.01
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func buttonMe(_ sender: Any) {
        followMe = true
    }
    
    @objc func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizer.State.began) {
            followMe = false
        } else if (gestureRecognizer.state == UIGestureRecognizer.State.ended) {
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
               
       let location:CLLocation = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
       
       let meters:CLLocationDistance = location.distance(from: userLocation)
       distanceLabel.text = String(format: "Distance: %.2f m", meters)
       
       // Routing
       // 1
       let sourceLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
       
       let destinationLocation = CLLocationCoordinate2D(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
       
       // 2
       let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
       let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
       
       // 3
       let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
       let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
       
       // 4
       let directionRequest = MKDirections.Request()
       directionRequest.source = sourceMapItem
       directionRequest.destination = destinationMapItem
       directionRequest.transportType = .automobile
       
       // Calculate the direction
       let directions = MKDirections(request: directionRequest)
       
       // 5
       directions.calculate {
           (response, error) -> Void in
           
           guard let response = response else {
               if let error = error {
                   print("Error: \(error)")
               }
               
               return
           }
           
           
           let route = response.routes[0]
           self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
           
           let rect = route.polyline.boundingMapRect
           self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
       }
       
    }
           
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       let renderer = MKPolylineRenderer(overlay: overlay)
       renderer.strokeColor = UIColor.red
       renderer.lineWidth = 4.0
       
       return renderer
    }

    
    @objc func longPressAction(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        
        let newCoor: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let anotation = MKPointAnnotation()
        anotation.coordinate = newCoor
        anotation.title = "Title2"
        anotation.subtitle = "subtitle2"
       
        mapView.addAnnotation(anotation)
    }
    
    
}

