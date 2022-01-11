//
//  YPAssetViewContainer.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit
import Stevia
import AVFoundation

/// The container for asset (video or image). It containts the YPGridView and YPAssetZoomableView.
class YPAssetViewContainer: UIView {
    public var zoomableView: YPAssetZoomableView?
    public let grid = YPGridView()
    public let curtain = UIView()
    public let spinnerView = UIView()
    public let squareCropButton = UIButton()
    public let rotateButton = UIButton()
    public let multipleSelectionButton = UIButton()
    public var onlySquare = YPConfig.library.onlySquare
    public var rotationAngle = YPConfig.library.rotationAngle
    public var isShown = true
    
    private let spinner = UIActivityIndicatorView(style: .white)
    private var shouldCropToSquare = YPConfig.library.isSquareByDefault
    private var isMultipleSelection = false
    
    private var currentRotationAngle: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(grid)
        grid.frame = frame
        clipsToBounds = true
        
        for sv in subviews {
            if let cv = sv as? YPAssetZoomableView {
                zoomableView = cv
                zoomableView?.myDelegate = self
            }
        }
        
        grid.alpha = 0
        
        let touchDownGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        touchDownGR.delegate = self
        addGestureRecognizer(touchDownGR)
        
        // TODO: Add tap gesture to play/pause. Add double tap gesture to square/unsquare
        
        sv(
            spinnerView.sv(
                spinner
            ),
            curtain
        )
        
        spinner.centerInContainer()
        spinnerView.fillContainer()
        curtain.fillContainer()
        
        spinner.startAnimating()
        spinnerView.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.3)
        curtain.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.7)
        curtain.alpha = 0
        
        if !onlySquare {
            // Crop Button
            squareCropButton.setImage(YPConfig.icons.cropIcon, for: .normal)
            if let backgroundColor = YPConfig.library.buttonBackgroundColor {
                squareCropButton.layer.masksToBounds = true
                squareCropButton.layer.cornerRadius = YPConfig.library.buttonSize / 2
                squareCropButton.backgroundColor = backgroundColor
            }
            sv(squareCropButton)
            squareCropButton.size(YPConfig.library.buttonSize)
            |-15-squareCropButton
            squareCropButton.Bottom == zoomableView!.Bottom - 15
        }
        
        if let rotationAngle = YPConfig.library.rotationAngle {
            // Rotate Button
            rotateButton.setImage(YPConfig.icons.rotateIcon, for: .normal)
            if let backgroundColor = YPConfig.library.buttonBackgroundColor {
                rotateButton.layer.masksToBounds = true
                rotateButton.layer.cornerRadius = YPConfig.library.buttonSize / 2
                rotateButton.backgroundColor = backgroundColor
            }
            sv(rotateButton)
            rotateButton.size(YPConfig.library.buttonSize)
            rotateButton-15-|
            rotateButton.Bottom == zoomableView!.Bottom - 15
        }
        
        // Multiple selection button
        sv(multipleSelectionButton)
        multipleSelectionButton.size(YPConfig.library.buttonSize)
        multipleSelectionButton-15-|
        multipleSelectionButton.setImage(YPConfig.icons.multipleSelectionOffIcon, for: .normal)
        multipleSelectionButton.Bottom == zoomableView!.Bottom - (15 + (rotationAngle != nil ? YPConfig.library.buttonSize + 10 : 0))
        
    }
    
    // MARK: - Square button

    @objc public func squareCropButtonTapped() {
        if let zoomableView = zoomableView {
            let z = zoomableView.zoomScale
            shouldCropToSquare = (z >= 1 && z < zoomableView.squaredZoomScale)
            squareCropButton.setImage(z >= 1 ? YPConfig.icons.shrinkIcon : YPConfig.icons.cropIcon, for: .normal)
        }
        zoomableView?.fitImage(shouldCropToSquare, animated: true)
    }
    
    
    public func refreshSquareCropButton() {
        if onlySquare {
            squareCropButton.isHidden = true
        } else {
            if let image = zoomableView?.assetImageView.image {
                let isImageASquare = image.size.width == image.size.height
                squareCropButton.isHidden = isImageASquare
            }
        }
        
        let shouldFit = YPConfig.library.onlySquare ? true : shouldCropToSquare
        zoomableView?.fitImage(shouldFit)
    }
    
    // MARK: - Rotate button
    
    @objc public func rotateButtonTapped() {
        guard zoomableView?.assetImageView != nil, let rotationAngle = YPConfig.library.rotationAngle else { return }
        currentRotationAngle += rotationAngle * .pi / 180
        zoomableView?.transform = CGAffineTransform(rotationAngle: currentRotationAngle)
    }
    
    // MARK: - Multiple selection

    /// Use this to update the multiple selection mode UI state for the YPAssetViewContainer
    public func setMultipleSelectionMode(on: Bool) {
        isMultipleSelection = on
        let image = on ? YPConfig.icons.multipleSelectionOnIcon : YPConfig.icons.multipleSelectionOffIcon
        multipleSelectionButton.setImage(image, for: .normal)
        refreshSquareCropButton()
    }
}

// MARK: - ZoomableViewDelegate
extension YPAssetViewContainer: YPAssetZoomableViewDelegate {
    public func ypAssetZoomableViewDidLayoutsv(_ zoomableView: YPAssetZoomableView) {
        let newFrame = zoomableView.assetImageView.convert(zoomableView.assetImageView.bounds, to: self)
        
        // update grid position
        grid.frame = frame.intersection(newFrame)
        grid.layoutIfNeeded()
        
        // Update play imageView position - bringing the playImageView from the videoView to assetViewContainer,
        // but the controll for appearing it still in videoView.
        if zoomableView.videoView.playImageView.isDescendant(of: self) == false {
            self.addSubview(zoomableView.videoView.playImageView)
            zoomableView.videoView.playImageView.centerInContainer()
        }
        
        squareCropButton.setImage(zoomableView.zoomScale >= 1 ? YPConfig.icons.shrinkIcon : YPConfig.icons.cropIcon, for: .normal)
    }
    
    public func ypAssetZoomableViewScrollViewDidZoom() {
        if isShown {
            UIView.animate(withDuration: 0.1) {
                self.grid.alpha = 1
            }
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidEndZooming() {
        UIView.animate(withDuration: 0.3) {
            self.grid.alpha = 0
        }
    }
}

// MARK: - Gesture recognizer Delegate
extension YPAssetViewContainer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
    
    @objc
    private func handleTouchDown(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if isShown {
                UIView.animate(withDuration: 0.1) {
                    self.grid.alpha = 1
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                self.grid.alpha = 0
            }
        default: ()
        }
    }
}
