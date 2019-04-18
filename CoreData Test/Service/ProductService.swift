//
//  ProductService.swift
//  CoreData Test
//
//  Created by Bruno Fernandes on 17/04/19.
//  Copyright © 2019 bfs. All rights reserved.
//

import Foundation

public class ProductService {

    private let storage: StorageContext

    init(storage: StorageContext = CoreDataStorageContext.shared) {
        self.storage = storage
    }

    public func list(completion: @escaping (Result<[Product], Error>) -> Void) {
        self.storage.get(completion: completion)
    }

    public func set(product: Product, completion: @escaping (Bool) -> Void) {

        self.storage.update(entitites: [product]) { (error) in
            completion(error == nil)
        }
    }

    public func remove(product: Product, completion: @escaping (Bool) -> Void) {

        self.storage.delete(entity: product) { (error) in
            completion(error == nil)
        }
    }
}
