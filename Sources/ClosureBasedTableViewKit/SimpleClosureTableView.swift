//
//  SimpleClosureTableView.swift
//  ClosureBasedTableViewKit
//
//  Created by Steve Sheets on 4/24/20.
//  Copyright © 2020 Steve Sheets. All rights reserved.
//

import Cocoa

// MARK: - Class

/// Simpliest style closure based Table View
public class SimpleClosureTableView: NSTableView, NSTableViewDelegate, NSTableViewDataSource {

// MARK: - Typealiases
    
    /// Closure type that is passed nothing, and returns Int.
    public typealias ReturnIntClosure = () -> Int

    /// Closure type that is passed nothing, and returns an Array.
    public typealias ReturnArrayClosure = () -> [Any]

    /// Closure type that is passed an Int, and returns nothing.
    public typealias InformIntClosure = (Int) -> Void

    /// Closure type that is passed an Int, and returns nothing.
    public typealias InformIntReturnStringClosure = (Int) -> String

// MARK: - Properties
    
    /// Optional closure to return number of items in table
    public var numberDataSource: ReturnIntClosure?
    
    /// Optional closure to return text, based on row number
    public var textDataSource: InformIntReturnStringClosure?
    
    /// Optional closure to return array to use for closure
    public var arrayDataSource: ReturnArrayClosure?
    
    /// Optional closure to keep track of current selected item
    public var selectionChangedEvent: InformIntClosure?

    /// Optional closure to keep track of double clicking on row
    public var doubleClickEvent: InformIntClosure?

// MARK: - Lifecycle Methods
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        dataSource = self
        delegate = self
        allowsMultipleSelection = false
        allowsEmptySelection = true
        allowsColumnSelection = false
        target = self
        doubleAction = #selector(tableViewDoubleAction)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        dataSource = self
        delegate = self
        allowsMultipleSelection = false
        allowsEmptySelection = true
        allowsColumnSelection = false
        target = self
        doubleAction = #selector(tableViewDoubleAction)
    }
    
// MARK: - NSTableViewDelegate Methods
    
    public func tableViewSelectionDidChange(_ notification: Notification) {
        guard let event = selectionChangedEvent else { return }
        
        event(self.selectedRow)
    }
    
    public func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
// MARK: - NSTableViewDataSource Methods
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        if let source = numberDataSource {
            return source()
        }
        else if let source = arrayDataSource {
            let list = source()
            
            return list.count
        }
        
        return 0
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let source = textDataSource {
            return source(row)
        }
        else if let source = arrayDataSource {
            let list = source()
            
            if row >= 0 && row < list.count {
                if let item = list[row] as? String {
                    return item
                }
            }
        }
        
        return nil
    }
    
// MARK: - Objective-C Actions
    
    /// Invoked closure when user double clicks on item
    /// - Parameter sender: ignored
    @objc func tableViewDoubleAction(sender: AnyObject) {
        guard let event = doubleClickEvent else { return }
        
        event(clickedRow)
    }

}
