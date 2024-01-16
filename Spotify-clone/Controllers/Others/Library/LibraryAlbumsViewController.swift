//
//  LibraryPlaylistsViewController.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/2/2024.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
     var albums = [Album]()
    private var observer:NSObjectProtocol?
    
    private let noAlbumsView = ActionLabelView()
    
    private let tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tv.isHidden = true
        return tv
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setupNoAlbumsView()
        fetchData()
        observer = NotificationCenter.default.addObserver(forName: .savedNotification, object: nil, queue: .main, using: { [weak self]_ in
            self?.fetchData()
        })
      

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: (view.width-150)/2, y: (view.height-150)/2, width: 150, height: 150)
       // noAlbumsView.center = view.center
        tableView.frame = view.bounds
    }
    
     func updateUI(){
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            tableView.isHidden = false

        }else{
                //show table
            tableView.reloadData()
            noAlbumsView.isHidden = true
            tableView.isHidden = false

            }
    }
    
    func setupNoAlbumsView(){
        view.addSubview(noAlbumsView)
        noAlbumsView.delegate = self
        noAlbumsView.configure(with: ActionLabelViewViewModel(text: "You don't have save albums yet", actionTitle: "Brows"))
    }
    
    func fetchData(){
        albums.removeAll()
        APICaller.shared.getCurrentUserAlbums{ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    self?.albums = albums
                    self?.updateUI()
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }
    }
   
   
    
 

}


extension LibraryAlbumsViewController : ActionLabelViewDelegate{
    func didTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
   
    }
    
}

extension LibraryAlbumsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.name, subtitle: album.artists.first?.name ?? "-", artworkURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()

        
        let album = albums[indexPath.row]

        
        
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
       
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
