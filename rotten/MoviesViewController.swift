//
//  MoviesViewController.swift
//  rotten
//
//  Created by Sahil Amoli on 9/11/14.
//
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    /* Constants */

    let getBoxOfficeMoviesURL = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=z62yeq4nzpkynde4h5k739kn&limit=20"
    let searchMoviesURL = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?page_limit=20&apikey=z62yeq4nzpkynde4h5k739kn&q="
    let pullToRefresh = "Pull down to refresh"

    /* Selectors */

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet var gestureRecognizer: UITapGestureRecognizer!

    /* Member variables */

    // Holds all the movie information
    var movies: [NSDictionary] = []
    // UI to handle pull down to refresh
    var refreshControl:UIRefreshControl!
    // Stores current search request string
    var currentSearch = ""

    /* Lifecycle Methods */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show loading spinner
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        tableView.delegate = self
        tableView.dataSource = self
        movieSearchBar.delegate = self

        self.refreshControl = UIRefreshControl()
        // Create color attribute
        var colorAttribute =  [NSForegroundColorAttributeName: UIColor.whiteColor()]
        // Set attributed text
        self.refreshControl.attributedTitle = NSAttributedString(string: pullToRefresh, attributes: colorAttribute)
        // Add target for refresh
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

        // Add the refresh control to the table view
        self.tableView.addSubview(refreshControl)

        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        // Get movie list
        getMovieList()
    }

    override func viewWillDisappear(animated: Bool) {
        movieSearchBar.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* TableView methods */

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var movieCell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as MovieCell
        
        // Grab the movie information from our data source
        var movie = movies[indexPath.row]
        var movieTitle = movie["title"] as? String
        var movieSynopsis = movie["synopsis"] as? String
        var movieParentalRating =  movie["mpaa_rating"] as? String
        var posters = movie["posters"] as NSDictionary
        var posterUrl = posters["thumbnail"] as String

        movieCell.titleLabel!.text = movieTitle
        movieCell.synopsisLabel!.text = movieParentalRating! + " " + movieSynopsis!

        movieCell.movieImageView.backgroundColor = UIColor.blackColor()
        movieCell.movieImageView.alpha = 0.0

        // Fade-in images
        movieCell.movieImageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string:posterUrl)), placeholderImage: nil, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
            movieCell.movieImageView.image = image

            UIView.animateWithDuration(0.5, animations: { () -> Void in
                movieCell.movieImageView.alpha = 1.0
            }, completion: { (Bool) -> Void in
            })
            }) { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
        }

        return movieCell
    }

    /* SearchBar Methods */

    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        self.currentSearch = searchText

        if !searchText.isEmpty {
            // IF there is search, return searched movies
            getMovieList(searchString: searchText)
        } else {
            // If the user erased the search, get full movie list
            getMovieList()
        }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        movieSearchBar.endEditing(true)
    }

    /* Segue Handler */

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var selectedRow = tableView.indexPathForSelectedRow()?.row
        var movieDetails = movies[selectedRow!]
        var destinationViewController = segue.destinationViewController as MovieDetailsViewController
        // Set up movie details inside the MovieDetailsViewController
        destinationViewController.movieDetails = movieDetails
    }

    /* Helpers */

    // Handles the GET Movies API and Search Requests
    func getMovieList(searchString: String = "") -> Void {
        var requestUrl = getBoxOfficeMoviesURL
        var isSearch = false
        
        if !searchString.isEmpty {
            requestUrl = searchMoviesURL + searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
            isSearch = true
        }

        var request = NSURLRequest(URL: NSURL(string: requestUrl))
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in

            // Hide loading spinner
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                self.showOfflineBanner()
                return
            }

            // Hide offline banner if it's visible
            self.hideOfflineBannerIfVisible()

            var errorValue: NSError?
            var responseData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &errorValue) as NSDictionary
            
            if(errorValue != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(errorValue!.localizedDescription)")
                return
            }

            // If this isn't the response to the last search, drop the response
            if self.currentSearch == searchString {
                self.movies = responseData["movies"] as [NSDictionary]
                // Need to reload the table view when we have data!
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }

    // Handle pull down to refresh
    func refresh(sender: AnyObject) {
        getMovieList(searchString: self.currentSearch)
    }

    // Show Offline Banner
    func showOfflineBanner() {
        // If the banner is already visible don't do anything
        if (!offlineView.hidden) {
            return
        }

        self.offlineView.hidden = false
        self.refreshControl.endRefreshing()

        UIView.animateWithDuration(0.5, animations: {
            self.offlineView.frame = CGRectMake(0, 65, self.offlineView.frame.size.width, self.offlineView.frame.size.height)
        })

    }

    // Hide Offline Banner
    func hideOfflineBannerIfVisible() {
        // If the banner is already visible don't do anything
        if (offlineView.hidden) {
            return
        }

        UIView.animateWithDuration(0.5, animations: {
            self.offlineView.frame = CGRectMake(0, 35, self.offlineView.frame.size.width, self.offlineView.frame.size.height)
        }, completion: { finished in
            self.offlineView.hidden = true
        })
    }

}

