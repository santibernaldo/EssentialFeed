//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/6/24.
//

import Foundation
import EssentialFeed
import Combine



// We wrap on our own MainQueue Scheduler, to keep the logic of checking that we're on the Main Thread


// The decorator pattern add behaviour to an instance, while keeping the same interface

// It's going to behave as a FeedLoader forwarding the messager to the
// decoratee
//final class MainQueueDispatchDecorator<T> {
//    private let decoratee: T
//    
//    init(decoratee: T) {
//        self.decoratee = decoratee
//    }
//    
//    func dispatch(completion: @escaping () -> ()) {
//        if Thread.isMainThread {
//            completion()
//        } else {
//            DispatchQueue.main.async {
//               completion()
//            }
//        }
//    }
//}
//
//extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
//    func load(completion: @escaping (FeedLoader.Result) -> ()) {
//        decoratee.load { [weak self] result in
//            self?.dispatch{ completion(result) }
//        }
//    }
//}
//
//extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
//    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
//        return decoratee.loadImageData(from: url) { [weak self] result in
//            self?.dispatch { completion(result) }
//        }
//    }
//}
