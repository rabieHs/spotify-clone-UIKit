//
//  SearchViewController.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController, UISearchResultsUpdating,UISearchBarDelegate {
   
    
    private var categories = [Category]()
    private var viewModels = [CategoryCollectionViewCellViewModel]()
    
    let searchController : UISearchController = {
      
        let search = UISearchController(searchResultsController:SearchResultViewController())
        search.searchBar.placeholder = "Songs, Albums, Artists"
        search.searchBar.searchBarStyle = .minimal
        search.definesPresentationContext = true
        return search
    }()
    
    let collectionView:UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ ->NSCollectionLayoutSection? in
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 7, bottom: 2, trailing: 7)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150)), subitem: item,count: 2)
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 10 , leading: 0, bottom: 10, trailing: 0)

        
        let section = NSCollectionLayoutSection(group: group)
        return section
        
    }))

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
      navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        view.addSubview(collectionView)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        
        APICaller.shared.getCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    
                    self?.viewModels = categories.compactMap({
                        CategoryCollectionViewCellViewModel(title: $0.name, id: $0.id, artworkURL: URL(string: $0.icons.first?.url ?? "" ))
                    })
                    self?.collectionView.reloadData()
                    break
                case .failure(let failure):
                    break
                }
            }
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func updateSearchResults(for searchController: UISearchController) {
       
        //search update with results
       
        // perform search
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let resultController  = searchController.searchResultsController as? SearchResultViewController, let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        resultController.delegate = self
        
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    resultController.update(with: results)
                    break
                case .failure(let failure):
                    break
                }
            }
        }
        
        
    }

}
extension SearchViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let    cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath)as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = viewModels[indexPath.row]
        cell.configure(with: category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()

        let category = categories[indexPath.row]
        let vc = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode  = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension SearchViewController : SearchResultViewControllerDelegate{
    func didTapResult(_ result: SearchResult) {
        switch result{
        case .album(let album):
            let vc = AlbumViewController(album: album)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .artist(let artist):
            guard let url = URL(string: artist.external_urls["spotify"] ?? "") else {
                return
            }
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        case.playlist(let playlist):
            let vc = PlayListViewController(playlist: playlist)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)

        case .track(let track):
            PlayerPresenter.shared.startPlayback(from: self, track: track)
            break
        }
    }
    
    
}
