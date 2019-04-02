//
//  CompassView.swift
//  ChiSail
//
//  Created by Logan Noel on 3/1/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import UIKit

class CompassView: UIView {
    private var goBack = CGFloat(0.0)
    private var needsReset = false
    var compassHeading = CGFloat(0)

    // https://github.com/uchicago-mobi/MPCS51030-2019-Winter-Forum/issues/133
    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIColor.darkGray.setStroke()
        let borderWidth = CGFloat(2.0)
        let circlePath = UIBezierPath(ovalIn: CGRect(x: borderWidth, y: borderWidth, width: rect.width - borderWidth*2, height: rect.height - borderWidth*2))
        circlePath.lineWidth = borderWidth
        circlePath.stroke()
        
        let headingPath = UIBezierPath()
        headingPath.lineWidth = 3
        headingPath.move(to: CGPoint(x: rect.midX, y: rect.midY))
        let hypotenuse = CGFloat(rect.height / 2)
        let xVector = cos(compassHeading) * hypotenuse
        let yVector = sin(compassHeading) * hypotenuse
        
        headingPath.lineCapStyle = .round
        headingPath.addLine(to: CGPoint(x: rect.midX + CGFloat(xVector), y: rect.midY + CGFloat(yVector)))
        UIColor.red.setStroke()
        headingPath.stroke()
    }
    
    private func resetCompass() {
        self.transform = self.transform.rotated(by: -self.goBack)
        self.setNeedsDisplay()
        needsReset = false
    }
    
    // https://stackoverflow.com/questions/27660540/uiview-animatewithduration-swift-loop-animation
    func animateCompass(actualWindHeading: Int, windIntensity: Float) {
        if needsReset {
            resetCompass()
        }
        let degreesOfMovement = self.getDegreesOfMovement(windIntensity)

        self.compassHeading = self.getAdjustedCompassHeading(actualWindHeading: actualWindHeading, degreesOfMovement: degreesOfMovement)
  
        self.goBack = degreesOfMovement
        self.needsReset = true
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       options: [.repeat, .autoreverse, .curveEaseInOut],
                       animations:{
                        self.transform = self.transform.rotated(by: degreesOfMovement)
        },
                       completion: nil)

        
    }
    
    private func getDegreesOfMovement(_ windIntensity: Float) -> CGFloat {
        return CGFloat(0.2 / Float.pi) * CGFloat(windIntensity)
    }
    
    private func getAdjustedCompassHeading(actualWindHeading: Int, degreesOfMovement: CGFloat) -> CGFloat {
        let actualCompassHeading = CGFloat(actualWindHeading - 90) * CGFloat.pi / 180.0
        return actualCompassHeading - degreesOfMovement / 2
    }

}
