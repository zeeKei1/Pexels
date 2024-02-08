//
//  OnboardingViewController.swift
//  Pexels
//
//  Created by Zamanbek Kozhas on 31.10.2023.
//

import UIKit

class OnboardingViewController: UIViewController {

    static let KEY: String = "UserDidSeeOnboarding"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var pages: [OnboardingModel] = [] {
        didSet {
            
            pageControl.numberOfPages = pages.count
            
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: OnboardingCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        generatePages()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        skipButton.layer.cornerRadius = skipButton.frame.height / 2
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
    }
    
    func generatePages() {
        pages = [
            OnboardingModel(imageName: "onboarding1", title: "Sell Houses", subtitle: "Sell houses easily with the help of Listenoryx and to make this line big I am writing more."),
            OnboardingModel(imageName: "onboarding2", title: "We Warn You", subtitle: "We warn you whether to put your money on certain companies or not because we care for you."),
            OnboardingModel(imageName: "onboarding3", title: "Broker Relationship", subtitle: "Our brokers are good, nice and friendly. We bet you, you feel happy after meeting your broker.")
        ]
    }
    
    @IBAction func skipButtonClicked(_ sender: UIButton) {
        start()
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
        if pageControl.currentPage == pageControl.numberOfPages - 1 {
            
            start()
        } else {
            
            pageControl.currentPage += 1
            collectionView.scrollToItem(at: IndexPath(item: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
//            let x: CGFloat = collectionView.frame.width * CGFloat(pageControl.currentPage)
//            collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            
            handlePageChanges()
        }
    }
    
    func start() {
        
        UserDefaults.standard.set(true, forKey: OnboardingViewController.KEY)
        
        let mainVC = MainViewController()
        let navC = UINavigationController(rootViewController: mainVC)
        view.window?.rootViewController = navC
        view.window?.makeKeyAndVisible()
    }
    
    func handlePageChanges() {
        if pageControl.currentPage == pageControl.numberOfPages - 1 {
            
            skipButton.isHidden = true
            nextButton.setTitle("Начать", for: .normal)
        } else {
            
            skipButton.isHidden = false
            nextButton.setTitle("Дальше", for: .normal)
        }
    }
}


extension OnboardingViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        
        let onboardingModel = pages[indexPath.item]
        cell.setup(onboardingModel: onboardingModel)
        
        return cell
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating at offset x : \(scrollView.contentOffset.x)")
        print("scrollView.frame.width: \(scrollView.frame.width)")
        
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        print("pageControl.currentPage: \(pageControl.currentPage)")
        
        handlePageChanges()
    }
}
