//
//  EmptyDataSet.swift
//  EmptyDataSet-Swift
//
//  Created by Max Lesichniy on 07.04.2023.
//

import SwiftUI

struct EmptyDataSet: View {
    
    var body: some View {
        EmptyDataSetViewRepresentable(())
    }
    
}

fileprivate struct EmptyDataSetViewRepresentable: UIViewRepresentable {
    
}

struct EmptyDataSet_Previews: PreviewProvider {
    static var previews: some View {
        EmptyDataSet()
    }
}
