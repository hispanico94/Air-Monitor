//
//  Current.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 08/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

struct World { }

#if RELEASE
let Current = World()
#else
var Current = World()
#endif
