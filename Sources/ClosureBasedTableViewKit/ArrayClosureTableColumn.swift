//
//  ArrayClosureTableColumn.swift
//  ClosureBasedTableViewKit
//
//  Created by Steve Sheets on 4/26/20.
//  Copyright © 2020 Steve Sheets. All rights reserved.
//

import Cocoa

// MARK: - Class

/// Closure based Table Column to manage array of objects
public class ArrayClosureTableColumn: NSTableColumn {
    
// MARK: - Typealiases

    /// Closure type that is passed item, and returns String.
    public typealias ObjectToStringClosure = (Any) -> String

    /// Closure type that is passed item and String, and returns nothing.
    public typealias InformObjectStringClosure = (Any, String) -> Void

// MARK: - Properties

    /// Inspectable string that identifies this column.
    @IBInspectable public var referral: String = ""
    
    /// Optional closure to convert item into string
    public var cellDataSource: ObjectToStringClosure?

    /// Optional closure to take string into item
    public var editCellEvent: InformObjectStringClosure?

}
