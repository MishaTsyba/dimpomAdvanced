//
//  NewsListController.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/20/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import UIKit
import Alamofire

class NewsListController: UIViewController {

	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var newsListTitleLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	@IBOutlet weak var newsListTableView: UITableView!

	var newsArticles: [NewsArticleModel] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		shadowView(view: headerView)
		activityIndicator.style = UIActivityIndicatorView.Style.medium
		newsListTableView.delegate = self
		newsListTableView.dataSource = self
		newsListTableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
		newsListTitleLabel.text = "Loading"
		activityIndicator.isHidden = false
		debugPrint("*********** NewsListController viewDidLoad  **************")
		getNewsResponseData()
		newsListTableView.reloadData()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		newsListTitleLabel.text = "Loading"
		activityIndicator.isHidden = false
		debugPrint("*********** NewsListController viewWillAppear  **************")
		getNewsResponseData()
		newsListTableView.reloadData()
	}
}

//MARK: - UITableViewDelegate
extension NewsListController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return newsArticles.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
		cell.updateNewsCell(news: newsArticles[indexPath.row])
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		debugPrint("*********** NewsListController didSelectRowAt  **************")

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailedController") as! NewsDetailedController

		vc.newsArticle = newsArticles[indexPath.row]
		debugPrint(vc.newsArticle)

		navigationController?.pushViewController(vc, animated: false)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}

//MARK: - Alamofire REST request
extension NewsListController {
	func getNewsResponseData() {
		activityIndicator.startAnimating()

		//URL composing
		guard let url = URL(string: "https://newsapi.org/v2/everything") else { return }

		//Request parameters composing
		let requestParameters = ["q": "iOS", "to": getCurrentFormattedDate()]
		debugPrint(requestParameters["to"])
		//Alamofire request
		Alamofire.request(url,
						  method: .get,
						  parameters: requestParameters,
						  encoding: URLEncoding.default,
						  headers: ["X-Api-Key": "fbd6fda585054e02b88a99eb96d5f676"]).responseData { (response) in

							if let jsonResponse = response.result.value {
								do {
									let newsModel = try JSONDecoder().decode(NewsModel.self, from: jsonResponse)
									if let newsArticles = newsModel.articles {
										self.newsArticles = newsArticles
										self.activityIndicator.stopAnimating()
										self.activityIndicator.isHidden = true

										self.newsListTitleLabel.text = "News about: \(requestParameters["q"] ?? "")"
										self.newsListTableView.reloadData()
									}
								} catch {
									debugPrint(error)
								}
							}
		}
	}
}

//MARK: - Design UI
extension NewsListController {

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

//MARK: - Get Current Date in ISO 8601 as String
extension NewsListController {
	func getCurrentFormattedDate() -> String {
		let date = Date()
		let dateFormatter = DateFormatter()
		let currentDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		dateFormatter.dateFormat = currentDateFormat
		return dateFormatter.string(from: date)
	}
}

