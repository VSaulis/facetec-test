import UIKit
import CoreGraphics

protocol OndatoCameraElementsViewDelegate {
    
    func takePhoto()
    func tryAgain()
    func next()
    func continueAnyway()
}

class OndatoCameraElementsView: UIView {
    
    var photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        imageView.backgroundColor = .black
        return imageView
    }()
    
    var shapeView: OndatoShapeView = {
        var view = OndatoShapeView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var shapeLayer = CAShapeLayer()
    var idLineLayer = CAShapeLayer()
    
    lazy var mainButton: OndatoButton = {
        let button = OndatoButton(.filled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("ondato_button_capture".localized.uppercased(), for: .normal)
        if let font = button.titleLabel?.font {
            button.titleLabel?.font = .boldSystemFont(ofSize: font.pointSize)
        }
        button.addTarget(self, action: #selector(handleMain), for: .touchUpInside)
        return button
    }()
    
    lazy var retryButton: OndatoButton = {
        let button = OndatoButton(.borderedBasic)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("ondato_try_again".localized.uppercased(), for: .normal)
        if let font = button.titleLabel?.font {
            button.titleLabel?.font = .boldSystemFont(ofSize: font.pointSize)
        }
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var continueButton: OndatoButton = {
        let button = OndatoButton(.filled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("FaceTec_action_continue".localized.uppercased(), for: .normal)
        if let font = button.titleLabel?.font {
            button.titleLabel?.font = .boldSystemFont(ofSize: font.pointSize)
        }
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var tryAgainButton: OndatoButton = {
        let button = OndatoButton(.borderedBasic)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("ondato_try_again".localized.uppercased(), for: .normal)
        if let font = button.titleLabel?.font {
            button.titleLabel?.font = .boldSystemFont(ofSize: font.pointSize)
        }
        button.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var continueAnywayButton: OndatoButton = {
        let button = OndatoButton(.filled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("ondato_continue_anyway".localized, for: .normal)
        button.addTarget(self, action: #selector(handleContinueAnyway), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    
    @objc func handleMain() {
        delegate?.takePhoto()
    }
    
    @objc func handleRetry() {
        delegate?.tryAgain()
    }
    
    @objc func handleContinue() {
        delegate?.next()
    }
    
    @objc func handleContinueAnyway() {
        delegate?.continueAnyway()
    }
        
    var delegate: OndatoCameraElementsViewDelegate?
    var image: UIImage? {
        didSet {
            photoImageView.image = image
            UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve], animations: { [self] in
                tryAgainButton.isHidden = true
                continueAnywayButton.isHidden = true
                shapeView.isHidden = false
                if image == nil {
                    photoImageView.isHidden = true
                    mainButton.isHidden = false
                    retryButton.isHidden = true
                    continueButton.isHidden = true
                } else {
                    photoImageView.isHidden = false
                    mainButton.isHidden = true
                    retryButton.isHidden = false
                    continueButton.isHidden = false
                }
            })
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTryAgainState(_ continueOptionEnabled: Bool) {
        mainButton.isHidden = true
        continueButton.isHidden = true
        if continueOptionEnabled {
            retryButton.isHidden = false
            continueAnywayButton.isHidden = false
            tryAgainButton.isHidden = true
        } else {
            retryButton.isHidden = true
            continueAnywayButton.isHidden = true
            tryAgainButton.isHidden = false
        }
    }
    
    func setupAnylineState() {
        mainButton.isHidden = true
        continueButton.isHidden = true
        retryButton.isHidden = true
        continueAnywayButton.isHidden = true
        tryAgainButton.isHidden = true
        shapeLayer.removeFromSuperlayer()
        shapeView.isHidden = true
    }
    
    private func setupViews() {
        addSubview(photoImageView)
        photoImageView.fillSuperview()
        
        addSubview(shapeView)
        shapeView.fillSuperview()
        
        addSubview(mainButton)

        mainButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6).isActive = true
        mainButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -68).isActive = true
        mainButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        mainButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, padding: .init(top: 0, left: 16, bottom: 68, right: 16), size: .init(width: 0, height: 50))

      mainButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        
        addSubview(retryButton)
        addSubview(continueButton)
        
        retryButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        retryButton.rightAnchor.constraint(equalTo: continueButton.leftAnchor, constant: -16).isActive = true
        continueButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        retryButton.widthAnchor.constraint(equalTo: continueButton.widthAnchor).isActive = true
        retryButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        retryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -68).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -68).isActive = true
        
        addSubview(tryAgainButton)
        tryAgainButton.anchor(top: mainButton.topAnchor, left: mainButton.leftAnchor, bottom: mainButton.bottomAnchor, right: mainButton.rightAnchor)
        
        addSubview(continueAnywayButton)
        continueAnywayButton.anchor(top: continueButton.topAnchor, left: continueButton.leftAnchor, bottom: mainButton.bottomAnchor, right: continueButton.rightAnchor)
        
    }

    func updateToNoFrame() {
        shapeView.backgroundColor = .clear
    }

    func updateToWhiteFrame() {
        shapeView.backgroundColor = .white
        shapeView.alpha = 1
    }
    
    func updateToSelfieFrame() {
        let ratio: CGFloat = 1.0

        var width: CGFloat = 0
        var height: CGFloat = 0
        var x: CGFloat = 16
        var y: CGFloat = 210

        let bottom: CGFloat = 100.0
        let maxWidth: CGFloat = frame.width - (2.0 * x)
        let maxHeight: CGFloat = frame.height - bottom - y

        if ratio >=  1.0 {
            width = maxWidth
            height = width / ratio
            y = y + (frame.height - bottom - height - y) / 2.0
        } else {
            height = maxHeight
            width = maxHeight * ratio
            x = (frame.width - width)/2.0
        }

        createRectanglePath(.init(x: x, y: y, width: width, height: height))
    }
    
    func updateToLivenessFrame() {
        let y: CGFloat = 164.0
        let x: CGFloat = 16.0
        let height: CGFloat = frame.height - 132.0 - y
        let width: CGFloat = frame.width - (2.0 * x)
        
        createOvalPath(.init(x: x, y: y, width: width, height: height))
    }
    
    func createOvalPath(_ rect: CGRect) {
        shapeView.pathRect = rect
        shapeView.isOval = true
        shapeView.layoutSubviews()
        
        idLineLayer.removeFromSuperlayer()
        shapeLayer.removeFromSuperlayer()
        
        let path = UIBezierPath(ovalIn: rect)
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 6.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        layer.addSublayer(shapeLayer)
    }
    
    func createRectanglePath(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 6.0)

        shapeView.pathRect = rect
        shapeView.isOval = false
        shapeView.layoutSubviews()
        
        idLineLayer.removeFromSuperlayer()
        shapeLayer.removeFromSuperlayer()
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 2.0
        shapeLayer.lineDashPattern = [12,9]
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
        
    }

    func addLinePath(point1: CGPoint, point2: CGPoint) {
        
        let linePath = UIBezierPath()
        linePath.move(to: point1)
        linePath.addLine(to: point2)
        
        idLineLayer = CAShapeLayer()
        idLineLayer.path = linePath.cgPath
        idLineLayer.lineWidth = 2.0
        idLineLayer.lineDashPattern = [12,9]
        idLineLayer.strokeColor = UIColor.white.cgColor
        idLineLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(idLineLayer)
    }

}
class OndatoShapeView: UIView {
    
    var pathRect = CGRect.zero
    var isOval: Bool = false {
        didSet {
            alpha = isOval ? 1 : 0.6
            backgroundColor = isOval ? .white : .black
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0.6
        backgroundColor = .black
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        if pathRect.width > 0 && pathRect.height > 0 {
            isOval ? layoutOval(rect: pathRect) : layoutRectangle(rect: pathRect)
        }
    }
    
    private func layoutRectangle(rect: CGRect) {
        let path = CGMutablePath()
        
        path.addRoundedRect(in: pathRect, cornerWidth: 6.0, cornerHeight: 6.0)
        path.addRect(CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        layer.mask = maskLayer
    }
    
    private func layoutOval(rect: CGRect) {
        let path = CGMutablePath()
        
        let oval = UIBezierPath(ovalIn: rect)
        path.addPath(oval.cgPath)
        
        path.addRect(CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
                
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.white.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        layer.mask = maskLayer
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
