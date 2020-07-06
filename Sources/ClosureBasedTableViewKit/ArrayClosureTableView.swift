//
//  ArrayClosureTableView.swift
//  ClosureBasedTableViewKit
//
//  Created by Steve Sheets on 4/24/20.
//  Copyright © 2020 Steve Sheets. All rights reserved.
//

import Cocoa

// MARK: - Class

/// Closure based Table View to manage array of objects
public class ArrayClosureTableView: NSTableView, NSTableViewDelegate, NSTableViewDataSource {

// MARK: - Typealiases
    
    /// Closure type that is passed nothing, and returns an Array.
    public typealias ReturnArrayClosure = () -> [Any]

    /// Closure type that is passed nothing, and returns an single item.
    public typealias ReturnItemClosure = () -> Any

    /// Closure type that is passed an Int, and returns nothing.
    public typealias InformIntClosure = (Int) -> Void

    /// Closure type that is passed an Array, and returns nothing.
    public typealias InformArrayClosure = ([Any]) -> Void

    /// Closure type that is passed two Ints, and returns nothing.
    public typealias InformDoubleIntClosure = (Int, Int) -> Void

// MARK: - Properties
    
    /// Optional closure to return array to use
    public var arrayDataSource: ReturnArrayClosure?
    
    /// Optional closure to create Item
    public var newItemDataSource: ReturnItemClosure?

    /// Optional closure to keep track of current selected row
    public var selectionChangedEvent: InformIntClosure?

    /// Optional closure to change array
    public var arrayChangedEvent: InformArrayClosure?
    
// MARK: - Private Properties
    
    var addButton: NSButton?
    
    var subtractButton: NSButton?
    
// MARK: - Lifecycle Methods
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        dataSource = self
        delegate = self
        allowsMultipleSelection = true
        allowsEmptySelection = true
        allowsColumnSelection = false
        allowsColumnReordering = true
        allowsColumnResizing = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        dataSource = self
        delegate = self
        allowsMultipleSelection = true
        allowsEmptySelection = true
        allowsColumnSelection = false
        allowsColumnReordering = true
        allowsColumnResizing = true
    }
    
// MARK: - NSTableViewDelegate Methods
    
    public func tableViewSelectionDidChange(_ notification: Notification) {
        checkSelection()
        
        guard let event = selectionChangedEvent else { return }
     
        event(self.selectedRow)
    }
    
    public func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    
// MARK: - NSTableViewDataSource Methods
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        guard let source = arrayDataSource else { return 0 }
            
        let list = source()
            
        return list.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let source = arrayDataSource, let arrayColumn = tableColumn as? ArrayClosureTableColumn, let cellSource = arrayColumn.cellDataSource else { return nil }
        
        let list = source()
        
        guard row >= 0,  row < list.count else { return nil }

        let item = list[row]
        return cellSource(item)
    }
    
    public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard let source = arrayDataSource, let arrayColumn = tableColumn as? ArrayClosureTableColumn, let event = arrayColumn.editCellEvent, let object = object as? String else { return }
        
        let list = source()
        
        guard row >= 0,  row < list.count else { return }
    
        let item = list[row]
            
        event(item, object)
    }
    
    public func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let changed = arrayChangedEvent, tableView.sortDescriptors.count >= 1, let source = arrayDataSource else { return }
        
        let sort = tableView.sortDescriptors[0]
        let list = source()
        
        guard let key = sort.key, let column = findColumn(referral: key), let convert = column.cellDataSource else { return }
        
        let flag = sort.ascending
        
        let newList = list.sorted(by: { item1, item2 in
            let str1 = convert(item1)
            let str2 = convert(item2)
            
            if flag {
                return str1 < str2
            }
            else {
                return str1 > str2
            }
        })
        
        changed(newList)
        reloadData()
    }

    
// MARK: - Public Methods
    
    /// Connect Add Button to table
    /// - Parameter button: NSButton to use
    public func linkAddButton(_ button: NSButton?) {
        guard let button = button else { return }
        
        addButton = button

        button.target = self
        button.action = #selector(ArrayClosureTableView.addItemAction)
    }
    
    /// Connect Subtract Button to table
    /// - Parameter button: NSButton to use
    public func linkSubtractButton(_ button: NSButton?) {
        guard let button = button else { return }

        subtractButton = button

        button.target = self
        button.action = #selector(ArrayClosureTableView.subtractItemAction)
        
        checkSelection()
    }
    
    /// Check the selection status of buttons
    public func checkSelection() {
        guard let button = subtractButton else { return }
        
        button.isEnabled = selectedRow != -1
    }
    
    /// Find Column with given referral
    /// - Parameter referral: String containing identifier
    /// - Returns: ArrayClosureTableColumn with given referral
    public func findColumn(referral: String) -> ArrayClosureTableColumn? {
        guard referral.count>0 else { return nil }

        for column in tableColumns {
            if let arrayColumn = column as? ArrayClosureTableColumn {
                if referral == arrayColumn.referral {
                    return arrayColumn
                }
            }
        }

        return nil
    }
    
    /// Add Column closures details
    /// - Parameters:
    ///   - referral: String containing identifier
    ///   - cell: Closure to invoke to convert item into string
    ///   - edit: Closre to invoke when cell been edited
    public func column(referral: String, cell: ArrayClosureTableColumn.ObjectToStringClosure?, edit: ArrayClosureTableColumn.InformObjectStringClosure? = nil) {
        guard let arrayColumn = findColumn(referral: referral) else { return }
        
        arrayColumn.cellDataSource = cell
        arrayColumn.editCellEvent = edit
    }
    
    /// Add Item to list
    public func addItem() {
        guard let source = arrayDataSource, let newSource = newItemDataSource, let changed = arrayChangedEvent else { return }
        
        var list = source()
        let item = newSource()

        list.append(item)
        
        changed(list)
        reloadData()
    }
    
    /// Subtract selected Items to list
    public func subtractItem() {
        guard let source = arrayDataSource, let changed = arrayChangedEvent else { return }
        
        let index = selectedRowIndexes
        var list = source()

        for n in index.reversed() {
            list.remove(at: n)
        }

        changed(list)
        reloadData()
    }
    
// MARK: - Objective-C Actions
    
    /// Invoked closure when user clicks on Add button
    /// - Parameter sender: ignored
    @objc public func addItemAction(sender: AnyObject) {
        addItem()
    }

    /// Invoked closure when user clicks on Subtract button
    /// - Parameter sender: ignored
    @objc public func subtractItemAction(sender: AnyObject) {
        subtractItem()
    }

}
