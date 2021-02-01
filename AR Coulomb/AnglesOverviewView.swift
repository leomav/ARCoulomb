//
//  AnglesOverviewView.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 29/1/21.
//  Copyright © 2021 Leonidas Mavrotas. All rights reserved.
//

import UIKit

enum ForceType {
    case single
    case net
}

class AnglesOverviewView: UIStackView {
    
//    let FORCE_ARROW_TAIL_LENGTH: Float = 0.003
//    let NETFORCE_ARROW_TAIL_LENGTH: Float = 0.005
//    let ARROW_TAIL_WIDTH: Float = 0.0005
//    let HEAD_LENGTH: Float = 0.001
//    let HEAD_WIDTH: Float = 0.001
//    let ARC_RADIUS: Float = 0.002
    
    let FORCE_ARROW_TAIL_LENGTH: Float = 30
    let NETFORCE_ARROW_TAIL_LENGTH: Float = 50
    let ARROW_TAIL_WIDTH: Float = 2
    let HEAD_LENGTH: Float = 10
    let HEAD_WIDTH: Float = 8
    let ARC_RADIUS: Float = 10
    
    let ARC_COLOR: UIColor = UIColor.orange
    
    
    var forcesDrawings: [ForceDrawing] = [
        ForceDrawing(type: ForceType.single, angle: 0, color: .white, selected: false),
        ForceDrawing(type: ForceType.single, angle: 45.degreesToRadians(), color: .lightGray, selected: false),
        ForceDrawing(type: ForceType.single, angle: 90.degreesToRadians(), color: .darkGray, selected: false),
        ForceDrawing(type: ForceType.single, angle: 135.degreesToRadians(), color: .black, selected: true),
        ForceDrawing(type: ForceType.net, angle: 225.degreesToRadians(), color: .green, selected: false),
    ]
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        // Obtain the center point of the pie chart
        let center = CGPoint(
            x: bounds.width / 2,
            y: bounds.height / 2
        )
        
        let selectedForceDrawing = forcesDrawings.first { (f) -> Bool in
            f.selected == true
        }
        drawAngleArc(center: center, force: selectedForceDrawing!)
        
        drawForces(center: center)
        
    }

    // MARK: - Actions
    private func drawForces(center: CGPoint) {
        forcesDrawings.forEach{ f in
            self.drawForce(center: center, force: f)
        }
    }
    
    
    private func drawForce(center: CGPoint, force: ForceDrawing) {
        
        // Get the tail length
        let tailLength: Float = force.type == ForceType.single ? FORCE_ARROW_TAIL_LENGTH : NETFORCE_ARROW_TAIL_LENGTH
        
        // Find the end point based on the angle
        let end_x_Point = CGFloat(center.x) + CGFloat( tailLength * cos(force.angle) )
        let end_y_Point = CGFloat(center.y) + CGFloat( tailLength * sin(force.angle) )
        
        // Create the arrow path
        let arrowPath = UIBezierPath.arrow(from: center, to: CGPoint(x: end_x_Point, y: end_y_Point), tailWidth: CGFloat(ARROW_TAIL_WIDTH), headWidth: CGFloat(HEAD_WIDTH), headLength: CGFloat(HEAD_LENGTH))
    
        // Fill with color
        force.color.setFill()
        arrowPath.fill()
    }
    
    private func drawAngleArc(center: CGPoint, force: ForceDrawing) {
        
        let startAngle: CGFloat = 0
//        let forceAngle: CGFloat = CGFloat(force.angle) - .pi/2
        let forceAngle: CGFloat = CGFloat(force.angle)
//        let endAngle: CGFloat = startAngle - forceAngle
        
        // Create arc path starting from 0 angle
        let arcPath = UIBezierPath(arcCenter: center, radius: CGFloat(ARC_RADIUS), startAngle: startAngle, endAngle: forceAngle, clockwise: true)
        
        // Add line to center
        arcPath.addLine(to: center)
        
        // Fill color
        ARC_COLOR.setFill()
        arcPath.fill()
        
    }
    
    
    
    struct ForceDrawing {
        var type: ForceType
        var angle: Float
        var color: UIColor
        var selected: Bool
    }
}


// Extension of UIBezierPath to draw Arrow shape path
extension UIBezierPath {

    class func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> Self {
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
        let points: [CGPoint] = [
            p(0, tailWidth / 2),
            p(tailLength, tailWidth / 2),
            p(tailLength, headWidth / 2),
            p(length, 0),
            p(tailLength, -headWidth / 2),
            p(tailLength, -tailWidth / 2),
            p(0, -tailWidth / 2)
        ]

        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }

}
