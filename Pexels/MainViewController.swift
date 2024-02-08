//
//  MainViewController.swift
//  Pexels
//
//  Created by Zamanbek Kozhas on 03.11.2023.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchHistoryCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var searchHistoryCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var searchPhotosResponse: SearchPhotosResponse? {
        didSet {
            DispatchQueue.main.async {
                self.imageCollectionView.reloadData()

            }
        }
    }
    var photos: [Photo] {
        return searchPhotosResponse?.photos ?? []
    }
    let savedSearchTextArrayKey: String = "savedSearchTextArrayKey"
    var searchTextArray: [String] = [] {
        didSet {
            searchHistoryCollectionView.reloadData()
            showSearchHistorySectionIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Pexels"
        
        searchBar.delegate = self
        
        // image CollectionView SETUP
        imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        imageCollectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.refreshControl = UIRefreshControl()
        imageCollectionView.refreshControl!.addTarget(self, action: #selector(search), for: .valueChanged)
        
        // Search History CollectionView SETUP
        let flowLayout = searchHistoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        searchHistoryCollectionView.register(UINib(nibName: SearchTextCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SearchTextCollectionViewCell.identifier)
        searchHistoryCollectionView.dataSource = self
        
        searchHistoryCollectionView.delegate = self
        
       resetSearchTextArray()
    }

    @objc func search() {
        self.searchPhotosResponse = nil
        
        guard let searchText = searchBar.text else {
            print("Search bar text is nil")
            return
        }
        guard !searchText.isEmpty else {
            print("Search bar text is empty")
            return
        }
        
        // Save Searching Text
        save(searchText: searchText)
        
        let endpoint: String = "https://api.pexels.com/v1/search"
        guard var urlComponents = URLComponents(string: endpoint) else {
            print("Couldn't create URLComponents instance from endpoint - \(endpoint)")
            return
        }
        
        let parameters = [
            URLQueryItem(name: "query", value: searchText),
            URLQueryItem(name: "per_page", value: "20")
        ]
        urlComponents.queryItems = parameters
        
        guard let url: URL = urlComponents.url else {
            print("URL is nil")
            return
        }
        
        var urlRequest: URLRequest = URLRequest(url: url)
////        urlRequest.httpMethod = "GET"
//        urlRequest.httpMethod = "POST"
        
        let APIKey: String = "m7pF11OcB1zytbDq1UGMzR8MVFVsvqT8ezL9QeAVbtdIBEjkd7S6b3Mi"
        urlRequest.addValue(APIKey, forHTTPHeaderField: "Authorization")
        
//        let parameters: [String: Any] = [
//            "querry" : searchText,
//            "per_page": 10
//        ]
//        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        if imageCollectionView.refreshControl?.isRefreshing == false {
            imageCollectionView.refreshControl?.beginRefreshing()
        }
        
        let urlSession: URLSession = URLSession(configuration: .default)
        let dataTask: URLSessionDataTask = urlSession.dataTask(with: urlRequest, completionHandler: searchPhotosHandler(data:urlResponse:error:))
        
        dataTask.resume()
//        dataTask.cancel() Для отмены запроса
    }
    
    func searchPhotosHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        print("Method searchPhotosHandler was called")
        
        DispatchQueue.main.async {
            if self.imageCollectionView.refreshControl?.isRefreshing == true {
                self.imageCollectionView.refreshControl?.endRefreshing()
            }
        }
        
        if let error = error {
            
            print("Search Photos endpoint error - \(error.localizedDescription)")
        } else if let data = data {
            
            do {
                
//                let jsonObject = try JSONSerialization.jsonObject(with: data)
//                print("Search Photos endpoint jsonObject - \(jsonObject)")
                let searchPhotosResponse = try JSONDecoder().decode(SearchPhotosResponse.self, from: data)
                print("Search Photos endpoint searchPhotosResponse - \(searchPhotosResponse)")
                self.searchPhotosResponse = searchPhotosResponse
                
            } catch let error {
                print("Search Photos endpoint serialixation error - \(error.localizedDescription)")
            }
            
        }
        
        if let urlResponse = urlResponse, let httpResponse = urlResponse as? HTTPURLResponse {
            
            print("Search Photos endpoint http response status code - \(httpResponse.statusCode)")
        }
    }
    
    func save(searchText: String) {
        var existingArray: [String] = getSaveSearchTextArray()
        existingArray.append(searchText)
        
        UserDefaults.standard.set(existingArray, forKey: savedSearchTextArrayKey)
        
        resetSearchTextArray()
    }
    
    func getSaveSearchTextArray() -> [String] {
        let array: [String] = UserDefaults.standard.stringArray(forKey: savedSearchTextArrayKey) ?? []
        return array
    }
    
    func getSortedSearchTextArray() -> [String] {
        let savedSearchTextArray: [String] = getSaveSearchTextArray()
        let reversedSavedSearchTextArray: [String] = savedSearchTextArray.reversed()
        return reversedSavedSearchTextArray
    }
    
    func resetSearchTextArray() {
        self.searchTextArray = getUniqueSearchTextArray()
    }
    
    func getUniqueSearchTextArray() -> [String] {
        
        let sortedSearchTextArray: [String] = getSortedSearchTextArray()
        
        var sortedSearchTextArrayWithUniqueValues: [String] = []
        
        sortedSearchTextArray.forEach { searchText in
            
            if !sortedSearchTextArrayWithUniqueValues.contains(searchText) {
                sortedSearchTextArrayWithUniqueValues.append(searchText)
            }
        }
        return sortedSearchTextArrayWithUniqueValues
    }
    
    func deleteContact(at index: Int) {
        // Удаление ключевого слова в указанным индексе из объекта searchTextArray
        searchTextArray.remove(at: index)
        // Переопределение значения под ключем "savedSearchTextArrayKey", а именно на значение объекта searchTextArray без ранее удаленного ключевого слова
        UserDefaults.standard.set(searchTextArray, forKey: savedSearchTextArrayKey)
    }
    
    func showSearchHistorySectionIfNeeded() {
        
        // Проверяем, если количество элементов в массиве истории поиска больше 0 и текущая высота коллекции истории поиска не равна 60.
        if searchTextArray.count > 0 && self.searchHistoryCollectionViewHeightConstraint.constant != 60 {
            // Устанавливаем высоту коллекции истории поиска равной 60.
            self.searchHistoryCollectionViewHeightConstraint.constant = 60
            
            // Анимируем изменение высоты коллекции истории поиска.
            UIView.animate(withDuration: 0.3) {
                // Применяем изменения макета, чтобы увидеть анимацию изменения высоты.
                self.view.layoutIfNeeded()
            }
        }
        // Проверяем, если количество элементов в массиве истории поиска меньше 1 и текущая высота коллекции истории поиска не равна 0.
        else if searchTextArray.count < 1 && self.searchHistoryCollectionViewHeightConstraint.constant != 0 {
            // Устанавливаем высоту коллекции истории поиска равной 0.
            self.searchHistoryCollectionViewHeightConstraint.constant = 0
            
            // Анимируем изменение высоты коллекции истории поиска.
            UIView.animate(withDuration: 0.3) {
                // Применяем изменения макета, чтобы увидеть анимацию изменения высоты.
                self.view.layoutIfNeeded()
            }
        }
    }
}


