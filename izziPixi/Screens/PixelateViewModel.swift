//
//  PixelateViewModel.swift
//  izziPixi
//
//  Created by Despo on 04.02.25.
//

import Combine
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

@MainActor
final class PixelateViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var isButtonsDisabled = true
  @Published var pixelSize: Float = 12
  @Published var choosenImage: UIImage? = nil
  @Published var pickedImage: PhotosPickerItem? = nil {
    didSet {
      uploadImageFromAlbum(from: pickedImage)
    }
  }
  
  func fixOrientation(_ image: UIImage) -> UIImage {
    if image.imageOrientation == .up {
      return image
    }
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    image.draw(in: CGRect(origin: .zero, size: image.size))
    
    let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return fixedImage ?? image
  }
  
  func uploadImageFromAlbum(from selection: PhotosPickerItem?) {
    guard let selection else { return }
    isLoading = true
    
    Task { [weak self] in
      if let data = try await selection.loadTransferable(type: Data.self) {
        if let uiImage = UIImage(data: data) {
          self?.choosenImage = self?.fixOrientation(uiImage)
          self?.isButtonsDisabled = false
          self?.isLoading = false
        }
      }
    }
  }
  
  func applyPixelation(scale: Float) -> UIImage? {
    guard let image = choosenImage else { return nil }
    guard let ciImage = CIImage(image: image) else { return nil }
    
    let clampFilter = CIFilter.affineClamp()
    clampFilter.inputImage = ciImage
    
    guard let clampedImage = clampFilter.outputImage else { return nil }
    
    let pixelFilter = CIFilter.pixellate()
    pixelFilter.inputImage = clampedImage
    pixelFilter.scale = scale
    
    guard let outputImage = pixelFilter.outputImage else { return nil }
    
    let context = CIContext(options: [.useSoftwareRenderer: false])
    let rect = ciImage.extent
    
    guard let cgImage = context.createCGImage(outputImage, from: rect) else { return nil }
    
    return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
  }
  
  func saveImageToPhotos(_ image: UIImage) {
    PHPhotoLibrary.requestAuthorization { status in
      guard status == .authorized else { return }
      
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
  }
  
  func reset() {
    isButtonsDisabled = true
    pickedImage = nil
    choosenImage = nil
    pixelSize = 12
  }
}
