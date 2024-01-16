//
//  SearchResultViewController.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import UIKit


struct SearchSection{
    let title : String
    let results : [SearchResult]
}

protocol SearchResultViewControllerDelegate:AnyObject{
    func didTapResult(_ result:SearchResult)
}

class SearchResultViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    
    private var sections :[SearchSection] = []
    
    weak var delegate: SearchResultViewControllerDelegate?
    private let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
       
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with results : [SearchResult]){
        let artists = results.filter({switch $0{
        case .artist:
            return true
        default :
            return false
      
        }})
        
        let playlists = results.filter({
            switch $0{
            case .playlist :
                return true
            default :return false
            }
        })
        
        let albums = results.filter({
            switch $0{
            case .album :
                return true
            default :return false
            }
        })
        let tracks = results.filter({
            switch $0{
            case .track :
                return true
            default :return false
            }
        })
        self.sections = [SearchSection(title: "Artists", results: artists),SearchSection(title: "Albums", results: albums),SearchSection(title: "Playlists", results: playlists),SearchSection(title: "Tracks", results: tracks)]
        tableView.reloadData()
        
        tableView.isHidden = results.isEmpty
      
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        
      
        
        switch result{
        case .album(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            //cell.textLabel?.text = model.name
            let viewModel = SearchResultSubtitleTableViewCellViewModel( title: model.name,subtitle: model.artists.first?.name ?? "-",artworkURL: URL(string: model.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
            
        case .artist(let model):
            guard let dcell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else {
                return UITableViewCell()
            }
            //cell.textLabel?.text = model.name
            let viewModel = SearchResultDefaultTableViewCellViewModel(artworkURL: URL(string: model.images?.first?.url ?? ""), title: model.name)
            dcell.configure(with: viewModel)
            return dcell
            
        case.playlist(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            //cell.textLabel?.text = model.name
            let viewModel = SearchResultSubtitleTableViewCellViewModel( title: model.name,subtitle: model.owner.display_name,artworkURL: URL(string: model.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        case .track(let model):
            
          
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            //cell.textLabel?.text = model.name
            let viewModel = SearchResultSubtitleTableViewCellViewModel( title: model.name,subtitle: model.artists.first?.name ?? "-",artworkURL: URL(string: model.album?.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        

        }
     
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    

}
