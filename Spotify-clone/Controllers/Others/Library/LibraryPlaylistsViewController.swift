//
//  LibraryPlaylistsViewController.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/2/2024.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    
     var playlists = [Playlist]()
    public var selectionHandler: ((Playlist)->Void)?
    
    private let noPlayListsView = ActionLabelView()
    
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
      setupNoPlaylistsView()
        
       fetchData()
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlayListsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlayListsView.center = view.center
        tableView.frame = view.bounds
    }
    
     func updateUI(){
        if playlists.isEmpty {
            noPlayListsView.isHidden = false
            tableView.isHidden = false

        }else{
                //show table
            tableView.reloadData()
            noPlayListsView.isHidden = true
            tableView.isHidden = false

            }
    }
    
    func setupNoPlaylistsView(){
        view.addSubview(noPlayListsView)
        noPlayListsView.delegate = self
        noPlayListsView.configure(with: ActionLabelViewViewModel(text: "You don't have any playlists yet", actionTitle: "Create"))
    }
    
    func fetchData(){
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                    break
                case .failure(let error):
                    break
                }
            }
        }
    }
   
    public func showCreationUI(){
        let alert = UIAlertController(title: "New Playlist", message: "Enter Playlist Name.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Playlist..."
            
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: {_ in
            
            guard let field = alert.textFields?.first,let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            APICaller.shared.createPlaylist(with: text) { [weak self] success in
                if(success){
                    //refresh
                    self?.fetchData()
                    HapticsManager.shared.vibrate(for: .success)

                }else{
                    
                   // HapticsManager.shared.vibrate(for: .error)

                    print("failed to create playlist")
                }
            }
        }))
        present(alert, animated: true)
    }
    
    @objc func didTapClose(){
        dismiss(animated: true, completion: nil)
    }

}


extension LibraryPlaylistsViewController : ActionLabelViewDelegate{
    func didTapButton(_ actionView: ActionLabelView) {
        
        showCreationUI()
   
    }
    
}

extension LibraryPlaylistsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: playlist.name, subtitle: playlist.owner.display_name, artworkURL: URL(string: playlist.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()

        
        let playlist = playlists[indexPath.row]

        guard  selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }
        
        let vc = PlayListViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isOwner = true
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
