//
//  NewsModelRealm.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/22/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import Foundation
import RealmSwift


class NewsModelRealm: Object {
	@objc dynamic var status: String = ""
	@objc dynamic var totalResults: Int = 0
	var articles = List<NewsArticleModelRealm>()
}

class NewsArticleModelRealm: Object {
	@objc dynamic var articleSource: NewsArticleSourceModelRealm?
	@objc dynamic var articleAuthor: String = ""
	@objc dynamic var articleTitle: String = ""
	@objc dynamic var articleDescription: String = ""
	@objc dynamic var articleUrl: String = ""
	@objc dynamic var articleUrlToImage: String = ""
	@objc dynamic var articlePublishedAt: String = ""
	@objc dynamic var articleContent: String = ""
}

class NewsArticleSourceModelRealm: Object {
	@objc dynamic var sourceName: String = ""
	@objc dynamic var sourceId: String = ""
}
