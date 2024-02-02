//
//  FileService.swift
//  FileService
//
//  Created by netlanc on 02.02.2024.
//

import UIKit

final class FileService {
    
    private let pathForFolder: String
    
    var items: [String] {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: pathForFolder)) ?? []

        // Фильтруем только файлы изображений
        let imageFiles = files.filter { fileName in
            let filePath = pathForFolder + "/" + fileName
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
            
            guard !isDirectory.boolValue else {
                return false // Исключаем директории
            }
            
            // Получаем расширение файла и проверяем, является ли оно изображением
            let fileExtension = URL(fileURLWithPath: filePath).pathExtension.lowercased()
            let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "webp"]
            return imageExtensions.contains(fileExtension)
            
        }.sorted()
        
        return imageFiles
    }
    
    init() {
        pathForFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("pathForFolder", pathForFolder)
    }
    
    init(pathFolder: String) {
        self.pathForFolder = pathFolder
    }
    
    func addFile(name: String, data: Data, completion: @escaping (Bool) -> Void) {
        let url = URL(fileURLWithPath: pathForFolder + "/" + name)
        if FileManager.default.fileExists(atPath: url.path) {
            
            let alert = UIAlertController(title: "Файл уже существует", message: "Хотите перезаписать файл?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Перезаписать", style: .destructive, handler: { _ in
                do {
                    try data.write(to: url)
                    completion(true)
                } catch {
                    completion(false)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in
                completion(false)
            }))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            
        } else {
            do {
                try data.write(to: url)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    func deleteItem(at index: Int) {
        let path = pathForFolder + "/" + items[index]
        try? FileManager.default.removeItem(atPath: path)
    }
    
    func getPath(at index: Int) -> String {
        pathForFolder + "/" + items[index]
    }
    
}
