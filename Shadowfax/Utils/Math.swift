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
    
    //Get upper left part of a 4x4 matrix
    static func upperLeft(_ mat:float4x4) -> float3x3 {
        return float3x3([
            [mat[0].x, mat[1].x, mat[2].x],
            [mat[0].y, mat[1].y, mat[2].y],
            [mat[0].z, mat[1].z, mat[2].z]
        ])
    }
    
}

extension Float {
    static var halfPi:Float = .pi / 2
    static var twoPi:Float = .pi * 2
}

extension CGFloat {
    static var halfPi:CGFloat = .pi / 2
    static var twoPi:CGFloat = .pi * 2
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
            [0, cos(angle), sin(angle), 0],
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
    
    init(eye: float3, center: float3, up: float3) {
      let z = normalize(center - eye)
      let x = normalize(cross(up, z))
      let y = cross(z, x)
      
      let X = float4(x.x, y.x, z.x, 0)
      let Y = float4(x.y, y.y, z.y, 0)
      let Z = float4(x.z, y.z, z.z, 0)
      let W = float4(-dot(x, eye), -dot(y, eye), -dot(z, eye), 1)
      
      self.init()
      columns = (X, Y, Z, W)
    }
    
    init(l: Float, r: Float, bottom: Float, top: Float, near: Float, far: Float) {
      let X = float4(2 / (r - l), 0, 0, 0)
      let Y = float4(0, 2 / (top - bottom), 0, 0)
      let Z = float4(0, 0, 1 / (far - near), 0)
      let W = float4((l + r) / (l - r),
                     (top + bottom) / (bottom - top),
                     near / (near - far),
                     1)
      self.init()
      columns = (X, Y, Z, W)
    }

}

extension float3x3 {
    
  init(normalFrom4x4 matrix: float4x4) {
    self.init()
    columns = SfaxMath.upperLeft(matrix).inverse.transpose.columns
  }
    
}

