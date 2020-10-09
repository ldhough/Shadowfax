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

extension float4x4 {
    
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

