//
//  AppDetailController.swift
//  somestore
//
//  Created by Kanat A on 13/03/2017.
//  Copyright © 2017 ak. All rights reserved.
//

import UIKit

class AppDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout  {
    
    // data source 
    var app: App? {
        didSet {
            
            if app?.screenshots != nil {
                // stop task
                return
            }
           
            if let id = app?.id {
                
                var urlString = String()
                if id == 1 {
                     urlString = "https://api.myjson.com/bins/15jbtb"
                } else {
                     urlString = "https://api.myjson.com/bins/7nrhr"
                }
                
                URLSession.shared.dataTask(with: URL.init(string: urlString)!, completionHandler: { (data, responce, error) in
                    
                    if error != nil {
                        print(error?.localizedDescription ?? [] )
                        return
                    }
                    
                    do {
                        let json = try(JSONSerialization.jsonObject(with: data!, options: .mutableContainers))  as? [String:Any]
                        
                        let appDetail = App()
                        appDetail.setValuesForKeys(json! )
                        
                        // save parced app
                        self.app = appDetail
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                        
                    } catch let err {
                        print(err)
                    }
                    
                }).resume()
            }
        }
    }
    
    fileprivate let headerId = "headerId"
    fileprivate let cellId = "cellId"
    fileprivate let descriptionCellId = "descriptionCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(AppDetailHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        collectionView?.register(ScreenshotsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(AppDetailDescriptionCell.self, forCellWithReuseIdentifier: descriptionCellId)
    }
    
    //MARK - UICollectionViewDataSource (vert cv)
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // decription
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: descriptionCellId, for: indexPath) as! AppDetailDescriptionCell
            
            cell.textView.attributedText = descriptionAttributedText()
            
            return cell
        }
        
        // screenshots
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenshotsCell
        
        cell.app = app
        
        return cell
    }
    
    fileprivate func descriptionAttributedText() -> NSAttributedString {
        
        let attributedText = NSMutableAttributedString(string: "Description\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
        let range = NSRange.init(location: 0, length: attributedText.string.characters.count)
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: style, range: range)
        
        if let desc = app?.desc {
            attributedText.append(NSMutableAttributedString(string: desc, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 11), NSForegroundColorAttributeName: UIColor.darkGray ]))
        }
        
        return attributedText
    }
    
    //MARK - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 1 {
            // нарисуем estimated rect для текста
            let rect = descriptionAttributedText().boundingRect(with: CGSize(width: view.frame.width, height: 1000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            
            return CGSize(width: view.frame.width, height: rect.height + 30)
        }
        
        return CGSize(width: view.frame.width, height: 170) 
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! AppDetailHeader
        
        header.app = app
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: view.frame.width, height: 170)
    }
    
}


class AppDetailDescriptionCell: BaseCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE DESCRIPTION"
        return tv
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(textView)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: textView)
        addConstraintsWithFormat(format: "H:|-14-[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat(format: "V:|-4-[v0]-4-[v1(1)]|", views: textView, dividerLineView)
    }
}


class AppDetailHeader: BaseCell {
    
    var app: App? {
        didSet {
            if let imageName = app?.imageName {
                imageView.image = UIImage(named: imageName)
            }
            
            nameLabel.text = app?.name
            
            if let price = app?.price?.stringValue {
                buyButton.setTitle("$\(price)", for: .normal)
            }
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Details", "Reviews", "Related"])
        sc.tintColor = .darkGray
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "TEST"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let buyButton: UIButton = {
        let bb = UIButton(type: .system)
        bb.setTitle("Buy", for: .normal)
        bb.layer.borderColor = UIColor(colorLiteralRed: 0, green: 129/255, blue: 250/255, alpha: 1).cgColor
        bb.layer.borderWidth = 1
        bb.layer.cornerRadius = 5
        bb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return bb
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addSubview(segmentedControl)
        addSubview(nameLabel)
        addSubview(buyButton)
        addSubview(dividerLineView)

        addConstraintsWithFormat(format: "H:|-14-[v0(100)]-8-[v1]|", views: imageView, nameLabel)
        addConstraintsWithFormat(format: "V:|-14-[v0(100)]", views: imageView)
        
        addConstraintsWithFormat(format: "V:|-14-[v0(20)]", views: nameLabel)
        
        addConstraintsWithFormat(format: "H:|-40-[v0]-40-|", views: segmentedControl)
        addConstraintsWithFormat(format: "V:[v0(34)]-8-|", views: segmentedControl)

        addConstraintsWithFormat(format: "H:[v0(60)]-14-|", views: buyButton)
        addConstraintsWithFormat(format: "V:[v0(32)]-56-|", views: buyButton)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView)
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
         addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


