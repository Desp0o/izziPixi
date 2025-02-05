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
  private let fileManager = FileManager.default
  private var directory: URL? = nil
  
  @Published var isLoading = false
  @Published var isSaved = false
  @Published var isButtonsDisabled = true
  @Published var pixelSize: Float = 12
  @Published var choosenImage: UIImage? = nil
  @Published var images: [UIImage] = []
  @Published var showPhotoAccessAlert = false
  @Published var pickedImage: PhotosPickerItem? = nil {
    didSet {
      uploadImageFromAlbum(from: pickedImage)
    }
  }
  
  var screenWidth: CGFloat {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first?.screen.bounds.width ?? 0
  }
  var screenHeight: CGFloat {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first?.screen.bounds.height ?? 0
  }
  
  init() {
    Task {
      await checkPhotoLibraryAccess()
    }
    setupFileManager()
    loadImages()
  }
  
  private func checkPhotoLibraryAccess() async {
    let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    await MainActor.run {
      if status == .denied || status == .restricted {
        showPhotoAccessAlert = true
        isButtonsDisabled = true
      }
    }
  }
  
  func setupFileManager() {
    guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return
    }
    
    directory = url.appendingPathComponent("SavedImages")
    guard let dir = directory else { return }
    
    if !fileManager.fileExists(atPath: dir.path) {
      do {
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
      } catch {
        print("error.localizedDescription")
      }
    }
  }
  
  func loadImages() {
    guard let dir = directory else { return }
    guard let files = try? fileManager.contentsOfDirectory(atPath: dir.path) else { return }
    
    images = files.compactMap { fileName in
      let filePath = dir.appendingPathComponent(fileName).path
      if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
        return UIImage(data: data)
      }
      return nil
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
    
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    
    if status == .denied || status == .restricted {
      showPhotoAccessAlert = true
      isButtonsDisabled = true
      return
    }
    
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
  
  func saveImagesToHistory() {
    guard let dir = directory else { return }
    for (index, image) in images.prefix(20).enumerated() {
      let imagePath = dir.appendingPathComponent("image_\(index).jpg")
      if let data = image.jpegData(compressionQuality: 1) {
        try? data.write(to: imagePath)
      }
    }
  }
  
  func addImage(_ image: UIImage) {
    if images.count >= 20 {
      images.removeLast()
    }
    images.insert(image, at: 0)
    saveImagesToHistory()
  }
  
  func saveImageToPhotos(_ image: UIImage, isSavingFromHistpry: Bool = false) {
    isLoading = true
    
    Task {
      let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
      if status == .denied || status == .restricted {
        await MainActor.run {
          self.isLoading = false
          self.showPhotoAccessAlert = true
        }
        return
      }
      
      await withCheckedContinuation { continuation in
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        continuation.resume()
      }
      
      await MainActor.run {
        self.isLoading = false
        self.isSaved = true
        
        if !isSavingFromHistpry {
          addImage(image)
        }
      }
    }
  }
  
  func reset() {
    isButtonsDisabled = true
    pickedImage = nil
    choosenImage = nil
    pixelSize = 12
  }
  
  func clearHistory() {
    guard let dir = directory else { return }
    if let files = try? fileManager.contentsOfDirectory(atPath: dir.path) {
      for file in files {
        let filePath = dir.appendingPathComponent(file).path
        try? fileManager.removeItem(atPath: filePath)
      }
    }
    images.removeAll()
  }
}
