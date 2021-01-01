//
//  Data.swift
//  Landmarks
//
//  Created by Yūki Genda on 2021/01/01.
//

import UIKit
import SwiftUI
import CoreLocation

let landmarkData: [Landmark] = load("landmarkData.json")

func load<T: Decodable>(_ filename: String) -> T {  // ラベルなしで引数を受け取る
    let data: Data
    
    // 受け取ったファイル名からURL?オブジェクトを取得
    // URLオブジェクトはただの文字列を持つオブジェクトではなく，URL操作が容易なオブジェクト
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {  // guard-else文はnilになったときelseになるような構文
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    // URLからDataオブジェクトに変換
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    // さらにJSONデータからの変換を試みる
    do {
        let decoder = JSONDecoder()
        // もし成功すれば，ジェネリクスとして受け取ったDecodableなクラス・構造体<T>をデコードして返す
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

// 継承しないので final
final class ImageStore {
    // Key: String => CGImage となるような辞書型を定義
    typealias _ImageDictionary = [String: CGImage]
    
    // imageを先の辞書型の空配列として初期化
    fileprivate var images: _ImageDictionary = [:]
 
    // 画像のスケーリング定数 (前回 2x にスケールしたので)
    fileprivate static var scale = 2
    
    // シングルトン (このクラスで生成されるオブジェクトは1つだけに制限するデザインパターン) を定義
    // これをするために，値型の構造体ではなく参照型のクラスにしたと思われる
    static var shared = ImageStore()
    
    // 3. 画像名からImageオブジェクトを返すメソッド
    func image(name: String) -> Image {
        // インデックス取得 (& 登録されていなければ登録)
        let index = _guaranteeImage(name: name)
        // CGImageから，加工したImageを返す
        return Image(images.values[index], scale: CGFloat(ImageStore.scale), label: Text(name))
    }
    // 1. 画像名からCGImage (CoreGraphics Image) オブジェクトに変換するメソッド
    static func loadImage(name: String) -> CGImage {
        guard
            // URLとして読み込み
            let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
            // URLからCGImageSourceを生成
            let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            // Sourceの先頭インデックスにある画像データをCGImageとして取得
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            // どこかでnilならエラー
            fatalError("Couldn't load image \(name).jpg from main bundle.")
        }
        return image
    }
    // 2. 画像名から辞書のインデックスを取得するメソッド
    fileprivate func _guaranteeImage(name: String) -> _ImageDictionary.Index {
        // もし辞書にキー(画像名)が登録されていたら，そのままそのインデックスを返す
        if let index = images.index(forKey: name) { return index }
        // そうでなければ，辞書に登録した後，そのインデックスを返す
        images[name] = ImageStore.loadImage(name: name)
        return images.index(forKey: name)!
    }
}
