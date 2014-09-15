//
//  MovieDetailsViewController.swift
//  rotten
//
//  Created by Sahil Amoli on 9/13/14.
//
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var moviePosterView: UIImageView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var titleAndYearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var criticScoreLabel: UILabel!
    @IBOutlet weak var audienceScoreLabel: UILabel!

    @IBOutlet weak var movieScrollView: UIScrollView!

    var movieDetails = NSDictionary()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var movieTitle = movieDetails["title"] as? String
        var movieYear = String(movieDetails["year"] as NSInteger)
        var movieSynopsis = movieDetails["synopsis"] as? String
        var movieParentalRating =  movieDetails["mpaa_rating"] as? String
        var posters = movieDetails["posters"] as NSDictionary
        var posterUrl = posters["original"] as String
        var ratings = movieDetails["ratings"] as NSDictionary
        var criticScore = String(ratings["critics_score"] as NSInteger)
        var audienceScore = String(ratings["audience_score"] as NSInteger)
        
        navTitle.title = movieTitle
        titleAndYearLabel.text = movieTitle! + " (\(movieYear))"
        criticScoreLabel.text = "Cricic Score: \(criticScore)%"
        audienceScoreLabel.text = "Audience Score: \(audienceScore)%"
        ratingLabel.text = movieParentalRating!
        synopsisLabel.text = movieSynopsis!
        // Adjust size of the ui label
        synopsisLabel.sizeToFit()
        posterUrl = fixImageUrl(posterUrl)
        moviePosterView.setImageWithURL(NSURL(string: posterUrl))

        movieScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Helper
    func fixImageUrl(originalUrl: String) -> String {
        return originalUrl.stringByReplacingOccurrencesOfString("tmb", withString: "ori")
    }
}
