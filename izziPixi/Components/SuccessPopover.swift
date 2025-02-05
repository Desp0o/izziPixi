//
//  SuccessPopover.swift
//  izziPixi
//
//  Created by Despo on 05.02.25.
//

import SwiftUI

struct SuccessPopover: View {
  @ObservedObject var vm: PixelateViewModel
  
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "checkmark.circle.fill")
        .renderingMode(.template)
        .foregroundStyle(.green)
        .scaleEffect(2)
      
      Text("Saved to Photo Library")
    }
    .padding(20)
    .background(Color.customBg.opacity(0.5))
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .task {
      try? await Task.sleep(for: .seconds(1))
      vm.isSaved = false
    }
  }
}
