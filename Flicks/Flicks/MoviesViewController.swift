//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Micah Peoples on 1/30/17.
//  Copyright © 2017 micah. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var networkIcon: UIImageView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let baseURL = "https://image.tmdb.org/t/p/w500"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    var movies : [NSDictionary]?
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        self.networkErrorView.isHidden = true;
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.networkErrorView.addGestureRecognizer(gestureRecognizer)
        
        let icon = UIImage(named: "caution-sign.png")
        self.networkIcon.image = icon
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(self.refreshControl, at: 0)
        
        update()
        
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            //self.networkErrorView.isHidden = true
            update()
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        update()
    }
    
    func update() {
        // Network Stuff
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.networkErrorView.isHidden = true
                    print(dataDictionary)
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                self.networkErrorView.isHidden = false
                print ("Netowrk Error")
                MBProgressHUD.hide(for: self.view, animated: true)
                //self.networkErrorView.click
            }
        }
        task.resume()
    }
    
    func hide(view: UIView) {
        view.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let imageURL = NSURL(string: self.baseURL + posterPath)
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        
        cell.posterView.setImageWith(imageURL as! URL)
        
        cell.title.text = title
        cell.overview.text = overview
        print ("row \(indexPath.row)")
        return cell
    }

}
