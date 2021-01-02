//
//  UserData.swift
//  Landmarks
//
//  Created by Yūki Genda on 2021/01/02.
//

import SwiftUI
import Combine
 
final class UserData: ObservableObject  {
    @Published var showFavoritesOnly = false
    @Published var landmarks = landmarkData
}
