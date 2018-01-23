//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Vineet Joshi on 1/21/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeTableCell"

class MemeTableViewController: UITableViewController {
    
    var memes: [Meme] = []
    var detailMemeImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        syncMemes()
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        syncMemes()
        self.tableView.reloadData()
    }
    
    func syncMemes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.memes = appDelegate.memes
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MemeTableViewCell
        
        let currentMeme: Meme = memes[indexPath.row]
        cell.memeImageView.image = currentMeme.originalImage!
        cell.topTextLabel.text = currentMeme.topText!
        cell.bottomTextLabel.text = currentMeme.bottomText!
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            memes.remove(at: indexPath.row)
            (UIApplication.shared.delegate as! AppDelegate).memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        detailMemeImage = memes[indexPath.row].memedImage
        return indexPath
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationVC = segue.destination as? MemeDetailViewController {
            destinationVC.memedImage = detailMemeImage
        }
    }
    
}
