# Sample Project for CoreData updating

Goal: Updating CoreData Graph with *Ordered To-Many Relationship* via JSON files using Swift `Decodable` and background contexts that sync with the main context using CoreData constraints and Merge Policies.

## General Setup:
- A single `ParentObject` has multiple `ChildObject` in a `children` property. A table in the App shows them.
- The `name` property is the unique identifier and set as constraint in CoreData.
- The complete list of ChildObjects are loaded from JSON files, there are "Sample1" and "Sample2".

## What happens when a sampe is loaded:
- Parent in the `TestViewController` is in the `viewContext`, and the table shows its `children` which are also in the viewContext. Updating the interface sets it via DiffableDataSource and Snapshots.
- When updating, a backgroundContext is used, *new* `childObjects` are generated
- Those objects are set via the setter to the existing `parentObject` that is fetched from the background context.
- The background context saves, so the objects get merged and the changes are applied to the viewContext.
- In theory the table should show the state of the viewContext, which got merged from the backgroundContext.

## What actually happens:
- I can't get the state of the background contexts with all relationships over to the viewContext. I don't know why not.
- If I load on top of full list, it gets empty.
- If I load on top of an empty list, it gets filled.
- The order is random, even though it's suposed to be an `OrderedSet`
- If there is an object that is in both the old and the new list, even stranger things happen...

My guess is that the error is in the accessor for `children` in `ParentObject`. But I don't know how it's supposed to look. Thanks for helping me understand this.
