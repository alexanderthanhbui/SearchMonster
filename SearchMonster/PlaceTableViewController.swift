//
//  PlaceTableViewController.swift
//  SearchMonster
//
//  Created by Hayne Park on 8/17/17.
//  Copyright © 2017 Alexander Bui. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import MapKit

class PlaceTableViewController: UITableViewController, GMSMapViewDelegate {
    
    var placePhoto: UIImage?
    var place: PlaceObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hides rows when tableView is empty
        tableView.tableFooterView = UIView()
        
        if let name = place?.name {
            navigationItem.title = name
        }
        
        // download photo from photo reference
        if let reference = place?.photoRef {
            if let url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?photoreference=\(reference)&maxwidth=1000&key=\(Constants.GoogleParameterValues.key)") {
                Networking.sharedInstance().getGooglePhoto(url: url, completionHandler: { (data: Data?, rsponse: URLResponse?, error: Error?) in
                    if error == nil {
                        if let imageData = data {
                            self.placePhoto = UIImage(data: imageData)
                        }
                    }
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() {
            // do nothing
        } else {
            showConnectionAlert()
        }
    }
    
    // alert for failed connection
    func showConnectionAlert() {
        let alert = UIAlertController(title: "Network Connection Error", message: "Internet Connection not Available! Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
            case 0:
                return 200
            case 1:
                return 95
            case 2:
                return 120
            case 3:
                return 66
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell0", for: indexPath) as! PlaceDetailFirstCustomTableViewCell
            
            DispatchQueue.main.async() {
                cell.placeImageView.image = self.placePhoto
                cell.placeImageView.contentMode = .scaleAspectFill
                tableView.reloadData()
            }

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! PlaceDetailSecondCustomTableViewCell
            
            if let name = place?.name {
                cell.placeNameLabel.text = name
            } else {
                cell.placeNameLabel.text = "This place has no name"
            }
            
            if let open = place?.open {
                if open == true {
                    cell.placeOpenLabel.text = "Open Now"
                    cell.placeOpenLabel.textColor = .green

                } else {
                    cell.placeOpenLabel.text = "Closed"
                    cell.placeOpenLabel.textColor = .red
                }
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! PlaceDetailThirdCustomTableViewCell
            
            cell.mapView.delegate = self
            
            // create marker and camera zoom for google maps
            if let lat = place?.latitude, let lon = place?.longitude {
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                marker.map = cell.mapView

                cell.mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 16)
            }
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! PlaceDetailFourthCustomTableViewCell
            
            if let address = place?.formattedAddress {
                cell.addressLabel.text = address
            }
            
            // Ceate button action in prototype cell
            cell.directionsButton.addTarget(self, action:#selector(directionButtonPressed(_:)), for:.touchUpInside)

            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

            return cell
        }
    }
    
    func directionButtonPressed(_ sender: AnyObject){
        // open in Apple Maps
        if let latitude = place?.latitude, let longitude = place?.longitude, let name = place?.name {
        let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }

}


