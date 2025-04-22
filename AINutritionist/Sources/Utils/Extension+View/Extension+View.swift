//
//  Extension+View.swift
//  AINutritionist
//
//  Created by muser on 07.04.2025.
//

import Foundation
import SwiftUI

extension View {
  @ViewBuilder func `iflet`<Content: View, OptionalType>(_ optional: Optional<OptionalType>, transform: (Self, OptionalType) -> Content) -> some View {
    if let unwrapped = optional {
      transform(self, unwrapped)
    } else {
      self
    }
  }
}
