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
import _PhotosUI_SwiftUI

@MainActor
final class PixelateViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var isButtonsDisabled = true
  @Published var pixelSize: Float = 12
  @Published var choosenImage: UIImage? = nil
  @Published var pickedImage:PhotosPickerItem? = nil {
    didSet {
      uploadImageFromAlbum(from: pickedImage)
    }
  }
  
  func uploadImageFromAlbum(from selection: PhotosPickerItem?) {
    guard let selection else { return }
    isLoading = true
    
    Task { [weak self] in
      if let data = try await selection.loadTransferable(type: Data.self) {
        if let uiImage = UIImage(data: data) {
          self?.choosenImage = uiImage
          self?.isButtonsDisabled = false
          self?.isLoading = false
        }
      }
    }
  }
  
  func applyPixelation(scale: Float) -> UIImage? {
    guard let image = choosenImage else { return nil}
    let context = CIContext()
    let filter = CIFilter.pixellate()
    filter.inputImage = CIImage(image: image)
    filter.scale = scale
    
    guard let outputImage = filter.outputImage,
          let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
      return nil
    }
    
    return UIImage(cgImage: cgImage)
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
