//
//  NewsListController.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/20/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import UIKit

class NewsListController: UIViewController {

	//MARK: - Outlet variables
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var newsListTitleLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var newsListTableView: UITableView!

	//MARK: - Custom variables
	let realmService = RealmService.shared
	var newsArticles: [NewsArticleModel] = []
	var newsArticlesRealmConverted: [NewsArticleModelRealm] = []
	var newsArticlesRealmSaved: [NewsArticleModelRealm] = []
	var url = "https://newsapi.org/v2/everything"
	var keyword = "iOS"
	var newsSortingByTime = "publishedAt"
	var headers = ["X-Api-Key": "fbd6fda585054e02b88a99eb96d5f676"]
	var pageNumber: Int = 1
	var pageSize: Int = 10
	var newsMaxCount: Int = 100
	var isLoading: Bool = false

	//MARK: - viewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()

		shadowView(view: headerView)
		newsListTitleLabel.text = "Loading"
		activityIndicator.isHidden = false

		newsListTableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
		newsListTableView.delegate = self
		newsListTableView.dataSource = self
		newsListTableView.refreshControl = pullToRefreshNews()

		if newsArticles.isEmpty {
			isLoading = true
			getNews(stringUrl: url, keyword: keyword, date: getCurrentFormattedDate(), newsSorting: newsSortingByTime, pageSize: pageSize, page: pageNumber, headers: headers)
		}
	}
}


