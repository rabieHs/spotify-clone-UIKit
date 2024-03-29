//
//  ViewController.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import UIKit


enum BrowseSectionType {
    case newReleases(viewModels:[NewReleasesCellViewModel])
    case featuredPlaylists(viewModels:[FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewModels:[RecommendedCellViewModel])
    
    var title : String {
        switch self {
        case .newReleases:
            return "New Released Albums"
        case .featuredPlaylists:
            return "Featured Playlists"
        case .recommendedTracks:
            return "Recommended"
        }
    }
}
class HomeViewController: UIViewController  {

    
    private var newAlbums: [Album] = []
    private var playlists:[Playlist] = []
    private var tracks : [AudioTrack] = []
    
    private var collectionView : UICollectionView =  UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { sectionInex, _ -> NSCollectionLayoutSection? in
        return  createSectionLayout(section: sectionInex)
      })
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        
        
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
        
        addLongTabGesture()


      //  let layout =

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func addLongTabGesture(){
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }

    
    private func configureCollectionView(){
        view.addSubview(collectionView)
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
    // register header
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
   
    private func fetchData(){
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases : NewReleasesResponse?
        var featuredPlatlist : FeaturedPlaylistsResponse?
        var recommendedTracks : RecommendationsResponse?
        APICaller.shared.getNewReleases { result in
            defer{
                group.leave()
            }
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        APICaller.shared.getFeaturedPlaylists { result in
            defer{
                group.leave()
            }
            switch result {
            case .success(let model):
              
                featuredPlatlist = model
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        APICaller.shared.getRecommendedGenres { result in
            
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement(){
                        seeds.insert(random)
                  

                    }
                }
                APICaller.shared.getRecommendations(genres: seeds) { result in
                    defer{
                        group.leave()
                    }
                    switch result {
                    case .success(let model):
                        
                        recommendedTracks = model
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                    
                }
            case .failure(let failure):
                break
            }
        }
        
        group.notify(queue: .main){
            
            guard   let newAlbums = newReleases?.albums.items,
                    let playlists = featuredPlatlist?.playlists.items,
                    let tracks = recommendedTracks?.tracks else {
                return
            }
            self.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
        }
       
    }
    

    
    
    private func configureModels(newAlbums: [Album],playlists:[Playlist],tracks : [AudioTrack]){
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        print(newAlbums.count)
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(name: $0.name,
                                            artworkURL: URL(string: $0.images.first?.url ?? ""), numberOfTracks: $0.total_tracks, artistName: $0.artists.first?.name ?? "_"
            )
        })))
        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({return FeaturedPlaylistCellViewModel(name: $0.name, artworkURL: URL(string: $0.images.first?.url ?? ""), creatorName: $0.owner.display_name)})))
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({return RecommendedCellViewModel(name: $0.name, artistName: $0.artists.first?.name ?? "-", artworkURL: URL(string: $0.album?.images.first?.url ?? ""))})))
        
        collectionView.reloadData()
    }
    
    private func  showSuccessAlert(){
        let alert = UIAlertController(title: "Success", message: "Track successfully added to Playlist", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }


@objc func didTapSettings(){
            let vc = SettingsViewController()
    vc.title = "Settings"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
        }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer){
        guard gesture.state == .began else {
            return
        }
        
        let touchPoint = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint), indexPath.section == 2  else{
            return
        }
        
        let model = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(title: model.name, message: "Would you like to add this track to a playlist ? ", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .default , handler: {[weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APICaller.shared.addTrackToPlaylist(track: model, playlist: playlist) {[weak self] success in
                        if(success){
                            self?.showSuccessAlert()
                        }
                    }
                }
                
                vc.title = "Select Playlist"
                self?.present(UINavigationController(rootViewController: vc), animated: true)
            }
        }))
        
        present(actionSheet, animated: true)
        
    }
    
    
    
}



extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type{
        case .newReleases( let viewModels):
            return viewModels.count
        case .featuredPlaylists(let viewModels):
            return viewModels.count

        case .recommendedTracks(let viewModels):
            return viewModels.count

        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = sections[indexPath.section]
        switch type{
        case .newReleases( let viewModels):
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else {return UICollectionViewCell()}
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
              return cell
        case .featuredPlaylists(let viewModels):
            
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else {return UICollectionViewCell()}
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
              return cell
        case .recommendedTracks(let viewModels):
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {return UICollectionViewCell()}
            let viewModel = viewModels[indexPath.row]

            cell.configure(with: viewModel)
            //cell.backgroundColor = .blue
              return cell
        }

    

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView,kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let title = sections[section].title
        
        header
            .configure(with: title)
        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()
        
        let section = sections[indexPath.section]
        switch section {
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlayListViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
        case .recommendedTracks:
            let track = tracks[indexPath.row]
            PlayerPresenter.shared.startPlayback(from: self, track: track)
            break
        }
    }
    
   static  func createSectionLayout(section : Int)-> NSCollectionLayoutSection{
      let supplementaryViews =  [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
        switch section {
        case 0 :
            //Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //verical Group inside a horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(390)), subitem: item, count: 3)
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390)), subitem: verticalGroup, count: 1)
            //Section
            let section  = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        case 1 :
            //Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //verical Group inside a horizontal group
          
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: item, count: 2)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: verticalGroup, count: 1)
            //Section
            let section  = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews

            return section
            
            
        case 2 :   //Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //verical Group inside a horizontal group
          
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)), subitem: item, count: 1)
            //Section
            let section  = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews

            return section
            
        default:
            //Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //verical Group inside a horizontal group
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(390)), subitem: item, count: 1)
            
            //Section
            let section  = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews

            return section
            
        }
    }
    
    
    
    
}

