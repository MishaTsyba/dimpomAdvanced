//
//  NewsDetailedController+Extensions.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/23/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import UIKit


//MARK: - Update UI
extension NewsDetailedController {
	func updateUI() {
		guard let article = newsArticle else { return }

		atricleTitleLabel.text = article.title

		if let source = article.source{
			articleSourceLabel.text = "From: " + (source.name ?? "no source")
		}

		articleContentLabel.text = article.content
		articleAuthorLabel.text = "By: " + (article.author ?? "no author")

		if let date = article.publishedAt {
			articleDateLabel.text = formatDate(stringDate: date)
		}

		if let urlString = article.urlToImage, let url = URL(string: urlString) {
			articleImageView.kf.setImage(with: url)
		} else {
			articleImageView.image = UIImage(named: "connectionlost")
		}
	}
}

//MARK: - Format Date
extension NewsDetailedController {
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
