//
//  HistoryView.swift
//  izziPixi
//
//  Created by Despo on 04.02.25.
//

import SwiftUI

struct HistoryView: View {
  @ObservedObject private var vm = PixelateViewModel()
  
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        HStack {
          Spacer()
          
          Button {
            withAnimation {
              vm.clearHistory()
            }
          } label: {
            Text("Clear History")
              .foregroundStyle(.white)
              .fontWeight(.semibold)
              .padding(.horizontal, 10)
              .padding(.vertical, 5)
              .background(vm.images.isEmpty ? .customGray : .blue)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .disabled(vm.images.isEmpty)
        }
        
        if vm.images.isEmpty {
          Text("You have no pixelized images")
            .foregroundStyle(.customGray)
            .offset(y: vm.screenHeight / 2 - 120)
        } else {
          LazyVGrid(columns: [
            GridItem(.fixed(vm.screenWidth / 2 - 30), spacing: 20),
            GridItem(.fixed(vm.screenWidth / 2 - 30), spacing: 20)
          ], spacing: 20){
            ForEach(vm.images, id: \.self) { image in
              Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: vm.screenWidth / 2 - 30, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                  ZStack {
                    Button {
                      vm.saveImageToPhotos(image, isSavingFromHistpry: true)
                    } label: {
                      ZStack {
                        Image(systemName: "square.and.arrow.down")
                          .renderingMode(.template)
                          .foregroundStyle(.white)
                          .scaleEffect(0.8)
                      }
                      .frame(width: 32, height: 32)
                      .background(.blue)
                      .clipShape(Circle())
                      .offset(x: -10, y: 10)
                    }
                  }
                  .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
          }
        }
      }
    }
    .scrollIndicators(.hidden)
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
    .overlay {
      if vm.isSaved {
        SuccessPopover(vm: vm)
      }
    }
  }
}

