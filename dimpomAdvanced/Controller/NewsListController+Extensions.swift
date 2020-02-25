//
//  NewsListController+Extensions.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/23/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

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

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if newsArticles.count < newsMaxCount && indexPath.row >= newsArticles.count - 1 && !isLoading {
			pageNumber += 1
			self.isLoading = true
			getNews(stringUrl: url, keyword: keyword, date: getCurrentFormattedDate(), newsSorting: newsSortingByTime, pageSize: pageSize, page: pageNumber, headers: headers)
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		navigateToDetailedNews(indexPath: indexPath)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}

//MARK: - Controller functionality
extension NewsListController {

	//MARK: - Request News
	func requestNews() {
		if isConnectedToInternet() {
			isLoading = true
			getNews(stringUrl: url, keyword: keyword, date: getCurrentFormattedDate(), newsSorting: newsSortingByTime, pageSize: pageSize, page: pageNumber, headers: headers)
		} else {
			self.loadDataFromRealm()
			self.newsListTableView.reloadData()
		}
	}
	//MARK: - getNews
	func getNews(stringUrl: String, keyword: String, date: String, newsSorting: String, pageSize: Int, page: Int, headers: [String: String]) {
		if isLoading {
			activityIndicator.startAnimating()
			guard let url = URL(string: stringUrl) else { return }
			let requestParameters = ["q": keyword,  "to": date, "pageSize": pageSize, "page": page, "sortBy": newsSorting] as [String : Any]
			let headers = headers
			makeRequest(url: url, requestParameters: requestParameters, headers: headers)
		}
	}

	//MARK: - makeRequest
	func makeRequest(url: URL, requestParameters: [String: Any], headers: [String: String]) {
		Alamofire
			.request(url, method: .get, parameters: requestParameters, encoding: URLEncoding.default, headers: headers).validate(statusCode: 200..<300).responseData { (response) in
				self.refreshControl.endRefreshing()
				self.isLoading = false
				switch response.result {
				case .success:
					self.activityIndicator.startAnimating()
					guard let jsonResponse = response.result.value else { return }
					do {
						let newsModel = try JSONDecoder().decode(NewsModel.self, from: jsonResponse)
						guard let newsArticles = newsModel.articles else { return }
						self.newsArticles.append(contentsOf: newsArticles)
						debugPrint("Response Validation Successful")
						debugPrint("\(self.newsArticles)")
						self.saveDataToRealm(newsArticles: self.newsArticles)
						self.newsListTableView.reloadData()
					} catch {
						debugPrint(error)
					}
				case let .failure(error):
					debugPrint("Response Validation error")
					debugPrint(error)
				}
		}
	}

	//MARK: - saveDataToRealm
	func saveDataToRealm(newsArticles: [NewsArticleModel]) {

		debugPrint("************************* Realm Start Convert *********************************")
		self.newsArticlesRealmConverted = self.parseNewsArticleModelToRealm(with: newsArticles)
		debugPrint("************************* Realm End Convert *********************************")

		debugPrint("************************* Realm Start Deleting *********************************")
		self.realmService.deleteNews()
		debugPrint("************************* Realm End Deleting *********************************")

		debugPrint("************************* Realm Start Writing *********************************")
		self.realmService.addNews(news: self.newsArticlesRealmConverted)
		debugPrint("************************* Realm End Writing *********************************")

		self.hideActivityUI()
	}

	//MARK: - loadDataFromRealm
	func loadDataFromRealm() {

		debugPrint("************************* Realm Start Reading *********************************")
		self.newsArticlesRealmSaved = self.realmService.getNews()
		debugPrint("************************* Realm End Reading *********************************")

		debugPrint("************************* Realm Start Loading *********************************")
		self.newsArticles = self.parseNewsArticleModelFromRealm(with: self.newsArticlesRealmSaved)
		debugPrint("************************* Realm End Loading *********************************")

		self.hideActivityUI()
	}

	//MARK: - parseNewsArticleModelToRealm
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

	//MARK: - parseNewsArticleModelFromRealm
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

	//MARK: - Pull to refresh refreshAction
	@objc func refreshAction(sender: UIRefreshControl) {
		isLoading = true
		self.newsArticles = []
		refreshControl.beginRefreshing()
		getNews(stringUrl: url, keyword: keyword, date: getCurrentFormattedDate(), newsSorting: newsSortingByTime, pageSize: pageSize, page: pageNumber, headers: headers)
		self.newsListTableView.reloadData()
	}

	//MARK: - navigateToDetailedNews
	func navigateToDetailedNews(indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailedController") as! NewsDetailedController
		vc.newsArticle = newsArticles[indexPath.row]
		navigationController?.pushViewController(vc, animated: false)
	}

	//MARK: - hideActivityUI
	func hideActivityUI() {
		self.activityIndicator.stopAnimating()
		self.activityIndicator.isHidden = true
		self.newsListTitleLabel.isHidden = true
	}

	//MARK: - Design UI
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

	//MARK: - Get Current Date in ISO 8601 as String
	func getCurrentFormattedDate() -> String {
		let date = Date()
		let dateFormatter = DateFormatter()
		let currentDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		dateFormatter.dateFormat = currentDateFormat
		return dateFormatter.string(from: date)
	}
}

//MARK: - UITextFieldDelegate
extension NewsListController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField {
		case searchTextField:
			searchTextField.resignFirstResponder()
		default:
			searchTextField.resignFirstResponder()
		}
		return true
	}

	func isConnectedToInternet() -> Bool {
		return NetworkReachabilityManager()?.isReachable ?? false
	}
}
