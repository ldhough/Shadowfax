//
//  Math.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/28/20.
//

import simd
import MetalKit

typealias float2 = SIMD2<Float>
typealias float3 = SIMD3<Float>
typealias float4 = SIMD4<Float>

class SfaxMath {
    
    static func radiansToDegrees(_ rad: Float) -> Float {
        return (rad / Float.pi) * 180
    }
    
    static func degreesToRadians(_ deg: Float) -> Float {
        return (deg / 180) * Float.pi
    }
    
    static func rotateXYZ(_ angleX: Float, _ angleY: Float, _ angleZ: Float) -> float4x4 {
        return float4x4(rotationX: angleX) * float4x4(rotationY: angleY) * float4x4(rotationZ: angleZ)
    }
    
}

extension float4 {
    static var red:float4 {
        float4(1, 0, 0, 1)
    }
    static var green:float4 {
        float4(0, 1, 0, 1)
    }
    static var blue:float4 {
        float4(0, 0, 1, 1)
    }
    static var yellow:float4 {
        float4(1, 1, 0, 1)
    }
    static var purple:float4 {
        float4(1, 0, 1, 1)
    }
}

extension float4x4 {
    
    init(fov: Float, near: Float, far: Float, aspect: Float) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = far / (far - near)
        let X = float4( x,  0,  0,  0)
        let Y = float4( 0,  y,  0,  0)
        let Z = float4( 0,  0,  z, 1)
        let W = float4( 0,  0,  z * -near,  0)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    var identity:float4x4 {
        matrix_identity_float4x4
    }
    
    init(translation: float3) {
        let matrix = float4x4( //Translate
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [translation.x, translation.y, translation.z, 1]
        )
        self = matrix
    }

    init(scaling: float3) {
        let matrix = float4x4( //Scale
            [scaling.x, 0, 0, 0],
            [0, scaling.y, 0, 0],
            [0, 0, scaling.z, 0],
            [0, 0, 0, 1]
        )
        self = matrix
    }

    init(rotationX angle: Float) {
        let matrix = float4x4( //Rotate x
            [1, 0, 0, 0],
            [1, cos(angle), sin(angle), 0],
            [0, -sin(angle), cos(angle), 0],
            [0, 0, 0, 1]
        )
        self = matrix
    }

    init(rotationY angle: Float) {
        let matrix = float4x4( //Rotate y
            [cos(angle), 0, -sin(angle), 0],
            [0, 1, 0, 0],
            [sin(angle), 0, cos(angle), 0],
            [0, 0, 0, 1]
        )
        self = matrix
    }

    init(rotationZ angle: Float) {
        let matrix = float4x4( //Rotate z
            [cos(angle), sin(angle), 0, 0],
            [-sin(angle), cos(angle), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
        self = matrix
    }

}

