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

class AnglesOverviewView: UIView {
    
    let FORCE_ARROW_TAIL_LENGTH: Float = 30
    let NETFORCE_ARROW_TAIL_LENGTH: Float = 50
    let ARROW_TAIL_WIDTH: Float = 2
    let HEAD_LENGTH: Float = 10
    let HEAD_WIDTH: Float = 7
    let ARC_RADIUS: Float = 10
    
    let ARC_COLOR: UIColor = UIColor.yellow
//    let NETFORCE_COLOR: UIColor = UIColor.white
//    let FORCE_COLOR: UIColor = UIColor.white
//    let SELECTED_FORCE_COLOR: UIColor = UIColor.green
    
    
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
                
        if selectedPointChargeObj.netForce != nil {
            if selectedPointChargeObj.netForce!.forces.count > 0 {
                
                drawForces(center: center)
            }
        }
        
    }

    // MARK: - Actions
    private func drawForces(center: CGPoint) {
        let netForce = selectedPointChargeObj.netForce!
        drawForce(center: center, angle: netForce.angle, forceType: netForce.type, color: netForce.color, selected: netForce.selected)
        
        netForce.forces.forEach{ f in
            drawForce(center: center, angle: f.angle, forceType: f.type, color: f.color, selected: f.selected)
        }
    }
    
    private func drawForce(center: CGPoint, angle: Float, forceType: ForceType, color: UIColor, selected: Bool) {
        
        /**
         - Regulated Angle:
         To ensure that the angle representation and the
         vectors go the same way as the 3d models
         */
        let regulatedAngle = 360.degreesToRadians() - angle
        
        // Get the tail length
        let tailLength: Float = forceType == ForceType.single ? FORCE_ARROW_TAIL_LENGTH : NETFORCE_ARROW_TAIL_LENGTH
        
        // Find the end point based on the angle
        let end_x_Point = CGFloat(center.x) + CGFloat( tailLength * cos(regulatedAngle) )
        let end_y_Point = CGFloat(center.y) + CGFloat( tailLength * sin(regulatedAngle) )
        
        // Create the arrow path
        let arrowPath = UIBezierPath.arrow(from: center, to: CGPoint(x: end_x_Point, y: end_y_Point), tailWidth: CGFloat(ARROW_TAIL_WIDTH), headWidth: CGFloat(HEAD_WIDTH), headLength: CGFloat(HEAD_LENGTH))
    
        // Fill with color
        color.setFill()
        arrowPath.fill()
        arrowPath.stroke(with: .color, alpha: 1)
        
        // If force is the selected one, draw Arc
        if selected {
            drawAngleArc(center: center, angle: regulatedAngle)
        }
    }
    
    private func drawAngleArc(center: CGPoint, angle: Float) {
        
        let startAngle: CGFloat = 0
//        let forceAngle: CGFloat = CGFloat(force.angle) - .pi/2
        let forceAngle: CGFloat = CGFloat(angle)
//        let endAngle: CGFloat = startAngle - forceAngle
        
        // Create arc path starting from 0 angle
        let arcPath = UIBezierPath(arcCenter: center, radius: CGFloat(ARC_RADIUS), startAngle: startAngle, endAngle: forceAngle, clockwise: false)
        
        // Add line to center
        arcPath.addLine(to: center)
        
        // Fill color
        ARC_COLOR.setFill()
        arcPath.fill()
    }
    
