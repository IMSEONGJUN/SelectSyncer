//
//  CardSelectController.swift
//  SelectSyncer
//
//  Created by SEONGJUN on 2021/01/09.
//

import UIKit

final class CardMainController: UIViewController {

    var resultCollection: UICollectionView!
//    var selectCollection: UICollectionView!
    let viewModel = CardSelectViewModel()
    
    let separatorView: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9370916486, green: 0.9369438291, blue: 0.9575446248, alpha: 1)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
    }
    
    func configureUI() {
        configureResultCollection()
        configureSeparatorView()
        
        
    }
    
    func configureResultCollection() {
        resultCollection = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        resultCollection.dataSource = self
        resultCollection.delegate = self
        resultCollection.register(CardCell.self, forCellWithReuseIdentifier: String(describing: CardCell.self))
        view.addSubview(resultCollection)
        resultCollection.backgroundColor = .white
        resultCollection
            .layout
            .top(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
            .leading()
            .trailing()
            .height(equalToconstant: UIHelper.resultCollectionViewHeight)
    }
    
    func configureSeparatorView() {
        view.addSubview(separatorView)
        separatorView.layout
            .top(equalTo: resultCollection.bottomAnchor)
            .width(equalTo: view.widthAnchor)
            .height(equalToconstant: 44)
    }

}

extension CardMainController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UIHelper.resultCollectionViewDefaultItemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CardCell.self),
                                                      for: indexPath) as! CardCell
        let card = viewModel.selectedCards.value?[indexPath.row]
        cell.card = card
        
        return cell
    }
}

extension CardMainController: UICollectionViewDelegateFlowLayout {
    
}

