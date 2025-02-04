//
//  ContentView.swift
//  izziPixi
//
//  Created by Despo on 04.02.25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
  let image: UIImage
      let pixelScale: Float

      var body: some View {
          if let pixelatedUIImage = applyPixelation(to: image, scale: pixelScale) {
              Image(uiImage: pixelatedUIImage)
                  .resizable()
                  .scaledToFit()
          } else {
              Text("Failed to apply pixelation")
          }
      }

      func applyPixelation(to image: UIImage, scale: Float) -> UIImage? {
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
}

#Preview {
  ContentView(image: UIImage(named: "hablo") ?? UIImage(), pixelScale: 10)
}
