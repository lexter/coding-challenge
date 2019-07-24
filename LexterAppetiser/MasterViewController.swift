//
//  MasterViewController.swift
//  LexterAppetiser
//
//  Created by Lexter Labra on 24/07/2019.
//  Copyright © 2019 Lexter Labra. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MasterViewController: UIViewController {

    @IBOutlet var resultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .all

        // Do any additional setup after loading the view.
        configureTableDataSource()
    }
    
    func configureTableDataSource() {
        resultsTableView.register(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        
        resultsTableView.rowHeight = 100
        
        
        // This is for clarity only, don't use static dependencies
        let API = "https://itunes.apple.com/search?term=star&country=au&media=movie&all"
        
        URLSession.shared.dataTask(with: URL(string: API))
        
    }

}
