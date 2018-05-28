//
//  Loader.swift
//  VaultPopover
//
//  Created by James on 4/23/18.
//  Copyright © 2018 porterjamesj. All rights reserved.
//

import Foundation

class Loader {
    
    let cipher: Cipher
    
    init(key: String, options: [String: Any]) {
        self.cipher = Cipher(secret: key)        
    }
}
