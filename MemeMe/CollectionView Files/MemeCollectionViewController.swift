//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Vineet Joshi on 1/21/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeCollectionCell"

class MemeCollectionViewController: UICollectionViewController {
    
    var memes: [Meme] = []
    var detailMemeImage: UIImage?
    
    // to connect this IBOutlet:
    // show Assistant Editor and click+drag from empty circle (of this outlet) to "Collection View Flow Layout"
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        syncMemes()
        
        // Given from instructor notes:
        let space: CGFloat = 10.0
        let widthDimension = (self.view.frame.size.width - (2*space)) / 3.0
        let heightDimension = (self.view.frame.size.height - (2*space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: widthDimension, height: heightDimension)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        syncMemes()
        self.collectionView?.reloadData()
    }
    
    func syncMemes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.memes = appDelegate.memes
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
        
        cell.memeImageView.image = self.memes[indexPath.row].memedImage!
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        detailMemeImage = memes[indexPath.row].memedImage
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let destinationVC = segue.destination as? MemeDetailViewController {
            destinationVC.memedImage = detailMemeImage
        }
    }

}
