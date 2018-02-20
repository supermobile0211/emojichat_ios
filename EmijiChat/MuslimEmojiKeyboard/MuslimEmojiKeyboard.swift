//
//  MuslimEmojiKeyboard.swift
//  EmojiKeyboard
//
//  Created by Bender on 31.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

// The view controller will adopt this protocol (delegate)
// and thus must contain the keyWasTapped method
protocol MuslimEmojiKeyboardDelegate: class {
    func keyWasTapped(emojiImage: UIImage)//character: NSAttributedString)
    func keyWasTapped(gifImageName: String)
    func emojiTapped(emojiName: String)
}

class MuslimEmojiKeyboard: UIView {

    @IBOutlet weak var emojiCollectionView: UICollectionView!
    
    // This variable will be set as the view controller so that
    // the keyboard can send messages to the view controller.
    weak var delegate: MuslimEmojiKeyboardDelegate?
    
    // MARK:- keyboard initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    var emojiNames = [[URL]]()
    
    func initializeSubviews() {
        let xibFileName = "MuslimEmojiKeyboard" // xib extention not included
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)?[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        
        let nib = UINib(nibName: "MuslimEmojiCollectionViewCell", bundle: nil)
        emojiCollectionView.register(nib, forCellWithReuseIdentifier: "MuslimEmojiCollectionViewCell")
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        
        if let currentSelectedButton = self.viewWithTag(1) as? UIButton {
            self.currentSelectedButton = currentSelectedButton
        }
        
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        
        for index in 1...8 {
            let assetURL = bundleURL.appendingPathComponent("emoji_category_\(index).bundle")
            let contents = try! fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            
            emojiNames.append(contents)
            
            /*
            for item in contents
            {
                print(item.lastPathComponent)
            }*/
        }
    }
    
    var currentSelectedButton: UIButton?
    var currentSelectedIndex: Int = 0
    
    @IBAction func changeCategoryButoonTapped(_ button: UIButton) {
        currentSelectedButton?.setImage(UIImage(named: "btn_subcategory_\((currentSelectedButton?.tag)! - 1)"), for: .normal)
        currentSelectedButton = button
        currentSelectedButton?.setImage(UIImage(named: "btn_subcategory_\(button.tag - 1)_active"), for: .normal)
        
        if let index = currentSelectedButton?.tag {
            currentSelectedIndex = index - 1
        } else {
            fatalError("No index in image")
        }
        
        emojiCollectionView.reloadData()
    }
    
    // MARK:- Button actions from .xib file
    /*
    @IBAction func keyTapped(sender: UIButton) {
        // create our NSTextAttachment
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "emoji_4_1_4.png")
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        // wrap the attachment in its own attributed string so we can append it
        let imageString = NSAttributedString(attachment: imageAttachment)
        
        self.delegate?.keyWasTapped(character: imageString)
    }*/
}

//import FLAnimatedImage

extension MuslimEmojiKeyboard: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiNames[currentSelectedIndex].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MuslimEmojiCollectionViewCell", for: indexPath) as! MuslimEmojiCollectionViewCell
        
        if
            let filePath = Bundle.main.path(forResource: "emoji_category_\(currentSelectedIndex + 1).bundle/" + emojiNames[currentSelectedIndex][indexPath.row].lastPathComponent, ofType: ""),
            let image = UIImage(contentsOfFile: filePath)
        {
            cell.emojiImageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
        var emojiName = emojiNames[currentSelectedIndex][indexPath.row].lastPathComponent
        if currentSelectedIndex != 0 {
            emojiName = emojiName.replacingOccurrences(of: "keyboard", with: "emoji")
        }
        emojiName = emojiName.replacingOccurrences(of: ".png", with: "")
        delegate?.emojiTapped(emojiName: emojiName)
        return
        
        if currentSelectedIndex == 0 {
            // send gif image name
            emojiNames[0][indexPath.row].deletePathExtension()
            let lastpath = emojiNames[0][indexPath.row].lastPathComponent
            let emojiName = lastpath.replacingOccurrences(of: "keyboard", with: "emoji", options: .literal, range: nil)
            self.delegate?.keyWasTapped(gifImageName: emojiName)
            return
        }
        
        
        let cell = collectionView.cellForItem(at: indexPath) as! MuslimEmojiCollectionViewCell
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = cell.emojiImageView.image
        //        imageAttachment.image = UIImage(named: "emoji_4_1_4.png")
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        let imageString = NSAttributedString(attachment: imageAttachment)
        
        self.delegate?.keyWasTapped(emojiImage: cell.emojiImageView.image!)
    }
}
