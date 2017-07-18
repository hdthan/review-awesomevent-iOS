//
//  MapViewController.swift
//  aEvents
//
//  Created by jenkin on 2/10/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import GoogleMaps

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet fileprivate weak var mapView: GMSMapView!

    var locationName: String?
    var longitude: Double?
    var latitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadMapView()
    }
    
    func loadMapView(){
        guard locationName != nil && longitude != nil && latitude != nil else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 15.0)
        mapView.camera = camera
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        marker.title = locationName
        marker.map = mapView as GMSMapView
    }
}
