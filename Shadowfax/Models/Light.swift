//
//  Light.swift
//  Shadowfax
//
//  Created by Lannie Hough on 11/12/20.
//

import Foundation

class Lighting {
    
    
    
    //Utility functions
    
    static func makePointLight() -> Light {
        var light = Light(position: [0, 0, 0],
                          color: [1, 1, 1],
                          intensity: 1,
                          attenuation: [1, 0, 0])
        return light
    }
    
}
