//
//  ManagedObjectProtocol.swift
//  CoreData Test
//
//  Created by Bruno Fernandes on 18/04/19.
//  Copyright © 2019 bfs. All rights reserved.
//

import CoreData

public protocol ManagedObjectProtocol {
    associatedtype Entity
    func toEntity() -> Entity?
}

public protocol ManagedObjectConvertible {
    associatedtype ManagedObject: NSManagedObject, ManagedObjectProtocol

    func toManagedObject(in context: NSManagedObjectContext) -> ManagedObject?
}

extension ManagedObjectProtocol where Self: NSManagedObject {

    public static func getOrCreateSingle(with id: String, from context: NSManagedObjectContext) -> Self {
        let result = single(with: id, from: context) ?? insert(in: context)
        result.setValue(id, forKey: "id")
        return result
    }

    public static func single(from context: NSManagedObjectContext, with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Self? {
        return fetch(from: context, with: predicate, sortDescriptors: sortDescriptors, fetchLimit: 1)?.first
    }

    public static func single(with id: String, from context: NSManagedObjectContext) -> Self? {
        let predicate = NSPredicate(format: "id == %@", id)
        return single(from: context, with: predicate, sortDescriptors: nil)
    }

    public static func insert(in context: NSManagedObjectContext) -> Self {
        return Self(context: context)
    }

    public static func fetch(from context: NSManagedObjectContext, with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, fetchLimit: Int?) -> [Self]? {

        let fetchRequest = Self.fetchRequest()
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false

        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }

        var result: [Self]?
        context.performAndWait { () -> Void in
            do {
                result = try context.fetch(fetchRequest) as? [Self]
            } catch {
                result = nil
                //Report Error
                print("CoreData fetch error \(error)")
            }
        }
        return result
    }
}
