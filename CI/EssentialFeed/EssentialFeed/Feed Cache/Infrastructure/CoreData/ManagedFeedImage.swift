//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 16/4/24.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    // This is a implementation detail of the CoreData module.
    
    // We have a copy of the FeedImage, but with CoreData implementation details, that FeedImage shouldn't know. So these implementation details doesn't affect the FeedImage, nor is not re-compiled again. Its in a different module.
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        if let data = context.userInfo[url] as? Data { return data }

        return try first(with: url, in: context)?.data
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
            let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
            request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
            return try context.fetch(request).first
        }
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let images = NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            managed.data = context.userInfo[local.url] as? Data
            return managed
        })
        
        // STAR: We remove the userInfo objects, so we don't keep in memory thousands of images
        // STAR: We don't want to hold hundreds/thousands of images
        context.userInfo.removeAllObjects()
        
        return images
    }
    
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
    
    // STAR: Every time we delete the FeedImage, this method is invoked
    // STAR: Performed optimization on the Infrastructure
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        // STAR: We store the data in a managedObjectContext, which is not persisted to disk
        // STAR: Just a temporary lookup dictionary
        managedObjectContext?.userInfo[url] = data
    }
}
