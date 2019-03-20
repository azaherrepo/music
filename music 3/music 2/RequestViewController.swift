//
//  RequestViewController.swift
//  music 2
//
//  Created by Ayman Zaher on 2019-03-17.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit

class RequestViewController: UIViewController {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var albumText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    func checkaConnection() -> Bool {
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
        switch Network.reachability.status {
        case .unreachable:
            return false
        case .wwan:
            return true
        case .wifi:
            return true
        }
        
    }
    
    @IBAction func requestBttn(_ sender: Any) {
        if checkaConnection() == true {
        let url = URL(string: "http://azaher2003-001-site1.1tempurl.com/service.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = ("name=\(nameText.text!)&album=\(albumText.text!)&artist=\(artistText.text!)")
        request.httpBody = "\(postString)".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
        navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "No Connection", message: "Could not send request pleas check your internet connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
