//
//  MasterViewController1.swift
//  LexterAppetiser
//
//  Created by Lexter Labra on 25/07/2019.
//  Copyright © 2019 Lexter Labra. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

struct TrackModel {
    var title: String
    var genre: String
    
    static func mapData(_ data: [String: Any]) -> TrackModel {
        return TrackModel(title: data["title"] as! String,
                          genre: data["genre"] as! String)
    }
}

class MasterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    var selectedItem: TrackModel?
    
    var objects = [
        TrackModel.mapData(["title": "Track 1" as Any, "genre": "Family"]),
        TrackModel.mapData(["title": "Track 2" as Any, "genre": "Comedy"]),
        TrackModel.mapData(["title": "Track 3" as Any, "genre": "Suspense"]),
        TrackModel.mapData(["title": "Track 4" as Any, "genre": "Family"]),
        TrackModel.mapData(["title": "Track 5" as Any, "genre": "Kids"])
    ]
    
    var observableObjs: Observable<[TrackModel]>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        self.observableObjs = Observable.from(optional: self.objects)
            
        observableObjs.bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { ( row, data, cell) in
            cell.textLabel?.text = data.title
            cell.detailTextLabel?.text = data.genre
        }
        .disposed(by: self.disposeBag)
        
        self.tableView.rx
            .modelSelected(TrackModel.self)
            .asDriver()
            .drive(onNext: { track in
                self.selectedItem = track
                self.performSegue(withIdentifier: "showDetail", sender: self)
            })
            .disposed(by: self.disposeBag)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let nav = segue.destination as? UINavigationController {
            if let detail = nav.topViewController as? DetailViewController {
                detail.track = self.selectedItem
            }
        }
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
//        self.obser objects.append(TrackModel.mapData(["title": "Track 6" as Any, "genre": "Comedy"]))
    }
 

}
