//
//  TypesTableViewController.swift
//  nearby
//
//  Created by Mitosis on 02/03/17.
//  Copyright © 2017 Mitosis. All rights reserved.
//
import UIKit

protocol TypesTableViewControllerDelegate: class {
    func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String])
}

class TypesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let possibleTypesDictionary = ["bakery":"Bakery", "bar":"Bar", "cafe":"Cafe", "grocery_or_supermarket":"Supermarket", "restaurant":"Restaurant"]
    var selectedTypes: [String]!
    weak var delegate: TypesTableViewControllerDelegate!
    var sortedKeys: [String] {
        return possibleTypesDictionary.keys.sorted()
    }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            
        }
    // MARK: - Actions
    @IBAction func donePressed(_ sender: AnyObject)
        {
        delegate?.typesController(self, didSelectTypes: selectedTypes)
       
    }
    
    // MARK: - Table view data source
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possibleTypesDictionary.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let key = sortedKeys[(indexPath as NSIndexPath).row]
        let type = possibleTypesDictionary[key]!
        cell.textLabel?.text = type
        cell.imageView?.image = UIImage(named: key)
        cell.accessoryType = (selectedTypes!).contains(key) ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let key = sortedKeys[(indexPath as NSIndexPath).row]
        if (selectedTypes!).contains(key) {
            selectedTypes = selectedTypes.filter({$0 != key})
        } else {
            selectedTypes.append(key)
        }
        
        tableView.reloadData()
    }
}

