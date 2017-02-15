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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layoutButton: UIBarButtonItem!
    @IBOutlet weak var networkIcon: UIImageView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let baseURL = "https://image.tmdb.org/t/p/w500"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    var movies : [NSDictionary]?
    let refreshControl = UIRefreshControl()
    var endpoint = "now_playing"
    var layoutString = "table"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.isHidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        self.networkErrorView.isHidden = true;
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.networkErrorView.addGestureRecognizer(gestureRecognizer)
        
        let icon = UIImage(named: "caution-sign.png")
        self.networkIcon.image = icon
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(self.refreshControl, at: 0)
        update()
        
    }
    
    func collectionView(_ collectionView:UICollectionView, layout:UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
    }
    
    func collectionView(_ collectionView:UICollectionView, layout:UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0; // top, left, bottom, right
    }
    
    func collectionView(_ collectionView:UICollectionView, layout:UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0; // top, left, bottom, right
    }
    
    // layout button tapped
    @IBAction func buttonTapped(_ sender: Any) {
        var fromView: UIView
        var toView: UIView
        
        if self.collectionView.isHidden
        {
            fromView = self.tableView
            toView = self.collectionView
            layoutString = "collection"
        }
        else
        {
            fromView = self.collectionView
            toView = self.tableView
            layoutString = "table"
        }
        
        // Show to view, hide from view
        //fromView.removeFromSuperview()
        fromView.isHidden = true
        //toView.frame = fromView.frame
        //self.view.addSubview(toView)
        toView.isHidden = false
        toView.insertSubview(self.refreshControl, at: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell", for: indexPath) as! MovieCollectionCell
        let movie = movies![indexPath.row]
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = URL(string: baseURL + posterPath)
            cell.posterView.setImageWith(imageURL!)
        }
        return cell
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
        MBProgressHUD.showAdded(to: self.view, animated: true)
        // Network Stuff
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.networkErrorView.isHidden = true
                    //print(dataDictionary)
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            } else {
                self.networkErrorView.isHidden = false
                print ("Netowrk Error")
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            self.refreshControl.endRefreshing()
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
        
        //print ("row \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.title.text = title
        cell.overview.text = overview
        
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: self.baseURL + posterPath)
            cell.posterView.setImageWith(imageURL as! URL)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("prepare4segue called")
        if layoutString == "table" {
            let cell = sender as! UITableViewCell
            let movie = movies![tableView.indexPath(for: cell)!.row]
            //print(movie)
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        } else {
            let cell = sender as! UICollectionViewCell
            let movie = movies![collectionView.indexPath(for: cell)!.row]
            //print(movie)
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }

}
