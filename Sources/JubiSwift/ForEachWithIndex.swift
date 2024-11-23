// Copyright Justin Bishop, 2024

import SwiftUI

public func ForEachWithIndex<T: Identifiable, V: View>(
  _ array: [T],
  block: @escaping (Int, T) -> V
) -> ForEach<[(offset: Int, element: T)], T.ID, V> {
  ForEach(Array(array.enumerated()), id: \.element.id) { idx, item in
    block(idx, item)
  }
}
