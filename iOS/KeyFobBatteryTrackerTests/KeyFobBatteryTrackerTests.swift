import XCTest
@testable import KeyFobBatteryTracker

@MainActor
final class KeyFobBatteryTrackerTests: XCTestCase {
    var store: FobStore!

    override func setUp() {
        super.setUp()
        store = FobStore()
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, FobStore.freeLimit)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        let added = store.add(Fob(name: "Test", detail: "d", date: Date()))
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<20 {
            _ = store.add(Fob(name: "Item \(i)", detail: "d", date: Date()))
        }
        XCTAssertEqual(store.items.count, FobStore.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<20 {
            _ = store.add(Fob(name: "Item \(i)", detail: "d", date: Date()))
        }
        XCTAssertGreaterThan(store.items.count, FobStore.freeLimit)
    }

    func testDeleteRemovesItem() {
        let item = Fob(name: "ToDelete", detail: "d", date: Date())
        _ = store.add(item)
        store.delete(id: item.id)
        XCTAssertFalse(store.items.contains(where: { $0.id == item.id }))
    }

    func testUpdateChangesFields() {
        var item = Fob(name: "Orig", detail: "d", date: Date())
        _ = store.add(item)
        item.name = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.name, "Updated")
    }

    func testCanAddMoreReflectsLimit() {
        while store.canAddMore {
            _ = store.add(Fob(name: "X", detail: "d", date: Date()))
        }
        XCTAssertFalse(store.canAddMore)
    }
}
