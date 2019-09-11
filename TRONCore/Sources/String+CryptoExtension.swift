//
//  String+Extension.swift
//  TRONCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public extension String {
    var isValidTRONAddress: Bool {
        return Base58Check.valid(self, version: TRONCore.pubkeyhash)
    }
}
