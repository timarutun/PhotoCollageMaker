//
//  CollageViewController.swift
//  PhotoCollageMaker
//
//  Created by Timur on 1/1/25.
//

import UIKit

class CollageViewController: UIViewController {
    var photos: [UIImage] = []
    private var collageView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollageView()
        setupGestures()
    }

    private func setupCollageView() {
        collageView = UIView(frame: view.bounds)
        view.addSubview(collageView)

        for photo in photos {
            let imageView = UIImageView(image: photo)
            imageView.frame = CGRect(x: Int.random(in: 50...150), y: Int.random(in: 100...300), width: 100, height: 100)
            imageView.isUserInteractionEnabled = true
            collageView.addSubview(imageView)
        }
    }

    private func setupGestures() {
        for subview in collageView.subviews {
            if let imageView = subview as? UIImageView {
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                imageView.addGestureRecognizer(panGesture)

                let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
                imageView.addGestureRecognizer(pinchGesture)
            }
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: collageView)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: collageView)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }
}
