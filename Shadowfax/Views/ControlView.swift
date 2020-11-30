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
    
    @GestureState private var pressingUp = false //{
//        didSet {
//            if self.pressingUp == true {
//                sfaxScene.interactions.interactFunctions["forward"]!.1 = true
//            } else {
//                sfaxScene.interactions.interactFunctions["forward"]!.1 = false
//            }
//        }
//    }
    
    func arrowKeys() -> some View {
        VStack {
            Spacer()
            HStack {
                arrowKey(arrowDirection: .top)
                    .gesture(LongPressGesture(minimumDuration: 0)
                                .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                                .updating($pressingUp) { value, state, thing in
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
            sfaxScene.swiftUIMetalView//SwiftUIMetalView(metalView: MetalView())
            //Color.white
            HStack {
//                Spacer()
                arrowKeys().padding()
                Spacer()
            }
        }.ignoresSafeArea()
    }
}

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
