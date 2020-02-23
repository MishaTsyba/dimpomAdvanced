//
//  NewsDetailedController.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/20/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import UIKit
import Alamofire

class NewsDetailedController: UIViewController {

	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var headerLabel: UILabel!

	@IBOutlet weak var atricleTitleLabel: UILabel!
	@IBOutlet weak var articleImageView: UIImageView!
	@IBOutlet weak var articleSourceLabel: UILabel!
	@IBOutlet weak var articleContentLabel: UILabel!
	@IBOutlet weak var articleAuthorLabel: UILabel!
	@IBOutlet weak var articleDateLabel: UILabel!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var articlePhotoView: UIView!

	var newsArticle: NewsArticleModel?

    override func viewDidLoad() {
        super.viewDidLoad()
		updateUI()
		shadowView(view: headerView)
		shadowView(view: articlePhotoView)
    }

	@IBAction func didTapBackButton(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
}

//MARK: - Update UI
extension NewsDetailedController {
	func updateUI() {
		guard let article = newsArticle else { return }

		atricleTitleLabel.text = article.title

		if let source = article.source{
			articleSourceLabel.text = "From: " + (source.name ?? "")
		}

		articleContentLabel.text = article.content
		articleAuthorLabel.text = "By: " + (article.author ?? "")

		if let date = article.publishedAt {
			articleDateLabel.text = formatDate(stringDate: date)
		}

		DispatchQueue.global(qos: .utility).async {
			guard let article = self.newsArticle else { return }
			guard let imageUrl = URL(string: article.urlToImage ?? "") else { return }
			do {
				let imageData = try Data(contentsOf: imageUrl)
				let image = UIImage(data: imageData)
				DispatchQueue.main.async {
					self.articleImageView.image = image
				}
			} catch {
				debugPrint(error)
				DispatchQueue.main.async {
					self.articleImageView.image = UIImage(named: "connectionlost")
				}
			}
		}
	}
}

//MARK: - Format Date
extension NewsDetailedController {
	func formatDate(stringDate: String) -> String {

		//Assign Date formats
		let currentDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		let expectedDateFormat = "MMM d, yyyy"

		//Init DateFormatter
		let dateFormatter = DateFormatter()

		//Assign currentDateFormat to DateFormatter
		dateFormatter.dateFormat = currentDateFormat

		//Convert input string value to Date based on currentDateFormat
		guard let date: Date = dateFormatter.date(from: stringDate) else { return "" }

		//Assign expectedDateFormat to DateFormatter
		dateFormatter.dateFormat = expectedDateFormat

		//Convert Date to output string value based on expectedDateFormat
		return dateFormatter.string(from: date)
	}
}

//MARK: - Design UI
extension NewsDetailedController {

	func shadowView(view: UIView) {
		view.layer.borderWidth = 0.8
		view.layer.borderColor = UIColor.black.cgColor
		view.layer.masksToBounds = false
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOffset = CGSize(width: 0, height: 0)
		view.layer.shadowOpacity = 3
		view.layer.shadowRadius = 0.8

		view.layer.shouldRasterize = true
		view.layer.rasterizationScale = 1
	}
}
