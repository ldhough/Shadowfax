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

class CONSTANTS {
    static let screen_size = UIScreen.main.bounds.size
    static let native_size = UIScreen.main.nativeBounds.size
}

class ButtonActions {
    
    static func up() {
        print("Up")
    }
    
    static func right() {
        print("Right")
    }
    
    static func left() {
        print("Left")
    }
    
    static func down() {
        print("Down")
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

struct ControlView: View {
    
    func arrowKey(buttonSize: CGSize = CGSize(width: CONSTANTS.screen_size.width/10,
                                              height: CONSTANTS.screen_size.width/10),
                  arrowDirection: CardinalDirections,
                  doAction: @escaping () -> Void) -> some View {
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
        .onTapGesture {
            doAction()
        }
    }
    
    func arrowKeys() -> some View {
        VStack {
            Spacer()
            HStack {
                arrowKey(arrowDirection: .top) {
                    ButtonActions.up()
                }
            }
            HStack {
                arrowKey(arrowDirection: .left) {
                    ButtonActions.left()
                }.padding([.bottom])
                arrowKey(arrowDirection: .bottom) {
                    ButtonActions.down()
                }.padding([.bottom])
                arrowKey(arrowDirection: .right) {
                    ButtonActions.right()
                }.padding([.bottom])
            }
        }.padding([.trailing])
    }
    
    var body: some View {
        ZStack {
            SwiftUIMetalView()
            //Color.white
            HStack {
                Spacer()
                arrowKeys()
            }
        }.ignoresSafeArea()
    }
}
