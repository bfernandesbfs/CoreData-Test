//
//  CoreDataStorageContext.swift
//  CoreData Test
//
//  Created by Bruno Fernandes on 17/04/19.
//  Copyright © 2019 bfs. All rights reserved.
//

import CoreData

public enum ProviderError: Error {
    case cannotFetch(String)
    case cannotSave(Error)
}

public final class CoreDataStorageContext {

    public static let shared = CoreDataStorageContext()

    private var errorHandler: (Error) -> Void = {_ in }

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataBase")
        container.loadPersistentStores(completionHandler: { [weak self](storeDescription, error) in
            if let error = error {
                NSLog("CoreData error \(error), \(String(describing: error._userInfo))")
                self?.errorHandler(error)
            }
        })
        return container
    }()

    private lazy var viewContext: NSManagedObjectContext = {
        let context:NSManagedObjectContext = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    private lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()

    private func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }

    private func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(block)
    }
}

extension CoreDataStorageContext: StorageContext {

    public func get<Entity: Storable>(with predicate: NSPredicate? = nil,
                                      sortDescriptors: [NSSortDescriptor]? = nil,
                                      fetchLimit: Int? = nil,
                                      completion: @escaping (Result<[Entity], Error>) -> Void) {

        performForegroundTask { context in

            do {
                let fetchRequest = Entity.ManagedObject.fetchRequest()
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = sortDescriptors
                if let limit = fetchLimit {
                    fetchRequest.fetchLimit = limit
                }

                let results = try context.fetch(fetchRequest) as? [Entity.ManagedObject]
                let items: [Entity] = results?.compactMap { $0.toEntity() as? Entity } ?? []
                completion(.success(items))

            } catch {
                let fetchError = ProviderError.cannotFetch("Cannot fetch error: \(error)")
                completion(.failure(fetchError))
            }

        }
    }

    public func update<Entity: Storable>(entitites: [Entity], completion: @escaping (Error?) -> Void) {

        performBackgroundTask { context in

            _ = entitites.compactMap { $0.toManagedObject(in: context)}

            do {
                try context.save()
                completion(nil)
            } catch {
                completion(ProviderError.cannotSave(error))
            }
        }
    }

    public func delete<Entity: Storable>(entity: Entity, completion: @escaping (Error?) -> Void) {

        performBackgroundTask { context in

            guard let object = entity.toManagedObject(in: context) else {
                return  completion(ProviderError.cannotSave(NSError(domain: "Delete", code: -1, userInfo: nil)))
            }

            context.delete(object)

            do {
                try context.save()
                completion(nil)
            } catch {
                completion(ProviderError.cannotSave(error))
            }

        }
    }
}
