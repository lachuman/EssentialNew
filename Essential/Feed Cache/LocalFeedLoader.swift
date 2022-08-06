//
//  LocalFeedLoader.swift
//  Essential
//
//  Created by lakshman-7016 on 20/06/21.
//

import Foundation

public class LocalFeedLoader {
	private let store: FeedStore
	private let currentDate: () -> Date

	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
}

extension LocalFeedLoader {
	public typealias SaveResult = Result<Void, Error>

	public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		store.deleteCachedFeed { [weak self] deletionResult in
			guard let self = self else { return }

			switch deletionResult {
			case .success:
				self.cache(feed, with: completion)
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
		store.insertFeed(feed.toLocal(), timeStamp: currentDate()) { [weak self] insertionResult in
			guard self != nil else { return }
			switch insertionResult {
			case .success:
				completion(.success(()))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}

extension LocalFeedLoader: FeedLoader {
	public typealias LoadResult = FeedLoader.Result

	public func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve() { [weak self] retrievedResult in
			guard let self = self else { return }
			switch retrievedResult {
			case .failure(let error):
				completion(.failure(error))

			case let .success(.some((feed: feed, timeStamp: timeStamp))) where FeedCachePolicy.validate(timeStamp, against: self.currentDate()):
				completion(.success(feed.toModels()))

			case .success:
				completion(.success([]))
			}
		}
	}
}

extension LocalFeedLoader {
	public func validateCache() {
		store.retrieve() { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .failure:
				self.store.deleteCachedFeed() { _ in }

			case let .success(.some((_, timeStamp))) where !FeedCachePolicy.validate(timeStamp, against: self.currentDate()):
				self.store.deleteCachedFeed() { _ in }

			case .success:
				break
			}
		}
	}
}

extension Array where Element == FeedImage {
	func toLocal() -> [LocalFeedImage] {
		map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}

extension Array where Element == LocalFeedImage {
	func toModels() -> [FeedImage] {
		map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}
