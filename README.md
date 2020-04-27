# Sample Project for CoreData updating

Goal: Updating CoreData Graph with *Ordered To-Many Relationship* via JSON files using Swift `Decodable` and background contexts that sync with the main context using CoreData constraints and Merge Policies.

## General Setup:
- A single `ParentObject` has Multiple `ChildObject` ina `children` Property. A table in the App shows them.
- The `name` property is the uniqui identifier and set as constraint in CoreData
- The complete List of Child Objects are loaded from JSON files, there are two "Sample1" and "Sample2"

## What happens when a sampe is loaded:
- Parent in the `TestViewController` is in the `viewContext`, and the table shows its `children` which are also in the viewContext. Updating the Interface sets it via diffable DataSource and Snapshots.
- When updating, a background context is used, *new* `childObjects` are generated
- Those objects are set via the setter to the existing `parentObject` that is fetched from the background context
- The background context saves, so theobjects get merged and the changes are propagated to the viewContext
- In theory the table should show the state of the viewContext, which got merged from the backgroundContext.

## What actually happens:
- I can't get the state of the background contexts with all relationships over to the viewContext. I don't know why.
- If you load on top of full list, it gets empty.
- If you load on top of an empty list, it gets filled.
- The order is random, even though it's souupsed to be an `OrderedSet`
- if there is an object that is in both the old and the new list, even stranger things happen...

My guess is that the error is in the accessor for `children` in `ParentObject`. But I don't know how it's supposed to look. Please help me understand this.
