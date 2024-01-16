//
//  SettingsViewController.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
  
    

    let tableView : UITableView={
        let tv = UITableView(frame: .zero,style: .grouped)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    private var sections = [Section]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureModels()
title = "Settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    //table view
    
    private  func configureModels(){
        sections.append(Section(title: "Profile", options: [Options(title: "View your profile", handler: {[weak self] in
            DispatchQueue.main.async {
                self?.viewProfile()

            }
        })]))
        sections.append(Section(title: "Account", options: [Options(title: "Sign Out", handler: {[weak self] in
            
            print("sign out tapped")
            DispatchQueue.main.async {
                self?.signOutTapped()

            }
        })]))
    }
    
    private func signOutTapped(){
        
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthenticationManager.shared.signOut {[weak self] signedOut in
                if signedOut {
                    DispatchQueue.main.async {
                        let navVC = UINavigationController(rootViewController: WelcomeViewController())
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true,completion: {
                            self?.navigationController?.popViewController(animated: true)

                        })                }
                }
            }
        }))
        
        present(alert, animated: true)
     
    }
    
    private func viewProfile(){
       let vc = ProfileViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // call handler for cell
        
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()

    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
   
}
