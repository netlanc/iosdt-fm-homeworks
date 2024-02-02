//
//  ViewController.swift
//  FileManagerController
//
//  Created by netlanc on 02.02.2024.
//

import UIKit

class FileManagerController: UIViewController {
    
    private let fileService: FileService
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    init(fileService: FileService) {
        self.fileService = fileService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        setupLayout()
        setupNavigation()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    private func setupNavigation() {
        
        navigationItem.title = "Файлы"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0, blue: 0.8297687173, alpha: 1)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func setupLayout() {
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
        
    }
    
    @objc private func addButtonAction() {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension FileManagerController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(fileService.items.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if fileService.items.isEmpty && indexPath.row == 0 { // Проверяем, есть ли файлы и это первая ячейка
            
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Файлов пока нет, нажмите сюда, чтобы загрузить"
            cell.accessoryType = .disclosureIndicator
            return cell
            
        } else {
            
            var content = cell.defaultContentConfiguration()
            content.text = fileService.items[indexPath.row].replaceMiddleWithEllipsis(maxLeft: 19, maxRight: 12) // балуюсь с длинными именами файлов, вырезаю из нутри часть имени
            
            let filePath = fileService.getPath(at: indexPath.row)
            
            // добавил превьюшку файла к ячейке
            if let image = UIImage(contentsOfFile: filePath) {
                
                // Масштабируем изображение до размеров, которые подходят для ячейки
                let scaledImage = image.scaledToSize(targetSize: CGSize(width: 24, height: 24))
                content.image = scaledImage
            }
            
            cell.contentConfiguration = content
            return cell
        }
    }
    
    
}

extension FileManagerController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if !fileService.items.isEmpty {
            if editingStyle == .delete {
                fileService.deleteItem(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if fileService.items.isEmpty && indexPath.row == 0 {
            
            addButtonAction() //
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else {
            
            let fileName = fileService.items[indexPath.row]
            let alert = UIAlertController(title: "Полное имя изображения", message: fileName, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
}


extension FileManagerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage,
           let imageURL = info[.imageURL] as? URL,
           let fileName = imageURL.path.components(separatedBy: "/").last,
           let imageData = image.jpegData(compressionQuality: 1.0) ?? image.pngData() {
            
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
            //try? imageData.write(to: fileURL)
            
            // Передаем данные изображения для сохранения
            fileService.addFile(name: fileName, data: imageData) { success in
                if success {
                    self.tableView.reloadData()
                } else {
                    print("Не удалось добавить изображение")
                }
            }
        }
    }
}
