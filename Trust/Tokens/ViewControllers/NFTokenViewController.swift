// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StackViewController
import Kingfisher

protocol NFTokenViewControllerDelegate: class {
    func didPressLink(url: URL, in viewController: NFTokenViewController)
}

class NFTokenViewController: UIViewController {

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()

    let token: NonFungibleTokenObject

    lazy var viewModel: NFTDetailsViewModel = {
        return NFTDetailsViewModel(token: token)
    }()
    weak var delegate: NFTokenViewControllerDelegate?

    init(token: NonFungibleTokenObject) {
        self.token = token
        super.init(nibName: nil, bundle: nil)

        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.kf.setImage(
            with: viewModel.imageURL,
            placeholder: .none
        )
        imageView.contentMode = .scaleAspectFit

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = viewModel.descriptionText
        descriptionLabel.textColor = viewModel.descriptionTextColor

        let internalButton = Button(size: .normal, style: .border)
        internalButton.translatesAutoresizingMaskIntoConstraints = false
        internalButton.setTitle(viewModel.internalButtonTitle, for: .normal)
        internalButton.addTarget(self, action: #selector(internalTap), for: .touchUpInside)

        let externalButton = Button(size: .normal, style: .border)
        externalButton.translatesAutoresizingMaskIntoConstraints = false
        externalButton.setTitle(viewModel.externalButtonTitle, for: .normal)
        externalButton.addTarget(self, action: #selector(externalTap), for: .touchUpInside)


        view.backgroundColor = .white
        navigationItem.title = viewModel.title
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(.spacer(height: 15))
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(.spacer(height: 15))
        stackView.addArrangedSubview(internalButton)
        stackView.addArrangedSubview(.spacer(height: 10))
        stackView.addArrangedSubview(externalButton)
        stackView.addArrangedSubview(.spacer(height: 10))

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 260),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
        ])
    }

    @objc func internalTap() {
        guard let url = viewModel.internalURL else { return }
        delegate?.didPressLink(url: url, in: self)
    }

    @objc  func externalTap() {
        guard let url = viewModel.externalURL else { return }
        delegate?.didPressLink(url: url, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
