//
//  TableViewController.swift
//  Listener
//
//  Created by Yu Sugawara on 2017/03/04.
//  Copyright © 2017年 Yu Sugawara. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    var strings = [String]()
    let listener = Listener(language: .japanese)

    @IBAction func startButtonClicked(_ sender: UIBarButtonItem) {
        listener.requestAuthorization(authorizationCompletion: { result in
            switch result {
            case .success:
                try! self.listener.startRecording()
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }, didChangeAvailability: { available in
            print("available: \(available)")
            self.navigationItem.prompt = available ? "true" : "false"
        }) { result in
            switch result {
            case .newString(let string):
                print("newString: \"\(string)\"")
                self.strings.insert(string, at: 0)
                
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)],
                                          with: .automatic)
            case .stop:
                print("stop")
            }
        }
    }

    @IBAction func stopButtonClicked(_ sender: UIBarButtonItem) {
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = strings[indexPath.row]

        return cell
    }
    
}
