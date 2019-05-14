//
//  WebViewController.swift
//  BoutTime
//
//  Created by Luis Laborda on 5/13/19.
//  Copyright © 2019 Luis Laborda. All rights reserved.
//
// Resources:
// Creating a web view:
// https://www.hackingwithswift.com/read/4/2/creating-a-simple-browser-with-wkwebview

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var address: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: address) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    @IBAction func closeView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
