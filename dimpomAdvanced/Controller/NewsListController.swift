//
//  NewsListController.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/20/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class NewsListController: UIViewController {

	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var newsListTitleLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	@IBOutlet weak var newsListTableView: UITableView!

	var newsArticles: [NewsArticleModel] = []
	var newsArticlesRealmConverted: [NewsArticleModelRealm] = []
	var newsArticlesRealmSaved: [NewsArticleModelRealm] = []
	let realmService = RealmService.shared

	override func viewDidLoad() {
		super.viewDidLoad()

		debugPrint("*********** NewsListController viewDidLoad  **************")

		shadowView(view: headerView)
		newsListTitleLabel.text = "Loading"
		activityIndicator.isHidden = false

		newsListTableView.delegate = self
		newsListTableView.dataSource = self
		newsListTableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")

		getNewsResponseData()
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
		navigationController?.pushViewController(vc, animated: false)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}

//MARK: - Alamofire REST request
extension NewsListController {
	func getNewsResponseData() {
		//Activity Indicator start
		activityIndicator.startAnimating()

		//URL composing
		guard let url = URL(string: "https://newsapi.org/v2/everything") else { return }

		//Request parameters composing
		let requestParameters = ["q": "iOS", "to": getCurrentFormattedDate()]

		//Alamofire request
		Alamofire
			.request(url, method: .get, parameters: requestParameters, encoding: URLEncoding.default, headers: ["X-Api-Key": "fbd6fda585054e02b88a99eb96d5f676"]).validate(statusCode: 200..<300).responseData { (response) in
				switch response.result {
					case .success:
						debugPrint("Response Validation Successful")
						if let jsonResponse = response.result.value {
							do {
								let newsModel = try JSONDecoder().decode(NewsModel.self, from: jsonResponse)
								if let newsArticles = newsModel.articles {
									debugPrint(newsArticles)
									self.newsArticles = newsArticles
									DispatchQueue.main.async {

										debugPrint("************************* Realm Start Convert *********************************")
										self.newsArticlesRealmConverted = self.parseNewsArticleModelToRealm(with: self.newsArticles)
										debugPrint(self.newsArticlesRealmConverted.count)
										debugPrint("************************* Realm End Convert *********************************")

										debugPrint("************************* Realm Start Deleting *********************************")
										self.realmService.deleteNews()
										debugPrint("************************* Realm End Deleting *********************************")

										debugPrint("************************* Realm Start Writing *********************************")
										self.realmService.addNews(news: self.newsArticlesRealmConverted)
										debugPrint("************************* Realm End Writing *********************************")

										self.newsListTitleLabel.text = "News about: \(requestParameters["q"] ?? "")"

										self.activityIndicator.stopAnimating()
										self.activityIndicator.isHidden = true
										self.newsListTableView.reloadData()
									}
								}
							} catch {
								debugPrint(error)
							}
						}
					case .failure:
						debugPrint("Response Validation error")
						DispatchQueue.main.async {
							if !self.realmService.getNews().isEmpty {

								debugPrint("************************* Realm Start Reading *********************************")
								self.newsArticlesRealmSaved = self.realmService.getNews()
								debugPrint("************************* Realm End Reading *********************************")

								debugPrint("************************* Realm Start Loading *********************************")
								self.newsArticles = self.parseNewsArticleModelFromRealm(with: self.newsArticlesRealmSaved)
								debugPrint("************************* Realm End Loading *********************************")

								self.newsListTitleLabel.text = "News about: \(requestParameters["q"] ?? "")"
							} else {
								self.newsArticles = []
								self.newsListTitleLabel.text = "Connection Error"
							}
							self.activityIndicator.stopAnimating()
							self.activityIndicator.isHidden = true
							self.newsListTableView.reloadData()
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

//MARK: - Parsing NewsArticleModel to NewsArticleModelRealm
extension NewsListController {

	func parseNewsArticleModelToRealm(with newsArticles: [NewsArticleModel]) -> [NewsArticleModelRealm] {
		debugPrint("START parseNewsArticleModelToRealm")
		debugPrint(newsArticles.count)

		var newsArticlesRealm: [NewsArticleModelRealm] = []
		for article in newsArticles {
			//debugPrint(article)

			let newsArticleModelRealm = NewsArticleModelRealm()
			let newsArticleSourceModelRealm = NewsArticleSourceModelRealm()

			if let articleAuthor = article.author {
				newsArticleModelRealm.articleAuthor = articleAuthor
				//debugPrint(newsArticleModelRealm.articleAuthor)
			}

			if let articleTitle = article.title {
				newsArticleModelRealm.articleTitle = articleTitle
				//debugPrint(newsArticleModelRealm.articleTitle)
			}

			if let articleDescription = article.description {
				newsArticleModelRealm.articleDescription = articleDescription
				//debugPrint(newsArticleModelRealm.articleDescription)
			}

			if let articleUrl = article.url {
				newsArticleModelRealm.articleUrl = articleUrl
				//debugPrint(newsArticleModelRealm.articleUrl)
			}

			if let articleUrlToImage = article.urlToImage {
				newsArticleModelRealm.articleUrlToImage = articleUrlToImage
				//debugPrint(newsArticleModelRealm.articleUrlToImage)
			}

			if let articlePublishedAt = article.publishedAt {
				newsArticleModelRealm.articlePublishedAt = articlePublishedAt
				//debugPrint(newsArticleModelRealm.articlePublishedAt)
			}

			if let articleContent = article.content {
				newsArticleModelRealm.articleContent = articleContent
				//debugPrint(newsArticleModelRealm.articleContent)
			}

			if let source = article.source {
				if let sourceName = source.name {
					newsArticleSourceModelRealm.sourceName = sourceName
				}

				if let sourceId = source.id {
					newsArticleSourceModelRealm.sourceId = sourceId
				}
			}

			newsArticleModelRealm.articleSource = newsArticleSourceModelRealm
			//debugPrint(newsArticleModelRealm.articleSource as? Any)
			newsArticlesRealm.append(newsArticleModelRealm)
		}

		debugPrint("END parseNewsArticleModelToRealm")
		return newsArticlesRealm
	}
}

//MARK: - Parsing  NewsArticleModelRealm to NewsArticleModel
extension NewsListController {

	func parseNewsArticleModelFromRealm(with newsArticlesRealm: [NewsArticleModelRealm]) -> [NewsArticleModel] {
		debugPrint("parseNewsArticleModelFromRealm")
		debugPrint(newsArticlesRealm.count)

		var newsArticles: [NewsArticleModel] = []
		for article in newsArticlesRealm {
			debugPrint(article)
			let newsArticleModel = NewsArticleModel()
			let newsArticleSourceModel = NewsArticleSourceModel()

			newsArticleModel.author = article.articleAuthor
			newsArticleModel.title = article.articleTitle
			newsArticleModel.description = article.articleDescription
			newsArticleModel.url = article.articleUrl
			newsArticleModel.urlToImage = article.articleUrlToImage
			newsArticleModel.publishedAt = article.articlePublishedAt
			newsArticleModel.content = article.articleContent

			if let articleSource = article.articleSource {
				newsArticleSourceModel.name = articleSource.sourceName
				newsArticleSourceModel.id = articleSource.sourceId
			}

			newsArticleModel.source = newsArticleSourceModel

			newsArticles.append(newsArticleModel)
		}

		debugPrint("END parseNewsArticleModelFromRealm")
		debugPrint(newsArticles.count)
		return newsArticles
	}
}
