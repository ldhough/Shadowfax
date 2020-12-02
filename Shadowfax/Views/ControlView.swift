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
                  arrowDirection: CardinalDirections) -> some View {//,
                  //doAction: @escaping () -> Void) -> some View {
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
//        .onTapGesture {
//            doAction()
//
//        }
    }
    
    @GestureState private var pressingUp = false
    @GestureState private var panning = false
    
//    func ges() -> DragGesture {
//        DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                                .updating($pressingUp) { value, state, _ in
//                                    sfaxScene.interactions.interactFunctions["forward"]!.1 = true
//                                }.onEnded({ _ in
//                                    sfaxScene.interactions.interactFunctions["forward"]!.1 = false
//                                })
//    }
    
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
                                })//.simultaneously(with:
                                                    //DragGesture(minimumDistance: 0, coordinateSpace: .local))
                            )
                    //.gesture(SimultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .local), DragGesture(minimumDistance: 0, coordinateSpace: .local))
//                arrowKey(arrowDirection: .top).modifier(TapReleaseModifier(tap: {
//                    print("set true")
//                    sfaxScene.interactions.interactFunctions["forward"]!.1 = true
//                }, release: {
//                    print("set false")
//                    sfaxScene.interactions.interactFunctions["forward"]!.1 = false
//                }))
//                arrowKey(arrowDirection: .top).modifier(TapAndReleaseModifier(tapAction: {
//                                                                                print("set true")
//                                                                                sfaxScene.interactions.interactFunctions["forward"]!.1 = true}
//                                                                             , releaseAction: {}))
//                Button(action: {
//                    print("set false")
//                    sfaxScene.interactions.interactFunctions["forward"]!.1 = false
//                }) {
//                    arrowKey(arrowDirection: .top)
//                }.onTapGesture {
//                    print("set true")
//                    sfaxScene.interactions.interactFunctions["forward"]!.1 = true
                //}
//                .modifier(TapAndReleaseModifier(tapAction: {
//                                                    print("set true")
//                                                    sfaxScene.interactions.interactFunctions["forward"]!.1 = true}
//                                                 , releaseAction: {}))
                
                
//                arrowKey(arrowDirection: .top)
//                    .modifier(TapAndReleaseModifier(tapAction: {
//                    print("set true")
//                    sfaxScene.interactions.interactFunctions["forward"]!.1 = true
//                }, releaseAction: {
//                    print("set false")
//                    sfaxScene.interactions.interactFunctions["forward"]!.1 = false
//                }))
//                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)//LongPressGesture(minimumDuration: 0)
//                                //.sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
//                                .updating($pressingUp) { value, state, _ in
//
//                                    //value.location
//                                    if abs(value.startLocation.x - value.location.x) < 10 {
//                                    sfaxScene.interactions.interactFunctions["forward"]!.1 = true
//                                    } else {
//                                        sfaxScene.interactions.interactFunctions["forward"]!.1 = false
//                                    }
//                                }.onEnded({ _ in
//                                    sfaxScene.interactions.interactFunctions["forward"]!.1 = false
//                                }))
                //LongPressGesture(minimumDuration: 0, maximumDistance: 0).onEnded(<#T##action: (Bool) -> Void##(Bool) -> Void#>)
            }
            HStack {
                arrowKey(arrowDirection: .left).padding([.bottom])
                    //.ge
                arrowKey(arrowDirection: .bottom).padding([.bottom])
                arrowKey(arrowDirection: .right).padding([.bottom])
            }
        }.padding([.trailing])//.gesture(
//            DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                .updating($panning) { value, state, _ in
//
//                    print("DOING PANNING")
//                }.onEnded({ _ in
//                    print("END PANNING")
//                })
//        )
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
                        let sensitivity:CGFloat = CGFloat(sfaxScene.scene.camera.sensitivity)
                        let screenWidth = UIScreen.main.bounds.width
                        let screenHeight = UIScreen.main.bounds.height
                        let distanceTraveledHoriz = value.location.x-lastPanPoint.x
                        let distanceTraveledVert = value.location.y-lastPanPoint.y
                        lastPanPoint = value.location
                        let percentTraveledHoriz = abs(distanceTraveledHoriz) / screenWidth
                        let percentTraveledVert = abs(distanceTraveledVert) / screenHeight
                        let horizAngle = (distanceTraveledHoriz > 0 ? 180*sensitivity : -180*sensitivity) * percentTraveledHoriz
                        let vertAngle = (distanceTraveledVert > 0 ? 180*sensitivity : -180*sensitivity) * percentTraveledVert
                        //var val = (self.scene.camera.position.z > 0 ? (-) : (+))(SfaxMath.degreesToRadians(Float(vertAngle)), self.scene.camera.rotation.x)
                        sfaxScene.scene.camera.rotation = [SfaxMath.degreesToRadians(Float(vertAngle)) + sfaxScene.scene.camera.rotation.x, //camera.position.z > 0 ? (-) : (+)
                                                      SfaxMath.degreesToRadians(Float(horizAngle)) + sfaxScene.scene.camera.rotation.y,
                                                      0]
                        print("DOING PANNING")
                    }.onEnded({ _ in
                        panStart = nil
                        lastPanPoint = nil
                        print("END PANNING")
                    })
            )
            //Color.white
            HStack {
//                Spacer()
                arrowKeys().padding()
                Spacer()
            }
        }.ignoresSafeArea()
    }
}

var panStart:CGPoint!
var lastPanPoint:CGPoint!

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

struct TapAndReleaseModifier: ViewModifier {
    let tapAction:() -> Void
    let releaseAction:() -> Void
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture(minimumDuration: 0,
                                pressing: { _ in
                                },
                                perform: {tapAction()})
            .simultaneousGesture(TapGesture().onEnded({
                releaseAction()
            }))
//            .gesture(TapGesture().onEnded(releaseAction))
//            .onLongPressGesture(minimumDuration: 0,
//                                pressing: {_ in},
//                                perform: {
//                                    tapAction()
//                                })
//            .onTapGesture {
//                tapAction()
//            }
    }
}

