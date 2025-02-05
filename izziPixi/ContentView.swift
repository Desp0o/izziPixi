//
//  ContentView.swift
//  izziPixi
//
//  Created by Despo on 04.02.25.
//

import SwiftUI

struct ContentView: View {
  private let tabs = ["Pixelate", "History"]
  @State private var currentIdenx = 0
  @Namespace private var namespace
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        switch currentIdenx {
        case 0:
          PixelateView()
        case 1:
          HistoryView()
        default:
          PixelateView()
        }
      }
      
      HStack(spacing: 20) {
        ForEach(tabs.indices, id: \.self) { index in
          let tab = tabs[index]
          ZStack {
            if currentIdenx == index {
              RoundedRectangle(cornerRadius: 12)
                .fill(.blue)
                .matchedGeometryEffect(id: "tab", in: namespace)
            }
            
            Button {
              currentIdenx = index
            } label: {
              Text(tab)
                .foregroundStyle(currentIdenx == index ? .white : .customGray)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            }
          }
        }
      }
      .frame(height: 40)
      .frame(maxWidth: .infinity)
      .background(Color.customBg)
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .padding(.horizontal, 40)
      .animation(.spring, value: currentIdenx)
    }
    .background(
      Color.customBg.ignoresSafeArea()
    )
  }
}
