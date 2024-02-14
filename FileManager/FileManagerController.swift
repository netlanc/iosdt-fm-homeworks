//
//  ViewController.swift
//  FileManagerController
//
//  Created by netlanc on 02.02.2024.
//
import UIKit

protocol SortingChangeObserver: AnyObject {
    func sortingDidChange(sortingDirection: Bool)
}

class FileManagerController: UIViewController {
    
    let defaults = UserDefaults.standard
    private let fileService: FileService
    private var sortedItems: [String] = []
    private var sortingDirection: Bool = true // Сортировка по умолчанию "А-Я"
    
    
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
        
        // Pre-sort files
        self.setupSortingDirection()
        self.sortFiles()
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
        setupObservers()
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
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(sortingDidChange(_:)), name: Notification.Name("SortingChanged"), object: nil)
    }
    
    @objc private func sortingDidChange(_ notification: Notification) {
        if let sortingDirection = notification.object as? Bool {
            self.sortingDirection = sortingDirection
            sortFiles()
        }
    }
    
    private func setupSortingDirection() {
        sortingDirection = defaults.bool(forKey: "sortingDirection")
    }
    
    private func sortFiles() {
        var sortedItems = fileService.items
        
        if sortingDirection {
            sortedItems.sort()
        } else {
            sortedItems.sort(by: { $0 > $1 })
        }
        
        self.sortedItems = sortedItems
        tableView.reloadData()
    }
    
}

extension FileManagerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(sortedItems.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if sortedItems.isEmpty && indexPath.row == 0 { // Проверяем, есть ли файлы и это первая ячейка
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Файлов пока нет, нажмите сюда, чтобы загрузить"
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            var content = cell.defaultContentConfiguration()
            
            let fileName = sortedItems[indexPath.row];
            
            content.text = fileName.replaceMiddleWithEllipsis(maxLeft: 19, maxRight: 12)
            
            let filePath = fileService.getPath(withName: fileName)
            
            if let image = UIImage(contentsOfFile: filePath) {
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
                // Удаляем файл из сервиса
                // fileService.deleteItem(at: indexPath.row)
                // с учетом того что при изменении сортировки индек ячейки и индекс файла в серсисе могут отличаться
                // удаление по индексу переделаем на удаление по имени фала
                
                let fileName = sortedItems[indexPath.row]
                fileService.deleteItem(withName: fileName)
                
                // Удаляем файл из массива отсортированных элементов
                sortedItems.remove(at: indexPath.row)
                
                // Удаляем ячейку из таблицы
                if !sortedItems.isEmpty {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
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
            
            //let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
            //try? imageData.write(to: fileURL)
            
            // Передаем данные изображения для сохранения
            fileService.addFile(name: fileName, data: imageData) { success in
                if success {
                    
                    print("Удалось добавить изображение")
                    self.sortFiles()
                    self.tableView.reloadData()
                } else {
                    print("Не удалось добавить изображение")
                }
            }
        }
    }
}

