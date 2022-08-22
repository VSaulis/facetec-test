class OndatoEmptyLoadingView: OndatoLoadingView {
    static func showLoadingView(in view: UIView) -> UIView {
        let loadingView = OndatoEmptyLoadingView(frame: .zero)

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.isHidden = true
        view.addSubview(loadingView)
        if #available(iOS 11.0, *) {
            loadingView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        } else {
            loadingView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        }

        UIView.transition(with: view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            loadingView.isHidden = false
        }, completion: nil)

        return loadingView
    }

    override func setupViews() {
        addSubview(indicatorView)
        indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
