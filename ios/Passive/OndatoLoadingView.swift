import UIKit

class OndatoLoadingView: UIView {
    
    static func showSendView(in view: UIView, progress: Float) -> UIView {
        var sendView: UIView!
      sendView = OndatoLoadingView(frame: .zero)
      (sendView as? OndatoLoadingView)?.progessView.progress = progress


        sendView.translatesAutoresizingMaskIntoConstraints = false
        sendView.isHidden = true
        view.addSubview(sendView)
        if #available(iOS 11.0, *) {
            sendView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        } else {
            sendView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        }
        
        UIView.transition(with: view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            sendView.isHidden = false
        }, completion: nil)
        
        return sendView
    }

    var progessView: OndatoProgressView = {
        let progressView = OndatoProgressView(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.6
        return progressView
    }()
    
    var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.color = UIColor(red: 253.0/255.0, green: 90.0/255.0, blue: 40.0/255.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: UIFont.systemFont(ofSize: 12.0).familyName, size: 27.0)
        label.text = "ondato_loading_title".localized
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    var subtitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: UIFont.systemFont(ofSize: 12.0).familyName, size: 17.0)
        label.text = "ondato_loading_subtitle".localized
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(progessView)
        progessView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progessView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        progessView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 34).isActive = true
        
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        addSubview(indicatorView)
        indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicatorView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -16).isActive = true
        
    }
}
