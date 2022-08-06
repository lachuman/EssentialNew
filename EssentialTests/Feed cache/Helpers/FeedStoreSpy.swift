//
//  FeedStoreSpy.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 23/06/21.
//

import Essential

class FeedStoreSpy: FeedStore {
	var deleteCallBack = [DeletionCompletion]()
	var insertionCompletion = [InsertionCompletion]()
	var retrievalCompletion = [RetrievalCompletion]()

	enum ReceivedMessage: Equatable {
		case deleteCacheFeed
		case insert([LocalFeedImage], Date)
		case retrieve
	}

	private(set) var receivedMessages = [ReceivedMessage]()

	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		deleteCallBack.append(completion)
		self.receivedMessages.append(.deleteCacheFeed)
	}

	func insertFeed(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
		self.insertionCompletion.append(completion)
		self.receivedMessages.append(.insert(feed, timeStamp))
	}

	func retrieve(completion: @escaping RetrievalCompletion) {
		self.retrievalCompletion.append(completion)
		self.receivedMessages.append(.retrieve)
	}

	func completeDeletion(with error: NSError, at index: Int = 0) {
		deleteCallBack[index](.failure(error))
	}

	func completeDeletionSuccessfully(at index: Int = 0) {
		deleteCallBack[index](.success(()))
	}

	func completeInsertion(with error: NSError, at index: Int = 0) {
		insertionCompletion[index](.failure(error))
	}

	func completeInsertionSuccessfully(at index: Int = 0) {
		insertionCompletion[index](.success(()))
	}

	func completeRetrieval(with error: NSError, at index: Int = 0) {
		retrievalCompletion[index](.failure(error))
	}

	func completeRetrievalSuccessfully(at index: Int = 0) {
		retrievalCompletion[index](.success(.none))
	}

	func completeRetrieval(with feed: [LocalFeedImage], timeStamp: Date, at index: Int = 0) {
		retrievalCompletion[index](.success((feed: feed, timeStamp: timeStamp)))
	}

	func completeRetrievalWithEmptyCache(at index: Int = 0) {
		retrievalCompletion[index](.success(.none))
	}
}
