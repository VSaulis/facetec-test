import UIKit

class OndatoLivenessViewController: UIViewController {
    
    lazy var cameraView: OndatoLivenessCaptureView = {
        let view = OndatoLivenessCaptureView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    lazy var cameraElementsView: OndatoCameraElementsView = {
        let view = OndatoCameraElementsView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    var closeButton: OndatoButton = {
        let button = OndatoButton(.simple)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ondato_close_icon"), for: .normal)
        button.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        return button
    }()
    
    var titleLabel: OndatoPaddedLabel = {
        let label = OndatoPaddedLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 27)
        label.text = "<title>"
        label.textColor = .black
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.backgroundColor = UIColor(white: 1, alpha: 0.6)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.bottomInset = 8
        label.topInset = 8
        label.leftInset = 8
        label.rightInset = 8
        return label
    }()

    @objc func backPressed() {
        closeButton.isEnabled = false
        cameraView.stopCamera { [weak self] in
            self?.backAction?()
        }
    }
    
    var backAction: (() -> ())?
    var completion: (([UIImage]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
        view.backgroundColor = .white
        setupViews()
        setupTexts()
        cameraView.startCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      cameraElementsView.updateToLivenessFrame()
        cameraView.updatePreviewLayer()
    }
    
    func setupTexts() {
        titleLabel.text = "FaceTec_feedback_face_not_found".localized
        cameraElementsView.mainButton.setTitle("ondato_button_capture".localized.uppercased(), for: .normal)
    }
    
    func setupViews() {
        view.addSubview(cameraView)
        view.addSubview(cameraElementsView)
        view.addSubview(closeButton)
        
        cameraView.fillSuperview()

        cameraElementsView.fillSuperview()
        closeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 0))
        
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        view.addSubview(titleLabel)
        
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        
    }
}

extension OndatoLivenessViewController: OndatoLivenessCaptureViewDelegate {
    func capturedImages(_ images: [UIImage]) {
        completion?(images)
    }
}

extension OndatoLivenessViewController: OndatoCameraElementsViewDelegate {
    func takePhoto() {
        cameraView.captureLiveness()
        // hide transparent camera view
        cameraView.isHidden = true
        cameraElementsView.updateToWhiteFrame()
        _ = OndatoEmptyLoadingView.showLoadingView(in: view)
    }
    
    func tryAgain() {
        
    }
    
    func next() {
        
    }
    
    func continueAnyway() {
    
    }
}
