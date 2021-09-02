//
//  SceneDelegate.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/28/20.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let sfSc = SfaxScene()
        
        //DESCRIBE SCENE
        
        var uniforms = Uniforms()
        let mesh = Models.importModel(sfSc.renderer.device, "planetsphere", "obj")
        let tex = Utils.loadTexture(imageName: "sun.png", device: sfSc.renderer.device) //tex
        sfSc.scene.addEntity(name: "Sun", mesh: mesh!, uniforms: &uniforms, texture: tex, obeysLight: false, isLight: true,
                        updateUniforms: { uniforms in
            uniforms.viewMatrix = sfSc.scene.camera.viewMatrix
            uniforms.projectionMatrix = sfSc.scene.camera.projMatrix
            let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
            uniforms.modelMatrix = notUpsideDown * float4x4(rotationY: SfaxMath.degreesToRadians(sfSc.renderer.timer*10.0))
        })
        
        //EARTH
        var uniformsEarth = Uniforms()
        let meshEarth = Models.importModel(sfSc.renderer.device, "planetsphere", "obj")
        let texEarth = Utils.loadTexture(imageName: "earth.png", device: sfSc.renderer.device)
        sfSc.scene.addEntity(name: "Earth", mesh: meshEarth!, uniforms: &uniformsEarth, texture: texEarth, updateUniforms: { uniforms in
            uniforms.viewMatrix = sfSc.scene.camera.viewMatrix
            uniforms.projectionMatrix = sfSc.scene.camera.projMatrix
            let scale = float4x4(scaling: [0.5, 0.5, 0.5])
            let moveOut = float4x4(translation: [4, 0, 0])
            let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
            let aroundSun = float4x4(rotationY: SfaxMath.degreesToRadians(sfSc.renderer.timer*5.0))
            let earthSpin = float4x4(rotationY: SfaxMath.degreesToRadians(sfSc.renderer.timer*20.0))
            uniforms.modelMatrix =  notUpsideDown * aroundSun * moveOut * earthSpin * scale
        })
        
        var uniformsMoon = Uniforms()
        let meshMoon = Models.importModel(sfSc.renderer.device, "planetsphere", "obj")
        let texMoon = Utils.loadTexture(imageName: "moon.png", device: sfSc.renderer.device)
        sfSc.scene.addEntity(name: "Moon", mesh: meshMoon!, uniforms: &uniformsMoon, texture: texMoon, updateUniforms: { uniforms in
            uniforms.viewMatrix = sfSc.scene.camera.viewMatrix
            uniforms.projectionMatrix = sfSc.scene.camera.projMatrix
            let scale = float4x4(scaling: [0.3, 0.3, 0.3])
            let moveOut = float4x4(translation: [6, 0, 0])
            let moveOut2 = float4x4(translation: [1, 0, 0])
            //let moveIn = float4x4(translation: [-6, 0, 0])
            let moveIn2 = float4x4(translation: [-2, 0, 0])
            let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
            let aroundSun = float4x4(rotationY: SfaxMath.degreesToRadians(sfSc.renderer.timer*5.0))
            let aroundEarth = float4x4(rotationY: SfaxMath.degreesToRadians(sfSc.renderer.timer*15.0))
            uniforms.modelMatrix = notUpsideDown * aroundSun * moveOut * moveIn2 * aroundEarth * moveOut2 * scale
            
        })
        
        var uniformsSky = Uniforms()
        let meshSky = Models.importModel(sfSc.renderer.device, "planetsphere", "obj")
        let texSky = Utils.loadTexture(imageName: "StarsInSpace.png", device: sfSc.renderer.device)
        sfSc.scene.addEntity(name: "Skydome", mesh: meshSky!, uniforms: &uniformsSky, texture: texSky, obeysLight: false, isLight: false, updateUniforms: { uniforms in
            uniforms.viewMatrix = sfSc.scene.camera.viewMatrix
            uniforms.projectionMatrix = sfSc.scene.camera.projMatrix
            let scale = float4x4(scaling: [60.0, 60.0, 60.0])
            uniforms.modelMatrix = scale
        })
        
        sfSc.interactions.interactFunctions["forward"] = ({ sfSc in
            if sfSc.interactions.interactFunctions["forward"]!.1 == true {
                let prevPos = sfSc.scene.camera.position
                //Rotation describes how camera is looking into scene, use this to find xyz components of moving in that direction
                let distTraveled:Float = 0.1
                //let maxRad:Float = 2 * .pi
                let rot = sfSc.scene.camera.rotation
                var rotX, rotY, rotZ:Float
                rotX = rot.x //about x, cam up or down //pitch
                rotY = rot.y //about y, cam right or left //yaw
                rotZ = rot.z //don't care about this for now
                var dx, dy, dz:Float
                dx = sin(rotY) * distTraveled
                dz = cos(rotY) * distTraveled
                dy = 0.0
                dy = -(sin(rotX) * distTraveled)

                print("XYZ Rotation: \(String(rotX)), \(String(rotY)), \(String(rotZ))")
                print("XYZ Position: \(String(prevPos.x)), \(String(prevPos.y)), \(String(prevPos.z))")
                print("= = = = = = = = = = = = = = = = = = = = =")

                sfSc.scene.camera.position = [prevPos.x + dx, prevPos.y + dy, prevPos.z + dz]
                //sfSc.interactions.interactFunctions["forward"]!.1 = false
            }
        }, false)
        
        //END DESCRIBE SCENE
        
        //DESCRIBE SCENE TWO
        
        
