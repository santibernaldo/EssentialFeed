//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/7/24.
//

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
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var remoteFeedLoader = httpClient.getPublisher(url: remoteURL)

    private lazy var remoteImageLoader = {
        RemoteFeedImageDataLoader(client: httpClient)
    }()
    
    private lazy var localImageLoader = {
        LocalFeedImageDataLoader(store: store)
    }()
    
    private lazy var remoteURL: URL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeLocalImageLoaderWithRemoteFallback))
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                self.remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: self.localImageLoader, using: url)
            })
    }
    
    // AnyPublisher -> produces an array of FeedImage or an error
    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        // There are many Publishers we can create, one of them is 'Future'. It starts with a completionBlock, and once the work is done, is returns some result

        // The signature of the completion `load` expects is the same one of the ÁnyPublisher returned
        
        // Future fires would fire the request every time we call 'makeRemoteFeedLoaderWithLocallFallback', not when someone subscribes to it
        
        // So we defers the execution of it
        return remoteFeedLoader
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            // When fallback, the `load` of the localFeedLoader is called
            .fallback(to: localFeedLoader.loadPublisher)
    }
}

