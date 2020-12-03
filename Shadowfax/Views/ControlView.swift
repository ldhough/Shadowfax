//
//  ControlView.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import SwiftUI

/*
 SwiftUI UI components to use for buttons/interaction with scenes as well as supporting classes & structs
 */

struct ControlView: View {
    
    let sfaxScene:SfaxScene
    
    func arrowKey(buttonSize: CGSize = CGSize(width: CONSTANTS.screen_size.width/10,
                                              height: CONSTANTS.screen_size.width/10),
                  arrowDirection: CardinalDirections) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .foregroundColor(Color.gray)
                .opacity(0.4)
            Triangle()
                .scale(0.75)
                .foregroundColor(Color.black)
                .opacity(0.6)
                .rotationEffect(arrowDirection == .top ? Angle(degrees: 0.0) :
                                    arrowDirection == .bottom ? Angle(degrees: 180.0) :
                                    arrowDirection == .right ? Angle(degrees: 90.0)
                                    : Angle(degrees: 270.0))
        }
        .frame(width: buttonSize.width, height: buttonSize.width)
    }
    
    @GestureState private var pressingUp = false
    @GestureState private var panning = false
    
    func arrowKeys() -> some View {
        VStack {
            Spacer()
            HStack {
                arrowKey(arrowDirection: .top)
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .updating($pressingUp) { value, state, _ in
                                    sfaxScene.interactions.interactFunctions["forward"]!.1 = true
                                }.onEnded({ _ in
                                    sfaxScene.interactions.interactFunctions["forward"]!.1 = false
                                }))
            }
            HStack {
                arrowKey(arrowDirection: .left).padding([.bottom])
                arrowKey(arrowDirection: .bottom).padding([.bottom])
                arrowKey(arrowDirection: .right).padding([.bottom])
            }
        }.padding([.trailing])
    }
    
    var body: some View {
        ZStack {
            sfaxScene.swiftUIMetalView.gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .updating($panning) { value, state, _ in
                        if panStart == nil {
                            panStart = value.location
                            lastPanPoint = value.location
                        }
                        let sensitivity:CGFloat = CGFloat(sfaxScene.scene.camera.sensitivity) * 3
                        let screenWidth = UIScreen.main.bounds.width
                        let screenHeight = UIScreen.main.bounds.height
                        let distanceTraveledHoriz = value.location.x-lastPanPoint.x
                        let distanceTraveledVert = value.location.y-lastPanPoint.y
                        lastPanPoint = value.location
                        let percentTraveledHoriz = abs(distanceTraveledHoriz) / screenWidth
                        let percentTraveledVert = abs(distanceTraveledVert) / screenHeight
                        let horizAngleTraveled = (distanceTraveledHoriz > 0 ? 180*sensitivity : -180*sensitivity) * percentTraveledHoriz
                        let vertAngleTraveled = (distanceTraveledVert > 0 ? 180*sensitivity : -180*sensitivity) * percentTraveledVert
                        
                        var vertAngle = SfaxMath.degreesToRadians(Float(vertAngleTraveled)) + sfaxScene.scene.camera.rotation.x
                        let horizAngle = SfaxMath.degreesToRadians(Float(horizAngleTraveled)) + sfaxScene.scene.camera.rotation.y
                        
                        if vertAngle > .halfPi {
                            vertAngle = .halfPi
                        } else if vertAngle < -.halfPi {
                            vertAngle = -.halfPi
                        }
                        sfaxScene.scene.camera.rotation = [vertAngle,
                                                           horizAngle,
                                                           0]
                    }.onEnded({ _ in
                        panStart = nil
                        lastPanPoint = nil
                    })
            )
            HStack {
                arrowKeys().padding()
                Spacer()
            }
        }.ignoresSafeArea()
    }
}

fileprivate var panStart:CGPoint!
fileprivate var lastPanPoint:CGPoint!

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

enum CardinalDirections {
    case top
    case bottom
    case right
    case left
}