//        let ptr:UnsafeMutablePointer<UnsafeMutablePointer<Float>?>?
//            = diamondSquareGenHeightmap(9, 1, 1000, 0.5, 0.5, 0.5, 0.5);
        
        let ptr:UnsafeMutableRawPointer? = diamondSquareGenHeightmap(9, 1, 1000, 0.5, 0.5, 0.5, 0.5);
//        let x = ptr?.load(fromByteOffset: 0, as: Float.self)
        
        let fStride = MemoryLayout<Float>.stride
        var array:[[Float]] = []
        for i in (0 ..< 9) {
            var subArray:[Float] = []
            for j in (0 ..< 9) {
                let number = ptr?.load(fromByteOffset: (i*(fStride*9))+(j*fStride), as: Float.self)
                subArray.append(number!)
            }
            array.append(subArray)
        }
        for sa in array {
            print(sa)
        }
        
//        print(x!)
//        let buffer = UnsafeRawBufferPointer(start: ptr, count: 81 * 4)
//
//        for (index, byte) in buffer.enumerated() {
//            let v:String = byte
//        }
        
//        let buffer:UnsafeMutableBufferPointer<UnsafeMutablePointer<Float>?>
//            = UnsafeMutableBufferPointer(start: ptr, count: 9)
//
//        let sArr:[[Float]] = []
        
        //while let a = buffer.baseAddress?.pointee {
//            print(a)
//            let things = buffer.compactMap({ ptr in
//                var fArr:[Float] = []
//                let subBuffer = UnsafeMutableBufferPointer(start: ptr, count: 9)
//                subBuffer.compactMap({ flt in
//                    fArr.append(flt)
//                })
//            })
        //}
        
        
        
//        while let a = ptr?.pointee {
//            print(a)
//            ptr += 1
//        }
        
//        let buffer:UnsafeMutableBufferPointer<UnsafeMutablePointer<Float>?>
//            = UnsafeMutableBufferPointer(start: ar, count: 9)
//        print(buffer) // addr of first element
//        let addrArr0 = buffer.baseAddress
//        print(addrArr0?.pointee)
//
//        let arr:[UnsafeMutablePointer<Float>?] = Array(buffer)
//        for row in arr {
//            print(row!)
//        }
//
//        var array:[[Float]] = []
//        for row in arr {
//            let buffer:UnsafeMutableBufferPointer<Float>
//                = UnsafeMutableBufferPointer(start: row, count: 9)
//            let rw:[Float] = Array(buffer)
//            array.append(rw)
//        }
//
//        for row in array {
//            var printStr = ""
//            for element in row {
//                printStr += "\(element) | "
//            }
//            print(printStr)
//        }
        //        let matrix = (0 ..< 9).map { row in
        //            UnsafeBufferPointer(start: ar, count: 9)
        //        }
        //        let s:String = matrix
                //print(ar)
                //print(ar?.pointee?.pointee)

        
        //END DESCRIBE SCENE TWO
        
        let solarSystemView = ControlView(sfaxScene: sfSc)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: solarSystemView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }

}
