//
//  Product.swift
//  CoreData Test
//
//  Created by Bruno Fernandes on 17/04/19.
//  Copyright © 2019 bfs. All rights reserved.
//

import CoreData

func get<T, U>(path: KeyPath<T, U>, value: U) {

}

public struct Product {
    var id: String
    var name: String
}

extension Product: Storable {

    public func toManagedObject(in context: NSManagedObjectContext) -> ProductEntity? {
        let product = ProductEntity.getOrCreateSingle(with: id, from: context)
        product.id = id
        product.name = name

        return product
    }

}

public class ProductEntity: NSManagedObject {}

extension ProductEntity: ManagedObjectProtocol {

    public func toEntity() -> Product? {
        return Product(id: id, name: name)
    }
}

extension ProductEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductEntity> {
        return NSFetchRequest<ProductEntity>(entityName: "Product")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String

}

