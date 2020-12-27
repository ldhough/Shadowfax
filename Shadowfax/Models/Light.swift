//
//  Light.swift
//  Shadowfax
//
//  Created by Lannie Hough on 11/12/20.
//

import Foundation

class SfaxLight {
    
    var light:Light
    
    init(light: Light) {
        self.light = light
    }
    
    //Utility functions
    
    static func makePointLight(position: float3 = [0, 0, 0],
                               color: float3 = [1, 1, 1],
                               intensity: Float = 1,
                               attenuation: float3 = [1, 0, 0]) -> Light {
        var light = Light(position: [0, 0, 0],
                          color: [1, 1, 1],
                          intensity: 1,
                          attenuation: [1, 0, 0])
        return light
    }
    
}
