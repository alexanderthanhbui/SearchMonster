//
//  ViewController.swift
//  SearchMonster
//
//  Created by Hayne Park on 8/16/17.
//  Copyright © 2017 Alexander Bui. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBAction func searchTextFieldChange(_ sender: UITextField) {
        if Reachability.isConnectedToNetwork(){
            Networking.sharedInstance().getGooglePlaceInfo(searchTerm: searchTextField.text!) { (objects: [PlaceObject]?, error: NSError?) in
                if error == nil {
                    if let objects = objects {
                        self.placeObjects = objects
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        } else {
            showConnectionAlert()
        }
    }
    
    var placeObjects = [PlaceObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // hides rows when tableView is empty
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    // MARK: Keyboard Notifications |credit to
    // https://stackoverflow.com/questions/594181/making-a-uitableview-scroll-when-text-field-is-selected/41040630#41040630
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let placeObject = placeObjects[indexPath.row]
        
        cell.titleLabel.text = placeObject.name
        cell.addressLabel.text = placeObject.formattedAddress
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeObjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueToDetailTableView", sender: indexPath)
    }
    
    // alert for failed connection
    func showConnectionAlert() {
        let alert = UIAlertController(title: "Network Connection Error", message: "Internet Connection not Available! Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // pass placeobject to detailView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToDetailTableView") {
            let controller = segue.destination as! PlaceTableViewController
            let row = (sender as! IndexPath).row
            let place = placeObjects[row]
            controller.place = place
        }
    }

}

