//
//  CardSelectViewController.swift
//  SelectSyncer
//
//  Created by SEONGJUN on 2021/01/09.
//

import UIKit

protocol CardSelectViewControllerDelegate: class {
    func hideSelectedCollection()
    func showSelectedCollection()
    func moveToOriginalPosition()
}

final class CardSelectViewController: UIViewController {

    // MARK: - Properties
    private weak var viewModel: CardMainViewModel!
    weak var delegate: CardSelectViewControllerDelegate?
    
    private let hideButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("숨김", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.9276365638, green: 0.1862117052, blue: 0.4215507805, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.addTarget(self, action: #selector(didTapHide), for: .touchUpInside)
        return btn
    }()

    private let showButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("보임", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.9276365638, green: 0.1862117052, blue: 0.4215507805, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.addTarget(self, action: #selector(didTapShow), for: .touchUpInside)
        return btn
    }()

    private let resetButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("초기화", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.9276365638, green: 0.1862117052, blue: 0.4215507805, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        return btn
    }()
    
    private var stack: UIStackView!
    var collection: UICollectionView!
    
    
    // MARK: - Life cycle
    init(viewModel: CardMainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTopMenu()
        configureCollectionView()
    }
    
    
    // MARK: - Initial Setup
    private func configureTopMenu() {
        stack = UIStackView(arrangedSubviews: [hideButton, showButton, resetButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.layout
            .top()
            .leading()
            .trailing()
            .height(equalToconstant: UIHelper.menuBarHeight)
    }
    
    private func configureCollectionView() {
        collection = UICollectionView(frame: view.frame,
                                      collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collection)
        collection.backgroundColor = .white
        collection.dataSource = self
        collection.delegate = self
        collection.register(CardCell.self,
                            forCellWithReuseIdentifier: String(describing: CardCell.self))
        collection.contentInset.bottom = statusBarHeight + UIHelper.totalUpperSideHeight + UIHelper.menuBarHeight + view.safeAreaInsets.bottom 
        collection.layout
            .top(equalTo: stack.bottomAnchor)
            .leading()
            .trailing()
            .bottom()
    }
    
    
    // MARK: - Action Handler
    @objc private func didTapHide() {
        delegate?.hideSelectedCollection()
    }
    
    @objc private func didTapShow() {
        delegate?.showSelectedCollection()
    }
    
    @objc private func didTapReset() {
        viewModel.reset()
        delegate?.moveToOriginalPosition()
    }
}


// MARK: - UICollectionViewDataSource
extension CardSelectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.defaultCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CardCell.self),
                                                      for: indexPath) as! CardCell
        let card = viewModel.defaultCards[indexPath.row]
        cell.card = viewModel.checkCardIsSelected(card: card)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CardSelectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell, let card = cell.card else { return }
        viewModel.updateSelectedCards(card: card)
    }
}