extension MainViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }
}

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case imageCollectionView:
            return photos.count
            
        case searchHistoryCollectionView:
            return searchTextArray.count
            
        default:
            return 0

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case imageCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
            cell.setup(photo: self.photos[indexPath.item])
            return cell
            
        case searchHistoryCollectionView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTextCollectionViewCell.identifier, for: indexPath) as! SearchTextCollectionViewCell
            
            let title = searchTextArray[indexPath.item]
            
            cell.set(title: title, delegate: self, collectionView: collectionView, indexPath: indexPath)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowlayout = collectionViewLayout as? UICollectionViewFlowLayout
        let horizontalSpacing: CGFloat = ( flowlayout?.minimumLineSpacing ?? 0 ) + collectionView.contentInset.left + collectionView.contentInset.right
        let width: CGFloat = (collectionView.frame.width - horizontalSpacing) / 2
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
            
        case imageCollectionView:
            let photo = self.photos[indexPath.item]
            let url = photo.src.large2X
            
            let vc = ImageScrollViewController(imageURL: url)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case searchHistoryCollectionView:
            let searchText: String = searchTextArray[indexPath.item]
            searchBar.text = searchText
            
            search()
            
        default:
            ()
        }
    }
}

extension MainViewController: SearchTextCollectionViewCellDelegate {
    
    func searchTextCollectionViewCell(_ collectionView: UICollectionView, deleteButtonWasTapped indexPath: IndexPath) {
        deleteContact(at: indexPath.item)
    }
}
