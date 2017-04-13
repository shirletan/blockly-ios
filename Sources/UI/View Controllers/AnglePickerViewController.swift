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

/**
 Delegate for events that occur on `AnglePickerViewController`.
 */
@objc(BKYAnglePickerViewControllerDelegate)
public protocol AnglePickerViewControllerDelegate: class {
  /**
   Event that is called when the user has selected a color for a color field.

   - parameter viewController: The view controller where this event occurred.
   - parameter color: The selected color.
   */
  func anglePickerViewController(
    _ viewController: AnglePickerViewController, didPickAngle angle: Int)
}

/**
 View controller for selecting an angle.
 */
@objc(BKYAnglePickerViewController)
public class AnglePickerViewController: UIViewController {
  // MARK: - Properties

  private let anglePicker = AnglePicker(frame: CGRect(x: 10, y: 10, width: 200, height: 200))

  private let textField = InsetTextField(frame: CGRect(x: 0, y: 50, width: 100, height: 30))

  /// The current angle value
  public var angle: Int = 0

  /// Delegate for events that occur on this controller
  public weak var delegate: AnglePickerViewControllerDelegate?

  // MARK: - Initializers

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Super

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(anglePicker)
//    view.addSubview(textField)
//
//    textField.borderStyle = .roundedRect
//    textField.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//    textField.keyboardType = .numbersAndPunctuation
//    textField.textAlignment = .right
//    textField.text = "TEST"
//
//    view.bringSubview(toFront: textField)
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    preferredContentSize = CGSize(width: 220, height: 220)

    refreshView()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Update the selected color after the view has appeared (it doesn't work if called from
    // viewWillAppear)
//    updateSelectedColor(animated: true)
  }

  // MARK: - Public

  public func refreshView() {
//    // Set the preferred content size when this view controller is displayed in a popover
//    let rows = ceil(CGFloat(self.colors.count) / CGFloat(self.preferredColorsPerRow))
//    self.preferredContentSize = CGSize(
//      width: CGFloat(self.preferredColorsPerRow) * _flowLayout.itemSize.width,
//      height: CGFloat(rows) * _flowLayout.itemSize.height)
//
//    // Refresh the collection view
//    self.collectionView?.reloadData()
//
//    updateSelectedColor(animated: false)
  }

  // MARK: - Private

//  fileprivate func updateSelectedColor(animated: Bool) {
//    guard let selectedColor = self.color else {
//      return
//    }
//
//    // Set the selected color, if it exists in the color picker
//    for i in 0 ..< colors.count {
//      if selectedColor == ColorHelper.makeColor(rgb: colors[i]) {
//        let indexPath = IndexPath(row: i, section: 0)
//        self.collectionView?.selectItem(
//          at: indexPath, animated: animated, scrollPosition: .centeredVertically)
//        break
//      }
//    }
//  }
//
//  fileprivate func makeColor(indexPath: IndexPath) -> UIColor? {
//    return ColorHelper.makeColor(rgb: self.colors[(indexPath as NSIndexPath).row])
//  }
}
