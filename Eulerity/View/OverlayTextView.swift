//
//  OverlayTextView.swift
//  Eulerity
//
//  Created by Chris Park on 11/11/21.
//

import Foundation
import UIKit

class OverlayTextView: UITextView {
    
    init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        text = "Text"
        font = UIFont(name: "Times New Roman", size: 27)
        textColor = .darkGray
        backgroundColor = .none
        isScrollEnabled = false
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = true
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
    }
    
    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        translate(gesture.translation(in: self))
        gesture.setTranslation(.zero, in: self)
        setNeedsDisplay()
    }
}

extension  CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
}

extension UIView {
    func translate(_ translation: CGPoint) {
        guard let superview = superview else { return }
        let destination = center + translation
        let minX = frame.width / 2
        let minY = frame.height / 2
        let maxX = superview.frame.width - minX
        let maxY = superview.frame.height - minY
        center = CGPoint(
            x: min(maxX, max(minX, destination.x)),
            y: min(maxY ,max(minY, destination.y)))
    }
}