//    private func drawForce(center: CGPoint, force: ForceDrawing) {
//
//        // Get the tail length
//        let tailLength: Float = force.type == ForceType.single ? FORCE_ARROW_TAIL_LENGTH : NETFORCE_ARROW_TAIL_LENGTH
//
//        // Find the end point based on the angle
//        let end_x_Point = CGFloat(center.x) + CGFloat( tailLength * cos(force.angle) )
//        let end_y_Point = CGFloat(center.y) + CGFloat( tailLength * sin(force.angle) )
//
//        // Create the arrow path
//        let arrowPath = UIBezierPath.arrow(from: center, to: CGPoint(x: end_x_Point, y: end_y_Point), tailWidth: CGFloat(ARROW_TAIL_WIDTH), headWidth: CGFloat(HEAD_WIDTH), headLength: CGFloat(HEAD_LENGTH))
//
//        // Fill with color
//        force.color.setFill()
//        arrowPath.fill()
//    }
    
    
//    private func drawAngleArc(center: CGPoint, force: ForceDrawing) {
//
//        let startAngle: CGFloat = 0
////        let forceAngle: CGFloat = CGFloat(force.angle) - .pi/2
//        let forceAngle: CGFloat = CGFloat(force.angle)
////        let endAngle: CGFloat = startAngle - forceAngle
//
//        // Create arc path starting from 0 angle
//        let arcPath = UIBezierPath(arcCenter: center, radius: CGFloat(ARC_RADIUS), startAngle: startAngle, endAngle: forceAngle, clockwise: true)
//
//        // Add line to center
//        arcPath.addLine(to: center)
//
//        // Fill color
//        ARC_COLOR.setFill()
//        arcPath.fill()
//
//    }
    
    
    // MARK: - Force Angles Update
    
//    func updateForceAngle(index: Int, angle: Float) {
//        self.forcesDrawings[index]?.angle = angle
//
//        // Re-draw
//        self.setNeedsDisplay()
//    }
    
//    func updateAllForcesAngles(netForce: NetForce) {
////        print(self.forcesDrawings.count)
//
//        self.forcesDrawings[netForce.forceId]?.angle = netForce.angle
//        netForce.forces.forEach{ force in
//            self.forcesDrawings[force.forceId]?.angle = force.angle
//        }
//
//        // Re-draw
//        self.setNeedsDisplay()
//    }
    
//    func selectForceDrawing(index: Int) {
//
////        print(self.forcesDrawings)
//
//        // In case an update is required
//        if forcesDrawings[selectedForceDrawIndex] == nil {
//            self.updateAllForcesAngles(netForce: selectedPointChargeObj.netForce!)
//        }
//
//        /// Re-assign normal color for previously selected ForceDraw (if there was a previously selected ForceDraw)
//        if selectedForceDrawIndex > -1 && forcesDrawings[selectedForceDrawIndex] != nil {
//
//            let prevSelected = self.forcesDrawings[self.selectedForceDrawIndex]!
//
//            /// Regular Color
//            let newColor = prevSelected.type == .net ? self.NETFORCE_COLOR : self.FORCE_COLOR
//
////            prevSelected.color = newColor
//            forcesDrawings[selectedForceDrawIndex]!.color = newColor
//
//        }
//
//        /// Asign the color and index for the new selected ForceDraw
//        self.selectedForceDrawIndex = index
////        self.forcesDrawings[self.selectedForceDrawIndex]?.selected = true
//        self.forcesDrawings[index]?.color = self.SELECTED_FORCE_COLOR
//
//        // Re-draw
//        self.setNeedsDisplay()
//
//    }
    
    /*
     Update forceDrawings Dictionary everytime that:
     1) Selected PointCharge changes
     2) A Force is added/deleted
     */
//    func updateForcesDrawings(netForce: NetForce) {
//        self.forcesDrawings = [:]
////        self.forcesDrawings[netForce.forceId] = ForceDrawing(type: .net, angle: netForce.angle, color: self.NETFORCE_COLOR, selected: false)
//        self.forcesDrawings[netForce.forceId] = ForceDrawing(type: .net, angle: netForce.angle, color: self.NETFORCE_COLOR)
//        netForce.forces.forEach{ force in
////            self.forcesDrawings[force.forceId] = ForceDrawing(type: .single, angle: force.angle, color: self.FORCE_COLOR, selected: false)
//            self.forcesDrawings[force.forceId] = ForceDrawing(type: .single, angle: force.angle, color: self.FORCE_COLOR)
//        }
//        
//        // Re-draw
//        self.setNeedsDisplay()
//    }
    
    
    
    
    struct ForceDrawing {
        var type: ForceType
        var angle: Float
        var color: UIColor
//        var selected: Bool
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
