//
//  ViewController.swift
//  Movie Searcher
//
//  Created by Sarthak Mishra on 04/08/21.
//

import UIKit
import SafariServices

class ViewController: UIViewController,UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource {
    
    
    
    @IBOutlet var table: UITableView!
    @IBOutlet var field: UITextField!
    
    var movies = [Movie]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        table.delegate = self;
        table.dataSource = self;
        field.delegate = self;
        
    }
    
    //Field
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchMovies()
        return true
    }
    
    private func searchMovies(){
        field.resignFirstResponder()
        
        guard let text = field.text,!text.isEmpty else {
            return
        }
        
        let query = text.replacingOccurrences(of: " ", with: "%20");
        
        movies.removeAll()
        
        URLSession.shared.dataTask(with: URL(string: "https://www.omdbapi.com/?apikey=7cfb2f0c&s=\(query)&type=movie")!,completionHandler: {data,response,error in
            
            guard let data = data, error == nil else{
                return
            }
            
            var result: MovieResult?
            do{
                result = try JSONDecoder().decode(MovieResult.self, from: data)
            }catch{
                print("Error")
            }
            
            guard let finalResult = result else{
                return
            }
            
            let newMovies = finalResult.Search;
            self.movies.append(contentsOf: newMovies)
            
            DispatchQueue.main.async {
                self.table.reloadData()
            }
            
            
            
            
            
        }).resume()
    }
    
    //Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier,for: indexPath) as! MovieTableViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let url = "https://www.imdb.com/title/\(movies[indexPath.row].imdbID)/"
        let vc = SFSafariViewController(url: URL(string:url)!)
        present(vc, animated: true)
    }
}

struct MovieResult: Codable {
    let Search: [Movie]
}

struct Movie: Codable {
    let Title: String
    let Year: String
    let imdbID: String
    let _Type: String
    let Poster: String

    private enum CodingKeys: String, CodingKey {
        case Title, Year, imdbID, _Type = "Type", Poster
    }
}

