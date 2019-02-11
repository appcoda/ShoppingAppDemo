//
//  ShoppingList.swift
//  InAppComm
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation

struct ShoppingList {
    var id: Int?
    var name: String?
    var editTimestamp: TimeInterval?
    var items = [String]()
}



struct ShoppingListsManager {
    var lists = [ShoppingList]()
    var currentID = 0
    
    
    mutating func add(list: ShoppingList) {
        lists.append(list)
        sortLists()
    }
    
    
    mutating func updateItems(inListWithID id: Int, items: [String]) {
        var index: Int?
        for i in 0..<lists.count {
            if let listID = lists[i].id {
                if listID == id {
                    index = i
                    break
                }
            }
        }
        
        if let index = index {
            lists[index].items = items
            lists[index].editTimestamp = Date.timeIntervalSinceReferenceDate
            sortLists()
        }
    }
    
    
    mutating func getNextListID() -> Int {
        currentID += 1
        return currentID
    }
    
    
    mutating func sortLists() {
        lists = lists.sorted { (list1, list2) -> Bool in
            guard let timestamp1 = list1.editTimestamp, let timestamp2 = list2.editTimestamp else { return false }
            return timestamp1 > timestamp2
        }
    }
    
    
    func getItemsCount(atIndex index: Int) -> Int {
        return lists[index].items.count
    }
    
    
    func getFormattedEditedTimestamp(listIndex: Int) -> String? {
        if let edited = lists[listIndex].editTimestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy, HH:mm:ss"
            return dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: edited))
        } else {
            return nil
        }
    }
}
