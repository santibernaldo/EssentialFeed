//
//  InboxFeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 25/4/24.
//

/*
 
 Insert
     - To empty cache stores data
     - To non-empty cache overrides previous value
     - Error (if possible to simulate, e.g., no write permission)

 - Retrieve
     - Empty cache works (before something is inserted)
     - Empty cache twice returns empty (no side-effects)
     - Non-empty cache returns data
     - Non-empty cache twice returns same data (retrieve should have no side-effects)
     - Error returns error (if possible to simulate, e.g., invalid data)
     - Error twice returns same error

 - Delete
     - Empty cache does nothing (cache stays empty and does not fail)
     - Inserted data leaves cache empty
     - Error (if possible to simulate, e.g., no write permission)

 - Side-effects must run serially to avoid race-conditions (deleting the wrong cache... overriding the latest data...)
 
 */
