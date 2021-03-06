// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustKeystore

struct TransactionSection {
    let title: String
    let items: [Transaction]
}

class TransactionsStorage {

    let realm: Realm

    var transactionsUpdateHandler: () -> Void = {}

    var transactions: Results<Transaction> {
        return realm.objects(Transaction.self).filter(NSPredicate(format: "id!=''")).sorted(byKeyPath: "date", ascending: false)
    }

    var transactionSections: [TransactionSection] = []

    private var transactionsObserver: NotificationToken?

    init(
        realm: Realm
    ) {
        self.realm = realm
        transactionsObservation()
    }

    var completedObjects: [Transaction] {
        return transactions.filter { $0.state == .completed }
    }

    var pendingObjects: [Transaction] {
        return transactions.filter { $0.state == TransactionState.pending }
    }

    func get(forPrimaryKey: String) -> Transaction? {
        return realm.object(ofType: Transaction.self, forPrimaryKey: forPrimaryKey)
    }

    func add(_ items: [Transaction]) {
        try! realm.write {
            realm.add(items, update: true)
        }
    }

    private func tokens(from transactions: [Transaction]) -> [Token] {
        let tokens: [Token] = transactions.flatMap { transaction in
            guard
                let operation = transaction.localizedOperations.first,
                let contract = Address(string: operation.contract ?? ""),
                let name = operation.name,
                let symbol = operation.symbol
                else { return nil }
            return Token(
                address: contract,
                name: name,
                symbol: symbol,
                decimals: operation.decimals
            )
        }
        return tokens
    }

    func delete(_ items: [Transaction]) {
        try! realm.write {
            realm.delete(items)
        }
    }

    func update(state: TransactionState, for transaction: Transaction) {
        try! realm.write {
            let tempObject = transaction
            tempObject.internalState = state.rawValue
            realm.add(tempObject, update: true)
        }
    }

    func removeTransactions(for states: [TransactionState]) {
        let objects = realm.objects(Transaction.self).filter { states.contains($0.state) }
        try! realm.write {
            realm.delete(objects)
        }
    }

    func deleteAll() {
        try! realm.write {
            realm.delete(realm.objects(Transaction.self))
        }
    }

    func updateTransactionSection() {
        transactionSections = mappedSections(for: Array(transactions))
    }

    func mappedSections(for transactions: [Transaction]) -> [TransactionSection] {
        var items = [TransactionSection]()
        let headerDates = NSOrderedSet(array: transactions.map { TransactionsViewModel.titleFormmater.string(from: $0.date ) })
        headerDates.forEach {
            guard let dateKey = $0 as? String else {
                return
            }
            let filteredTransactionByDate = Array(transactions.filter { TransactionsViewModel.titleFormmater.string(from: $0.date ) == dateKey })
            items.append(TransactionSection(title: dateKey, items: filteredTransactionByDate))
        }
        return items
    }

    private func transactionsObservation() {
        transactionsObserver = transactions.observe { [weak self] _ in
            self?.updateTransactionSection()
            self?.transactionsUpdateHandler()
        }
    }
}
