//
//  RealmService.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/22/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
	static let shared: RealmService = {
		let instance = RealmService()
		return instance
	}()

	func addNews(news: [NewsArticleModelRealm]) {
		do {
			let realm = try Realm()
			try realm.write {
				realm.add(news)
			}
		} catch {
			debugPrint("error writing news to realm")
		}
	}

	func getNews()-> [NewsArticleModelRealm] {
		do {
			let realm = try Realm()
			let news = realm.objects(NewsArticleModelRealm.self)
			let newsArray = Array(news)
			return newsArray
		} catch {
			debugPrint("error getting news from realm")
			return[]
		}
	}

	func deleteNews() {
        do {
			let realm = try Realm()
			try realm.write {
				realm.deleteAll()
			}
        } catch {
            debugPrint("Error deliting all News")
        }
    }
}
