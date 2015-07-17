//
//  EndpointSelectionViewController.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 27.06.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import UIKit

class EndpointSelectionViewController: UITableViewController {
    
    var didSelectEndpoint: ((endpoint: String) -> Void)?
    var endpoints = [Endpoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        endpoints = Configuration.endpoints()
        preferredContentSize = CGSizeMake(CGFloat(280), min(CGFloat(endpoints.count * 44), CGFloat(6*44 + 22)))
        tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return endpoints.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let endpoint = endpoints[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("EndpointCell") as! UITableViewCell
        cell.textLabel?.text = endpoint.name
        cell.detailTextLabel?.text = endpoint.url
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let endpoint = endpoints[indexPath.row]
        didSelectEndpoint?(endpoint: endpoint.url)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
