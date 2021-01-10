//
//  CardCell.swift
//  SelectSyncer
//
//  Created by SEONGJUN on 2021/01/09.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    var card: Card? {
        didSet{
            configureCell(card)
        }
    }
    
    let containerView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    let letterLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    let orderNumberLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func prepareForReuse() {
        orderNumberLabel.isHidden = true
    }
    
    func configureUI() {
        contentView.addSubview(containerView)
        containerView.frame = contentView.bounds
        
        containerView.addSubview(letterLabel)
        letterLabel.layout
            .centerY(equalTo: contentView.centerYAnchor)
            .centerX(equalTo: contentView.centerXAnchor)
        
        containerView.addSubview(orderNumberLabel)
        orderNumberLabel.layout
            .top(equalTo: contentView.topAnchor, constant: 3)
            .trailing(equalTo: contentView.trailingAnchor, constant: -3)
            .width(equalToconstant: 20)
            .height(equalToconstant: 20)
        
        orderNumberLabel.layer.cornerRadius = 10
        orderNumberLabel.clipsToBounds = true
        orderNumberLabel.isHidden = true
    }
    
    func configureCell(_ card: Card?) {
        guard let card = card else { return }
        letterLabel.text = card.letter
        orderNumberLabel.isHidden = !card.isSelected
        if let number = card.selectedOrderNumber {
            orderNumberLabel.text = "\(number)"
        }
    }
}
