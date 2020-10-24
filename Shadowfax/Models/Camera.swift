//
//  Camera.swift
//  Shadowfax
//
//  Created by Lannie Hough on 10/12/20.
//

import Foundation

class Camera {
    
    var sensitivity:Float = 0.5
    
    //View matrix properties
    var position:float3 = [0, 0, 0] {
        didSet { //Property observers on Camera properties allow entire view and model matrices to be directly updated without having to do anything except modifying the properties themselves
            self.viewMatrix = Camera.makeViewMatrix(pos: self.position,
                                                    rotX: self.rotation[0], rotY: self.rotation[1], rotZ: self.rotation[2])
        }
    }
    var rotation:float3 = [0, 0, 0] {
        didSet {
            self.viewMatrix = Camera.makeViewMatrix(pos: self.position,
                                                    rotX: self.rotation[0], rotY: self.rotation[1], rotZ: self.rotation[2])
        }
    }
    var scale:float3 = [1, 1, 1] {
        didSet {
            self.viewMatrix = Camera.makeViewMatrix(pos: self.position,
                                                    rotX: self.rotation[0], rotY: self.rotation[1], rotZ: self.rotation[2])
        }
    }
    //Projection matrix properties
    var fov:Float = 45.0 {
        didSet {
            self.projMatrix = Camera.makeProjectionMatrix(fovDegrees: self.fov, near: self.near, far: self.far, aspect: self.aspectRatio)
        }
    }
    var near:Float = 0.1 {
        didSet {
            self.projMatrix = Camera.makeProjectionMatrix(fovDegrees: self.fov, near: self.near, far: self.far, aspect: self.aspectRatio)
        }
    }
    var far:Float = 100 {
        didSet {
            self.projMatrix = Camera.makeProjectionMatrix(fovDegrees: self.fov, near: self.near, far: self.far, aspect: self.aspectRatio)
        }
    }
    
    init(aspect: Float) {
        self.aspectRatio = aspect
        self.viewMatrix = Camera.makeViewMatrix(pos: [0, 0, 0], rotX: 0, rotY: 0, rotZ: 0)
        self.projMatrix = Camera.makeProjectionMatrix(fovDegrees: 45.0, near: 0.1, far: 100, aspect: aspect)
    }
    
    var aspectRatio:Float {
        didSet {
            self.projMatrix = Camera.makeProjectionMatrix(fovDegrees: self.fov, near: self.near, far: self.far, aspect: self.aspectRatio)
        }
    }
    var viewMatrix:float4x4
    var projMatrix:float4x4
    
    //pos is translation
    class func makeViewMatrix(pos: float3, rotX: Float, rotY: Float, rotZ: Float) -> float4x4 {
        var viewMatrix:float4x4
        let rotation:float4x4 = SfaxMath.rotateXYZ(rotX, rotY, rotZ)//float4x4(rotationX: rotX) * float4x4(rotationY: rotY) * float4x4(rotationZ: rotZ)
        let posMatrix = float4x4(translation: pos)
        viewMatrix = posMatrix * rotation//rotation * posMatrix
        return viewMatrix.inverse
    }
    
    class func makeProjectionMatrix(fovDegrees: Float, near: Float, far: Float, aspect: Float) -> float4x4 {
        return float4x4(fov: SfaxMath.degreesToRadians(fovDegrees), near: near, far: far, aspect: aspect)
    }
    
}
