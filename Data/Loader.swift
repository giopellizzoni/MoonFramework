//
//  Loader.swift
//  Data
//
//  Created by Giovanni Pellizzoni on 02/07/20.
//  Copyright © 2020 Giovanni Pellizzoni. All rights reserved.
//

import Foundation


enum ContactsLoaderResult {
    case success([Employee])
    case failure(Error)
}

