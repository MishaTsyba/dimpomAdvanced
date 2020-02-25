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
	@IBOutlet weak var searchTextField: UITextField!
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
	var headers = ["X-Api-Key": "46a07be3bdf14ff8a433c95d357ac215"]
	var pageNumber: Int = 1
	var pageSize: Int = 10
	var newsMaxCount: Int = 30
	var isLoading: Bool = false
	var refreshControl = UIRefreshControl()

	//MARK: - viewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		shadowView(view: headerView)

		refreshControl.addTarget(self, action: #selector(refreshAction(sender:)), for: .valueChanged)
		newsListTableView.refreshControl = refreshControl
		activityIndicator.isHidden = false

		newsListTableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
		newsListTableView.delegate = self
		newsListTableView.dataSource = self
		searchTextField.delegate = self
		requestNews()
	}

	@IBAction func didTapSearchButton(_ sender: Any) {
		guard let searchKeyword = searchTextField.text else { return }
		if !searchKeyword.isEmpty {
			keyword = searchKeyword
			debugPrint("\(keyword)")
		}
		self.newsArticles = []
		requestNews()
	}
}


