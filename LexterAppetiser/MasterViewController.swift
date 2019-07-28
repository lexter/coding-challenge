//
//  MasterViewController.swift
//  LexterAppetiser
//
//  Created by Lexter Labra on 24/07/2019.
//  Copyright © 2019 Lexter Labra. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?

    var detailViewController: DetailViewController? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var tracks: [Track] = []
    var term = ""
    var selectedTrack: Track?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureSearchController()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        if let trackId = UserDefaults.standard.value(forKey: "selectedTrackId") as? Int64 {
            self.selectedTrack = Track.fetchWithPredicate(NSPredicate(format: "trackId == \(trackId)"), context: self.context).first
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
        
        self.tracks = Track.fetch(predicate: nil, sortDescriptors: [["key": "trackName", "ascending": "true"]], context: self.context)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//            let object = self.tracks[indexPath.row]
//                self.selectedTrack = object
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.track = self.selectedTrack!
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let event = self.tracks[indexPath.row]
        configureCell(cell, withEvent: event)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTrack = self.tracks[indexPath.row]
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func configureCell(_ cell: TrackCell, withEvent event: Track) {
        DispatchQueue.main.async {
            cell.cellData = event
            cell.configure()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print(UserDefaults.standard.value(forKey: "lastActive"))
        if let lastActive = UserDefaults.standard.value(forKey: "lastActive") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd HH:mm"
            let dateStr = dateFormatter.string(from: lastActive as! Date)
            return dateStr
        }
        return nil
    }
}

// MARK: - Extensions

extension MasterViewController: UISearchResultsUpdating {
    
    func configureSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search for a movie"
        navigationItem.searchController = search
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.term = text
            self.executeSearch(self.term, completion: { [unowned self] results in
                self.persistSearchResults(results)
            })
        }
    }
}

// MARK: - Extension for HTTP Request.
extension MasterViewController {
    
    func executeSearch(_ term: String, completion: @escaping (_ results: [[String: Any]]) -> Void) {
        let baseURL = "https://itunes.apple.com/search?term=\(term)&country=au&media=movie&all"
        self.defaultSession.dataTask(with: URL(string: baseURL)!) { (data, response, error) in
            guard error == nil else {
                print("HTTP ERROR ---> \(error!)")
                completion([])
                return
            }
            do {
                let parsedJSON = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                let results = parsedJSON["results"]
                completion(results as! [[String: Any]])
            }
            catch let e {
                print("ERROR PARSING ---> \(e)")
                completion([])
            }
            
        }.resume()
    }
    
    /// Maps the serach results into local storage.
    /// - param results - Array of Dictionaries
    func persistSearchResults(_ results: [[String: Any]]) {
        DispatchQueue.main.async { [unowned self] in
            for item in results {
                let trackId = item["trackId"] as! Int64
                let t = (Track.fetchObject(predicate: NSPredicate(format: "trackId == \(trackId)"), context: self.context) ?? Track.createInContext(self.context))
                t.mapData(item)
                
                /// If the localArtwork is already downloaded, just return immediately.
                guard t.localArtworkPath == nil else { return }
                
                if let url = URL(string: t.artworkUrl100!) {
                    
                    var filename = url.pathComponents.last!
                    let ext = filename.components(separatedBy: ".").last!
                    
                    self.defaultSession.dataTask(with: url) { (data, resp, error) in
                        
                        guard error == nil else {
                            t.isDownloadingArtwork = false
                            return
                        }
                        
                        let tempDir = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
                        filename = "\(UUID().uuidString).\(ext)"
                        let targetURL = tempDir.appendingPathComponent(filename)
                        t.localArtworkPath = filename
                        t.isDownloadingArtwork = true
                        
                        do {
                            try data!.write(to: targetURL)
                        }
                        catch let e {
                            print(e)
                        }
                        
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        
                    }.resume()
                } // END OF: if let url = URL(string: t.artworkUrl100!) {
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.tracks = Track.fetch(predicate: self.term.count > 0 ? NSPredicate(format: "trackName CONTAINS[cd] %@", self.term) : nil, sortDescriptors: [["key": "trackName", "ascending": "true"]], context: self.context)
            
            self.tableView.reloadData()
        }
    }
    
}
