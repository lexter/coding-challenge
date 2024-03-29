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
    
    /// Default URLSession instance for HTTP requests.
    let defaultSession = URLSession(configuration: .default)
    
    /// Stores URLSessionDataTask instances that downloads the artworks.
    var dataTasks: [URLSessionDataTask] = []

    var detailViewController: DetailViewController? = nil
    
    /// An NSManagedOnbjectContext reference from the AppDelegate.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /// Stores the tracks for table rendering
    var tracks: [Track] = []
    
    /// Search term
    var term = ""
    
    /// Holds a referece to selected task in the list.
    var selectedTrack: Track?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Movies"
        
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
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.track = self.selectedTrack!
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
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
        let track = self.tracks[indexPath.row]
        configureCell(cell, withTrack: track)
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

    func configureCell(_ cell: TrackCell, withTrack track: Track) {
        DispatchQueue.main.async {
            cell.cellData = track
            cell.defaultSession = self.defaultSession
            cell.configure()
            if let task = cell.downloadArtworkIfNeeded() {
                self.dataTasks.append(task)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let lastActive = UserDefaults.standard.value(forKey: "lastActive") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd HH:mm"
            let dateStr = dateFormatter.string(from: lastActive as! Date)
            return "Last Active - \(dateStr)"
        }
        return nil
    }
}

// MARK: - Extensions

extension MasterViewController: UISearchResultsUpdating {
    
    /// Configure the Search Controller
    func configureSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.hidesNavigationBarDuringPresentation = false
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
    
    /// Performs the call to HTTP search.
    /// - Parameter term: Search keyword
    /// - Parameter completion: A completion block accepting results parameters.
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
    /// - Parameter results: Array of Dictionaries
    func persistSearchResults(_ results: [[String: Any]]) {
        DispatchQueue.main.async { [unowned self] in
            
            for task in self.dataTasks where task.state == .running || task.state == .suspended {
                task.cancel()
            }
            
            self.dataTasks.removeAll()
            
            for item in results {
                let trackId = item["trackId"] as! Int64
                let t = (Track.fetchObject(predicate: NSPredicate(format: "trackId == \(trackId)"), context: self.context) ?? Track.createInContext(self.context))
                t.mapData(item)
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.tracks = Track.fetch(predicate: self.term.count > 0 ? NSPredicate(format: "trackName CONTAINS[cd] %@", self.term) : nil, sortDescriptors: [["key": "trackName", "ascending": "true"]], context: self.context)
            
            self.tableView.reloadData()
        }
    }
    
}
