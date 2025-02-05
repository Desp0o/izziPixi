//
//  PixelateView.swift
//  izziPixi
//
//  Created by Despo on 04.02.25.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct PixelateView: View {
  @StateObject private var vm = PixelateViewModel()
  
  var body: some View {
    VStack {
      HStack {
        Button {
          vm.reset()
        } label: {
          Text("Clear")
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(vm.isButtonsDisabled ? .customGray : .blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(vm.isButtonsDisabled)
        
        Spacer()
        
        Button {
          if let image = vm.applyPixelation(scale: vm.pixelSize){
            vm.saveImageToPhotos(image)
          }
        } label: {
          HStack {
            Text("Export")
              .foregroundStyle(.white)
              .fontWeight(.semibold)
            
            Image(systemName: "square.and.arrow.up")
              .foregroundStyle(.white)
          }
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background(vm.isButtonsDisabled ? .customGray : .blue)
          .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(vm.isButtonsDisabled)
      }
      
      Spacer()
      
      VStack {
        if let image = vm.applyPixelation(scale: vm.pixelSize) {
          VStack {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
              .clipped()
            
            Slider(value: $vm.pixelSize, in: 1...450, step: 1)
              .tint(.blue)
          }
        } else {
          PhotosPicker(selection: $vm.pickedImage) {
            VStack {
              Image("imagePlaceholder")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
              
              Text("Choose image")
                .font(Font.system(size: 16))
                .fontWeight(.bold)
                .foregroundStyle(.customGray)
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.customGray, style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
          }
        }
      }
      Spacer()
    }
    .padding(20)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      ZStack{
        Color.customBg.ignoresSafeArea()
      }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    )
    .overlay {
      ZStack {
        if vm.isLoading {
          ProgressView()
            .scaleEffect(2)
            .tint(.blue)
        }
        
        if vm.isSaved {
          SuccessPopover(vm: vm)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
