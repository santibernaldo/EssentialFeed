//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/7/24.
//

import UIKit
import CoreData
import EssentialFeed

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
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteFeedLoader = RemoteFeedLoader(client: httpClient, url: remoteURL)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: FeedLoaderWithFallbackComposite(
                    primary: FeedLoaderCacheDecorator(
                        decoratee: remoteFeedLoader,
                        cache: localFeedLoader),
                    fallback: localFeedLoader),
                imageLoader: FeedImageDataLoaderWithFallbackComposite(
                    primary: localImageLoader,
                    fallback: FeedImageDataLoaderCacheDecorator(
                        decoratee: remoteImageLoader,
                        cache: localImageLoader))))
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
}
