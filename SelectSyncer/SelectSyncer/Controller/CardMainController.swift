//
//  CardSelectController.swift
//  SelectSyncer
//
//  Created by SEONGJUN on 2021/01/09.
//

import UIKit

final class CardMainController: UIViewController {

    private enum State {
        case show
        case hide
    }
    
    // MARK: - Properties
    private var visible = true
    private var nextState: State {
        return visible ? .hide : .show
    }
    
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    
    private var selectedCardCollection: UICollectionView!
    private lazy var cardSeletCollection = CardSelectViewController(viewModel: viewModel)
    private let cardSelectCollectionContainer = UIView()
    private var statusCoverBar: UIView!
    private let separatorView: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9370916486, green: 0.9369438291, blue: 0.9575446248, alpha: 1)
        let label = UILabel()
        label.text = "이 영역은 스크롤 시 숨겨집니다"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .center
        view.addSubview(label)
        label.layout.centerX().centerY()
        return view
    }()
    
    private let viewModel = CardMainViewModel()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupLongPressGestureRecognizer()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureStatusBar()
    }
    
    
    // MARK: - Initial Setup
    private func configureUI() {
        view.backgroundColor = .systemBackground
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
    
    private func configureResultCollection() {
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
    }
    
    private func configureSeparatorView() {
        view.addSubview(separatorView)
        separatorView.layout
            .top(equalTo: selectedCardCollection.bottomAnchor)
            .width(equalTo: view.widthAnchor)
            .height(equalToconstant: UIHelper.separatorHeight)
    }
    
    private func configureCardSelectCollectionContainer() {
        view.addSubview(cardSelectCollectionContainer)
        cardSelectCollectionContainer.addGestureRecognizer(UIPanGestureRecognizer(target: self,
                                                                                  action: #selector(handlePanGesture(_:))))
        cardSelectCollectionContainer.layout
            .top(equalTo: separatorView.bottomAnchor)
            .leading()
            .trailing()
            .height(equalTo: view.heightAnchor)
        
        cardSeletCollection.delegate = self
        add(childVC: cardSeletCollection, to: cardSelectCollectionContainer)
    }
    
    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    private func bind() {
        viewModel.selectedCards.bind { [weak self] _ in
            guard let self = self else { return }
            self.selectedCardCollection.reloadData()
            self.cardSeletCollection.collection.reloadData()
        }
    }
    
    private func setupLongPressGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(reorderCollectionViewItem(_:)))
        gesture.minimumPressDuration = 0.5
        selectedCardCollection.addGestureRecognizer(gesture)
    }
    
    
    // MARK: - Action Handler
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
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began:
            if (visible && translation.y > 0) || (!visible && translation.y < 0){
                break
            }
            startInteractiveTransition(state: nextState, duration: 0.5)
        case .changed:
            var fractionComplete = translation.y / (statusBarHeight + UIHelper.totalUpperSideHeight)
            fractionComplete = visible ? -fractionComplete : fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    // MARK: - Animation Helper
    private func animateTransitionIfNeeded(state: State, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .hide:
                    self.hideUpperCollection()
                case .show:
                    self.showUpperCollection()
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
    
    private func startInteractiveTransition(state: State, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        runningAnimations.forEach({ $0.fractionComplete = fractionCompleted + animationProgressWhenInterrupted })
    }
    
    private func continueInteractiveTransition() {
        runningAnimations.forEach({ $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) })
    }
    
    private func hideUpperCollection() {
        UIView.animate(withDuration: 0.5) {
            self.separatorView.transform = CGAffineTransform(translationX: 0, y: -UIHelper.totalUpperSideHeight)
            self.selectedCardCollection.transform = CGAffineTransform(translationX: 0, y: -UIHelper.totalUpperSideHeight)
            self.cardSelectCollectionContainer.transform = CGAffineTransform(translationX: 0, y: -UIHelper.totalUpperSideHeight)
            self.cardSeletCollection.collection.contentInset.bottom = self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom
        } completion: { (_) in
            self.visible = false
        }
    }
    
    private func showUpperCollection() {
        UIView.animate(withDuration: 0.5) {
            self.separatorView.transform = .identity
            self.selectedCardCollection.transform = .identity
            self.cardSelectCollectionContainer.transform = .identity
            self.cardSeletCollection.collection.contentInset.bottom = self.view.safeAreaInsets.top + UIHelper.totalUpperSideHeight + UIHelper.menuBarHeight
        } completion: { (_) in
            self.visible = true
        }
    }
}


// MARK: - UICollectionViewDataSource
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


// MARK: - UICollectionViewDelegateFlowLayout
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


// MARK: - CardSelectViewControllerDelegate
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
