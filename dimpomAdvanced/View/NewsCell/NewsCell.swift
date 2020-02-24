//
//  NewsCell.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/20/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import UIKit
import Kingfisher

class NewsCell: UITableViewCell {

	@IBOutlet weak var newsImageView: UIImageView!
	@IBOutlet weak var newsTimeLabel: UILabel!
	@IBOutlet weak var newsTitleLabel: UILabel!
	@IBOutlet weak var newsDescriptionLabel: UILabel!
	@IBOutlet weak var cellBackgroundView: UIView!

	override func awakeFromNib() {
        super.awakeFromNib()
		shadowView(view: cellBackgroundView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension NewsCell {

	func updateNewsCell(news: NewsArticleModel) {

		if let newsTitle = news.title {
			newsTitleLabel.text = newsTitle
		} else {
			newsTitleLabel.text = "no title"
		}

		if let newsDescription = news.description {
			newsDescriptionLabel.text = newsDescription
		} else {
			newsDescriptionLabel.text = "no description"
		}

		if let newsTime = news.publishedAt {
			newsTimeLabel.text = formatDate(stringDate: newsTime)
		} else {
			newsDescriptionLabel.text = "no time"
		}
		if let urlString = news.urlToImage, let url = URL(string: urlString) {
			newsImageView.kf.setImage(with: url)
		} else {
			newsImageView.image = UIImage(named: "connectionlost")
		}
	}
}

extension NewsCell {
	func designView(view: UIView) {
		view.clipsToBounds = true
		view.layer.cornerRadius = 10
	}

	func shadowView(view: UIView) {
		view.layer.borderWidth = 0.3
		view.layer.borderColor = UIColor.black.cgColor
		view.layer.masksToBounds = false
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOffset = CGSize(width: 0, height: 1)
		view.layer.shadowOpacity = 3
		view.layer.shadowRadius = 3

		view.layer.shouldRasterize = true
		view.layer.rasterizationScale = 1
	}
}

extension NewsCell {
	func formatDate(stringDate: String) -> String {

		//Assign Date formats
		let currentDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		let expectedDateFormat = "MM-dd-yyyy HH:mm"

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
