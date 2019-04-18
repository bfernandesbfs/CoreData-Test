//
//  StorageContext.swift
//  CoreData Test
//
//  Created by Bruno Fernandes on 18/04/19.
//  Copyright © 2019 bfs. All rights reserved.
//

import Foundation

public protocol StorageContext {

    func get<Entity: Storable>(with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, fetchLimit: Int?, completion: @escaping (Result<[Entity], Error>) -> Void)
    func update<Entity: Storable>(entitites: [Entity], completion: @escaping (Error?) -> Void)
    func delete<Entity: Storable>(entity: Entity, completion: @escaping (Error?) -> Void)
}

extension StorageContext {

    func get<Entity: Storable>(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil, completion: @escaping (Result<[Entity], Error>) -> Void) {
        get(with: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit, completion: completion)
    }
}
