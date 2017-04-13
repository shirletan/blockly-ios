/*
 * Copyright 2017 Google Inc. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import QuartzCore

@objc(BKYAnglePicker)
public class AnglePicker: UIControl {

  // MARK: - Properties

  private let _angleLayer = CAShapeLayer()// BezierPathLayer()
  private let _backgroundCircleLayer = BezierPathLayer()
  private let _tickLayer = BezierPathLayer()

  public var tickColor = ColorHelper.makeColor(rgb: "757575")

  public var angleColor = ColorHelper.makeColor(rgb: "d32f2f")

  public var circleColor = ColorHelper.makeColor(rgb: "f5f5f5")

  public var numberOfTicks = Int(24)

  public var offsetAngle = CGFloat(0) {
    didSet { offsetRadians = toRadians(offsetAngle) }
  }

  public private(set) var offsetRadians = CGFloat(0)
//    didSet { offsetAngle = toDegrees(offsetRadians) }

  public var clockwise = false

  public var angle = CGFloat(0) {
    didSet { radians = toRadians(angle) }
  }

  public private(set) var radians = CGFloat(0)
//    didSet { angle = toDegrees(radians) }

  private var diameter: CGFloat {
    return min(bounds.width, bounds.height)
  }

  private var radius: CGFloat {
    return diameter / CGFloat(2)
  }

//  private var offsetRadians = toRadians(offsetAngle)
//  private var radians = toRadians(angle)



  // MARK: - Initializer

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    let circleFrame = CGRect(x: (bounds.width - diameter) / 2,
                             y: (bounds.height - diameter) / 2,
                             width: diameter,
                             height: diameter)

    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    let circlePath = UIBezierPath(ovalIn:
      CGRect(x: 0, y: 0, width: circleFrame.width, height: circleFrame.height))

    _backgroundCircleLayer.shouldRasterize = true
    _backgroundCircleLayer.drawsAsynchronously = true
    _backgroundCircleLayer.frame = circleFrame
    _backgroundCircleLayer.fillColor = circleColor?.cgColor
    _backgroundCircleLayer.strokeColor = nil
    _backgroundCircleLayer.lineWidth = 0
    _backgroundCircleLayer.setBezierPath(circlePath, animated: false)
    _backgroundCircleLayer.allowsEdgeAntialiasing = true
    //    backgroundCircleLayer.fillRule = kCAFillRuleEvenOdd
    layer.addSublayer(_backgroundCircleLayer)

    let tickPath = UIBezierPath(rect: CGRect.zero)
    _tickLayer.strokeColor = tickColor?.cgColor
    _tickLayer.fillColor = tickColor?.cgColor
    _tickLayer.shouldRasterize = true
    _tickLayer.drawsAsynchronously = true
    _tickLayer.lineWidth = 2
    _tickLayer.allowsEdgeAntialiasing = true

    let tickStart = (radius - 24)
    let tickEnd = (radius - 8)

    let radiansPerTick = CGFloat(M_PI) * 2.0 / CGFloat(numberOfTicks)
    for i in 0 ..< numberOfTicks {
      let radian = (CGFloat(i) * radiansPerTick * (clockwise ? 1 : -1)) + toRadians(offsetAngle)
      let x1 = cos(radian) * tickStart + center.x
      let y1 = sin(radian) * tickStart + center.y
      let x2 = cos(radian) * tickEnd + center.x
      let y2 = sin(radian) * tickEnd + center.y
      tickPath.move(to: CGPoint(x: x1, y: y1))
      tickPath.addLine(to: CGPoint(x: x2, y: y2))

//      print("angle: \(radian), x: \(x), y: \(y), i: \(i)")
    }
    _tickLayer.setBezierPath(tickPath, animated: false)


    _backgroundCircleLayer.addSublayer(_tickLayer)
    _backgroundCircleLayer.addSublayer(_angleLayer)

    _angleLayer.frame = circleFrame
    if let filter = CIFilter(name:"CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: 2]) {
      _angleLayer.backgroundFilters = [filter]
      _angleLayer.masksToBounds = true
    }

//    let anglePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI) * 1/4, clockwise: true)
//    angleLayer.frame = circleFrame
//    angleLayer.setBezierPath(anglePath, animated: false)
//    layer.mask = angleLayer

    updateAngle(angle, animated: false)

    setNeedsDisplay()
  }

  fileprivate func updateAngle(_ angle: CGFloat, animated: Bool) {
    let oldAngle = self.angle
    let newAngle = angle
    self.angle = newAngle


    let anglePath = angleBezierPath(from: offsetAngle, to: newAngle)

    _angleLayer.allowsEdgeAntialiasing = true

    _angleLayer.fillColor = angleColor?.cgColor
    _angleLayer.strokeColor = angleColor?.cgColor
    _angleLayer.lineWidth = 2

    
//    let fromBezierPath = _angleLayer.presentation()?.path

    // Kill off any potentially on-going animation
    _angleLayer.removeAnimation(forKey: "path")

    if animated {
      var values = [Any]()

//      if let value = fromBezierPath {
//        values.append(value)
//      }
      values.append(angleBezierPath(from: offsetAngle, to: oldAngle))
      values.append(anglePath.cgPath)

      let animation = CAKeyframeAnimation(keyPath: "path")
      animation.calculationMode = kCAAnimationCubic
      animation.values = values
      animation.keyTimes = [0, 0.17, 0.67, 0.83, 1] // ease-in/ease-out
//      animation.keyTimes = [0, 1] // ease-in/ease-out
      animation.duration = 0.3
//      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      animation.fillMode = kCAFillModeBoth // Keeps `self.path` set to `toValue` on completion
      animation.isRemovedOnCompletion = false // Keeps `self.path` set to `toValue` on completion
      _angleLayer.add(animation, forKey: animation.keyPath)
    } else {
      _angleLayer.path = anglePath.cgPath
    }

    setNeedsDisplay()

  }

  fileprivate func toRadians(_ degrees: CGFloat) -> CGFloat {
    return CGFloat(Double(degrees) / 180.0 * M_PI)
  }

  fileprivate func toDegrees(_ radians: CGFloat) -> CGFloat {
    return CGFloat(Double(radians) / M_PI * 180.0)
  }

  fileprivate func angleRelativeToCenter(of point: CGPoint) -> CGFloat {
    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    let dx = point.x - center.x
    let dy = (point.y - center.y) * (clockwise ? 1: -1)
    var angle = CGFloat(Double(atan(dy/dx)) / M_PI * 180.0)

    if dx < 0 {
      // Adjust the angle if it's obtuse
      angle += 180
    }

    // Remove the original offset from the angle
    angle -= offsetAngle

    // Clamp angle so it's between the desired range
    while angle < 0 {
      angle += 360
    }
    while angle >= 360 {
      angle -= 360
    }

    return angle
  }

  fileprivate func angleBezierPath(from startAngle: CGFloat, to endAngle: CGFloat) -> UIBezierPath {

    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    let startingPoint = CGPoint(x: cos(toRadians(offsetAngle) * (clockwise ? 1: -1)) * radius + center.x,
                                y: sin(toRadians(offsetAngle) * (clockwise ? 1: -1)) * radius + center.y)

    let anglePath = UIBezierPath(rect: CGRect.zero)
    anglePath.move(to: center)
    anglePath.addLine(to: startingPoint)
    anglePath.addArc(
      withCenter: center,
      radius: radius,
      startAngle: toRadians(offsetAngle) * (clockwise ? 1: -1),
      endAngle: toRadians(offsetAngle + angle) * (clockwise ? 1: -1),
      clockwise: clockwise)
    anglePath.close()

    return anglePath
  }
}

extension AnglePicker {
  public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    //print("BEGIN tracking: \(touch.hash)")

    let relativeLocation = touch.location(in: self)
    updateAngle(angleRelativeToCenter(of: relativeLocation), animated: true)

    return true
  }

  public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    print("CONTINUE tracking: \(touch.hash)")

    let relativeLocation = touch.location(in: self)
    updateAngle(angleRelativeToCenter(of: relativeLocation), animated: false)

    return true
  }

  public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    print("END tracking: \(touch?.hash)")

    if let relativeLocation = touch?.location(in: self) {
      updateAngle(angleRelativeToCenter(of: relativeLocation), animated: false)
    }
  }

  public override func cancelTracking(with event: UIEvent?) {
    print("CANCEL tracking")
  }
}
