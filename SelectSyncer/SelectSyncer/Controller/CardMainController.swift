//
//  CardSelectController.swift
//  SelectSyncer
//
//  Created by SEONGJUN on 2021/01/09.
//

import UIKit

final class CardMainController: UIViewController {

    var selectedCardCollection: UICollectionView!
    
    lazy var cardSeletCollection = CardSelectViewController(viewModel: viewModel)
    let cardSelectCollectionContainer = UIView()
    
    let viewModel = CardMainViewModel()
    
    private var statusCoverBar: UIView!
    
    let separatorView: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9370916486, green: 0.9369438291, blue: 0.9575446248, alpha: 1)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureUI()
        setupLongPressGestureRecognizer()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureStatusBar()
    }
     
    func configureUI() {
        configureResultCollection()
        configureSeparatorView()
        configureCardSelectCollectionContainer()
    }
    
    private func configureStatusBar() {
        statusCoverBar = UIApplication.statusBar
        guard let statusBar = statusCoverBar else {return}
        statusBar.backgroundColor = .systemBackground
        let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
        window?.addSubview(statusBar)
    }
    
    func configureResultCollection() {
        selectedCardCollection = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        selectedCardCollection.dataSource = self
        selectedCardCollection.delegate = self
        selectedCardCollection.register(CardCell.self, forCellWithReuseIdentifier: String(describing: CardCell.self))
        
        view.addSubview(selectedCardCollection)
        selectedCardCollection.backgroundColor = .white
        selectedCardCollection
            .layout
            .top(equalTo: view.safeAreaLayoutGuide.topAnchor)
            .leading()
            .trailing()
            .height(equalToconstant: UIHelper.resultCollectionViewHeight)
//        selectedCardCollectionTopConst = selectedCardCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
//        selectedCardCollectionTopConst.isActive = true
    }
    
    func configureSeparatorView() {
        view.addSubview(separatorView)
        separatorView.layout
            .top(equalTo: selectedCardCollection.bottomAnchor)
            .width(equalTo: view.widthAnchor)
            .height(equalToconstant: UIHelper.separatorHeight)
    }
    
    func configureCardSelectCollectionContainer() {
        view.addSubview(cardSelectCollectionContainer)
        cardSelectCollectionContainer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        cardSelectCollectionContainer.isUserInteractionEnabled = true
        cardSelectCollectionContainer.layout
            .top(equalTo: separatorView.bottomAnchor)
            .leading()
            .trailing()
            .height(equalTo: view.heightAnchor)
        
        cardSeletCollection.delegate = self
        add(childVC: cardSeletCollection, to: cardSelectCollectionContainer)
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    func bind() {
        viewModel.selectedCards.bind { [weak self] (_) in
            self?.selectedCardCollection.reloadData()
            self?.cardSeletCollection.collection.reloadData()
        }
    }
    
    func setupLongPressGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(reorderCollectionViewItem(_:)))
        gesture.minimumPressDuration = 0.5
        selectedCardCollection.addGestureRecognizer(gesture)
    }
    
    @objc private func reorderCollectionViewItem(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: selectedCardCollection)
    
        switch sender.state {
        case .began:
            guard let indexPath = selectedCardCollection.indexPathForItem(at: location) else { break }
            selectedCardCollection.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            selectedCardCollection.updateInteractiveMovementTargetPosition(location)
        case .cancelled:
            selectedCardCollection.cancelInteractiveMovement()
        case .ended:
            selectedCardCollection.endInteractiveMovement()
        default:
            break
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: cardSelectCollectionContainer)
        
        switch gesture.state {
        case .began:
            view.superview?.subviews.forEach({ $0.layer.removeAllAnimations() })
        case .changed:
            if cardSelectCollectionContainer.frame.minY >= view.safeAreaInsets.top
                && cardSelectCollectionContainer.frame.minY <= view.safeAreaInsets.top + UIHelper.totalUpperSideHeight {
                separatorView.transform = CGAffineTransform(translationX: 0, y: translation.y)
                selectedCardCollection.transform = CGAffineTransform(translationX: 0, y: translation.y)
                cardSelectCollectionContainer.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
            
//            gesture.setTranslation(CGPoint(x: 0, y: 0), in: view)
            
        case .ended:
            if translation.y < 0 {
                hideUpperCollection()
            } else {
                showUpperCollection()
            }
        default:
            break
        }
    }
    
    func hideUpperCollection() {
        UIView.animate(withDuration: 0.5) {
            self.separatorView.transform = CGAffineTransform(translationX: 0, y: -UIHelper.totalUpperSideHeight)
            self.selectedCardCollection.transform = CGAffineTransform(translationX: 0, y: -UIHelper.totalUpperSideHeight)
            self.cardSelectCollectionContainer.transform = CGAffineTransform(translationX: 0, y: -UIHelper.totalUpperSideHeight)
            self.cardSeletCollection.collection.contentInset.bottom = self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom
        }
    }
    
    func showUpperCollection() {
        UIView.animate(withDuration: 0.5) {
            self.separatorView.transform = .identity
            self.selectedCardCollection.transform = .identity
            self.cardSelectCollectionContainer.transform = .identity
            self.cardSeletCollection.collection.contentInset.bottom = self.view.safeAreaInsets.top + UIHelper.totalUpperSideHeight + UIHelper.menuBarHeight
        }
    }
}

extension CardMainController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectedCards.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CardCell.self),
                                                      for: indexPath) as! CardCell
        cell.card?.letter = ""
        guard var card = viewModel.selectedCards.value[indexPath.row] else { return cell }
        card.isSelected = false
        cell.card = card
        
        return cell
    }
}

extension CardMainController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        let source = sourceIndexPath.item
        let destination = destinationIndexPath.item
        
        let element = viewModel.selectedCards.value.remove(at: source)
        viewModel.selectedCards.value.insert(element, at: destination)
    }
}

extension CardMainController: CardSelectViewControllerDelegate {
    func hideSelectedCollection() {
        hideUpperCollection()
    }
    
    func showSelectedCollection() {
        showUpperCollection()
    }
    
    func moveToOriginalPosition() {
        showUpperCollection()
    }
}
