//
//  ProfileViewController.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import UIKit
import SDWebImage
class ProfileViewController: UIViewController,UITableViewDelegate , UITableViewDataSource{
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    let headerView = UIView()
    let imageView = UIImageView()

    private var models = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        headerView.addSubview(imageView)

        tableView.tableHeaderView = headerView
       // headerView.addSubview(imageView)
        tableView.dataSource = self
        tableView.delegate = self
        title = "Profile"
        fetchProfile()
        view.backgroundColor = .systemBackground
      
    }
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }
    private func fetchProfile(){
        
        DispatchQueue.main.async {
            APICaller.shared.getUserProfile { [weak self] result in
                switch result {
                case .success(let model):

                    self?.updateUI(with: model)

                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.failedToGetProfile()
                }
            }
        }
    }
    
    private func updateUI(with model:UserProfile){
        models.append("Full Name: \(model.display_name)")
        models.append("Email Address: \(model.email)")
        models.append("User ID: \(model.id)")
        models.append("Plan: \(model.product)")
        
        createProfileImage(with:model.images?.first?.url)
        //tableView.isHidden = false
        // configure table models
        tableView.reloadData()

        
        
    }
    
    private func createProfileImage(with url:String? ){
        guard let urlString = url , let url = URL(string: urlString) else {return}
        print(urlString)
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5)
        let imagesize :CGFloat = headerView.height/2
        imageView.frame =  CGRect(x: 0, y: 0, width: imagesize, height: imagesize)
       
        imageView.center = headerView.center
        imageView.sd_setImage(with: url)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imagesize/2
        imageView.contentMode = .scaleAspectFill
    }
    private func failedToGetProfile(){
        let label = UILabel(frame: .zero)
        label.text = "Failed to load Profile"
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }

}

