//
//  Endpoint.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 27.06.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import Foundation

struct Endpoint {
    var name: String
    var url: String
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}