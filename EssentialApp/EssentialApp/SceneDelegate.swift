//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/7/24.
//

import os
import UIKit
import CoreData
import EssentialFeed
import Combine

/*
 SceneDelegate acting as the Composition Root:
 it allows us to keep the modules needed decoupled
 
 The problem with having every module coupled, or a shared module coupled with all the rest, it is that every time you change something in the shared module, it can breaks one of the other modules, or even if you don't break them, you have to recompile o redeploy all the other modules which can live in other repositories
 */
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    // CODE: Ask
    // STAR: If our components are not thread safe, we must implement always the operations in a serial Scheduler (Serial: Executes only one task at a time)
    // It can be passed on the subscribe(on: Scheduler) on Combine
    // We use .concurrent, because CoreData using the perform API we created, is Thread-Safe
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
            label: "com.essentialdeveloper.infra.queue",
            qos: .userInitiated,
            attributes: .concurrent
        ).eraseToAnyScheduler()
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("feed-store.sqlite"))
        } catch {
            // STAR: Returns a NullStore will prevent the app to be in a WEIRD STATE.
            // Maybe the feedstore can't be created, because there's not enough space in disk for example, or some bug arise from the model of the feedstore
            // STAR: assertionFailure only will crash on Debug
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var logger = Logger(subsystem: "com.essentialdeveloper.EssentialAppCaseStudy", category: "main")
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var remoteFeedLoader = httpClient.getPublisher(url: remoteURLFeed)

    private lazy var localImageLoader = {
        LocalFeedImageDataLoader(store: store)
    }()
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments))
    //
    private lazy var remoteURLFeed: URL = FeedEndpoint.get().url(baseURL: baseURL)

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore, scheduler: AnyDispatchQueueScheduler) {
        self.init()
        self.httpClient = httpClient
        self.store = store
        self.scheduler = scheduler
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    // AnyPublisher -> produces an array of FeedImage or an error
//    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
//        // There are many Publishers we can create, one of them is 'Future'. It starts with a completionBlock, and once the work is done, is returns some result
//
//        // The signature of the completion `load` expects is the same one of the ÁnyPublisher returned
//        return remoteFeedLoader
//            .caching(to: localFeedLoader)
//            .fallback(to: localFeedLoader.loadPublisher)
//            .map(makeFirstPage)
//            .eraseToAnyPublisher()
//    }
    
//    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
//        let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
//        
//        // Future fires would fire the request every time we call 'makeRemoteFeedLoaderWithLocallFallback', not when someone subscribes to it
//        
//        // So we defers the execution of it
//        
//        //         [  side-effect  ]
//        //         -pure function-
//        //         [  side-effect  ]
//        return remoteFeedLoader             //  [ network request ]
//            .tryMap(FeedItemsMapper.map)    //  -     mapping     -
//            .caching(to: localFeedLoader)   //  [     caching     ]
//        // When fallback, the `load` of the localFeedLoader is called
//            .fallback(to: localFeedLoader.loadPublisher)
//            .map { items in
//                Paginated(items: items, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: items, last: items.last))
//            }
//            .eraseToAnyPublisher()
//    }
    
    // TODO: Refactor Extract Logic into helper methods (video Keyset pagination and commit)
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
           makeRemoteFeedLoader()
               .caching(to: localFeedLoader)
               .fallback(to: localFeedLoader.loadPublisher)
               .map(makeFirstPage)
               .eraseToAnyPublisher()
       }
           
       private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
           makeRemoteFeedLoader(after: last)
                // STAR: COMBINE Zip operator combines two results into a tuple
               .zip(localFeedLoader.loadPublisher())
               .map { (newItems, cachedItems) in
                   (cachedItems + newItems, newItems.last)
               }.map(makePage)
               .caching(to: localFeedLoader)
       }
       
       private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
           let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
           
           return httpClient
               .getPublisher(url: url)
               .tryMap(FeedItemsMapper.map)
               .eraseToAnyPublisher()
       }
       
       private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
           makePage(items: items, last: items.last)
       }
       
       private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
           Paginated(items: items, loadMorePublisher: last.map { last in
               { self.makeRemoteLoadMoreLoader(last: last) }
           })
       }
       
       private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
           
           let localImageLoader = LocalFeedImageDataLoader(store: store)

           return localImageLoader
               .loadImageDataPublisher(from: url)
               .fallback(to: { [httpClient, scheduler] in
                  httpClient
                       .getPublisher(url: url)
                       .tryMap(FeedImageDataMapper.map)
                       .caching(to: localImageLoader, using: url)
                       // STAR: We perform on a Serial Queue from the Composition Root our components, in this case, the cahing.
                       // We don't need to make our components Thread Safe, if we control Threading as a Cross-Cutting concern from the Composition Root
                       .subscribe(on: scheduler)
                       .eraseToAnyPublisher()
               })
                // DispatchQueue.global implements the Scheduler protocol. We avoid dispatching on the MainThread
                // The global dispatch queue is a concurrent queue
               .subscribe(on: scheduler)
                // We erase to AnyPublisher, because the return type is a AnyPublisher
               .eraseToAnyPublisher()
       }
    
    // STAR: Injecting the logging into the chain with handleEvents
    private func makeLocalImageLoaderWithCombineLoggerRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let httpClient = HTTPClientProfilingDecorator(decoratee: httpClient, logger: logger)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        return localImageLoader
            .loadImageDataPublisher(from: url)
            .logCacheMisses(url: url, logger: logger)
            .fallback(to: { [httpClient, logger] in
                return httpClient
                    .getPublisher(url: url)
                    .logErrors(url: url, logger: logger)
                    .logElapsedTime(url: url, logger: logger)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
            // DispatchQueue.global implements the Scheduler protocol. We avoid dispatching on the MainThread
            // The global dispatch queue is a concurrent queue
            .subscribe(on: scheduler)
            // We erase to AnyPublisher, because the return type is a AnyPublisher
            .eraseToAnyPublisher()
    }
    
}

// We decorate the HTTPClient to print the requests
private class HTTPClientProfilingDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let logger: Logger
    
    init(decoratee: HTTPClient, logger: Logger) {
        self.decoratee = decoratee
        self.logger = logger
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any HTTPClientTask {
        logger.trace("Starting loading url: \(url)")
        
        // STAR: Date can get OUT OF DATE, and you can get INCONSISTENT logging
        let startTime = CACurrentMediaTime()
        return decoratee.get(from: url) { [logger] result in
            if case let .failure(error) = result {
                logger.trace("failed to load url: \(url) with error: \(error.localizedDescription)")
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("Finished loading url: \(url) in \(elapsed) seconds")
            
            completion(result)
        }
    }
}

extension Publisher {
    // STAR: Logging is a CROSS-CUTTING concern (it applies everywhere), so with a good design, we can apply Logging WITHOUT POLUTING our modules
    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(
            receiveCompletion: { result in
                if case let .failure(error) = result {
                    logger.trace("Cache miss for url: \(url)")
                }
            }).eraseToAnyPublisher()
    }
    
    func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(
            receiveCompletion: { result in
                if case let .failure(error) = result {
                    logger.trace("failed to load url: \(url) with error: \(error.localizedDescription)")
                }
            }).eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        let startTime = CACurrentMediaTime()
        return handleEvents(
            receiveSubscription: { _ in
                // Starts the request
                logger.trace("Starting loading url: \(url)")
            },
            receiveCompletion: { result in
                let elapsed = CACurrentMediaTime() - startTime
                logger.trace("Finished loading url: \(url) in \(elapsed) seconds")
            }).eraseToAnyPublisher()
    }
}
