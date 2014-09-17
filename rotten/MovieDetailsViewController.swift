//
//  MovieDetailsViewController.swift
//  rotten
//
//  Created by Sahil Amoli on 9/13/14.
//
//

import UIKit

class MovieDetailsViewController: UIViewController {

    /* Selectors */

    @IBOutlet weak var moviePosterView: UIImageView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var titleAndYearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var criticScoreLabel: UILabel!
    @IBOutlet weak var audienceScoreLabel: UILabel!
    @IBOutlet weak var movieScrollView: UIScrollView!

    /* Member variables */

    var movieDetails = NSDictionary()

    /* Lifecycle Methods */

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let movieTitle = movieDetails["title"] as? String
        let movieYear = String(movieDetails["year"] as NSInteger)
        let movieSynopsis = movieDetails["synopsis"] as? String
        let movieParentalRating =  movieDetails["mpaa_rating"] as? String
        let posters = movieDetails["posters"] as NSDictionary
        let lowResPosterUrl = posters["original"] as String
        let highResPosterUrl = fixImageUrl(lowResPosterUrl)
        let ratings = movieDetails["ratings"] as NSDictionary
        let criticScore = String(ratings["critics_score"] as NSInteger)
        let audienceScore = String(ratings["audience_score"] as NSInteger)
        
        navTitle.title = movieTitle
        titleAndYearLabel.text = movieTitle! + " (\(movieYear))"
        criticScoreLabel.text = "Cricic Score: \(criticScore)%"
        audienceScoreLabel.text = "Audience Score: \(audienceScore)%"
        ratingLabel.text = movieParentalRating!
        synopsisLabel.text = movieSynopsis!
        // Adjust size of the ui label
        synopsisLabel.sizeToFit()

        // Set lowres image first
        moviePosterView.setImageWithURL(NSURL(string: lowResPosterUrl))
        // Set highres image (it will replace the lowres image once its done)
        moviePosterView.setImageWithURL(NSURL(string: highResPosterUrl))

        movieScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* Gesture Handlers */

    @IBAction func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        let currentCenterY = recognizer.view!.center.y
        let endPositionY = currentCenterY + translation.y

        recognizer.view!.center = CGPoint(x: recognizer.view!.center.x,
                y: endPositionY)
            
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        // Animate the details to the top
        if endPositionY < 650 && translation.y < 0 {
            UIView.animateWithDuration(0.5, animations: {
                recognizer.view!.frame = CGRectMake(0, 63, recognizer.view!.frame.size.width, recognizer.view!.frame.size.height)
                }, completion: { finished in
            })
        }
        // Animate the details to the bottom
        if endPositionY > 450 && translation.y > 0 {
            UIView.animateWithDuration(0.5, animations: {
                recognizer.view!.frame = CGRectMake(0, self.view.frame.size.height - 95, recognizer.view!.frame.size.width, recognizer.view!.frame.size.height)
                }, completion: { finished in
                    
            })
        }
    }
    
    /* Helper Method */
    func fixImageUrl(originalUrl: String) -> String {
        return originalUrl.stringByReplacingOccurrencesOfString("tmb", withString: "ori")
    }
}
