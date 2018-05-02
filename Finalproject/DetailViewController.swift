//
//  DetailViewController.swift
//  Final project
//
//  Created by Yufan Chen on 2018/4/23.
//  Copyright © 2018年 Yufan Chen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var duedate: UILabel!
    var storep: Float?
    var storec: String?
    var stored: Date?
    var currentIndex: IndexPath?
    var isChanged = false
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.content!.description
            }
            if let due = duedate {
                due.text = detail.deadline!.description(with: NSLocale.current)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let controller = segue.destination as! EditViewController
            if let detail = detailItem {
                controller.stored = detail.deadline
                controller.storec = detail.content!
                controller.storep = detail.priority
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        detailDescriptionLabel.lineBreakMode = .byWordWrapping
        detailDescriptionLabel.numberOfLines = 0;
        
        duedate.lineBreakMode = .byWordWrapping
        duedate.numberOfLines = 0;
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    @IBAction func myUnwindAction( _ unwindSegue: UIStoryboardSegue){
        if let vc = unwindSegue.source as? EditViewController{
            storep = vc.priority.value
            stored = vc.date.date
            storec = vc.content.text
            detailDescriptionLabel.text = storec
            duedate.text = stored?.description
            isChanged = true
        }
    }



}

