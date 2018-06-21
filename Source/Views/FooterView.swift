import UIKit

public protocol FooterViewDelegate: class {
    
    func footerView(_ footerView: FooterView, didExpand expanded: Bool)
    func footerView(_ footerView: FooterView, didPressReplyButton replyButton: UIButton)
    func footerView(_ footerView: FooterView, didPressAlbumButton albumButton: UIButton)
}

open class FooterView: UIView {
    open fileprivate(set) lazy var replyButton: UIButton = { [unowned self] in
        let title = NSAttributedString (
            string: "",
            attributes: LightboxConfig.CloseButton.textAttributes)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.setImage(AssetManager.image("icon_reply"), for: .normal)
        
        button.addTarget(self, action: #selector(replyButtonDidPress(_:)),
                         for: .touchUpInside)
        
        button.isHidden = !LightboxConfig.CloseButton.enabled
        
        return button
        }()
    
    open fileprivate(set) lazy var albumButton: UIButton = { [unowned self] in
        let title = NSAttributedString (
            string: "",
            attributes: LightboxConfig.CloseButton.textAttributes)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.setImage(AssetManager.image("icon_album"), for: .normal)
        
        button.addTarget(self, action: #selector(albumButtonDidPress(_:)),
                         for: .touchUpInside)
        
        button.isHidden = !LightboxConfig.CloseButton.enabled
        
        return button
        }()
    
    open fileprivate(set) lazy var infoLabel: InfoLabel = { [unowned self] in
        let label = InfoLabel(text: "")
        label.isHidden = !LightboxConfig.InfoLabel.enabled
        label.textColor = LightboxConfig.InfoLabel.textColor
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        label.delegate = self
        
        return label
        }()
    
    open fileprivate(set) lazy var pageLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: CGRect.zero)
        label.isHidden = !LightboxConfig.PageIndicator.enabled
        label.numberOfLines = 1
        
        return label
        }()
    
    open fileprivate(set) lazy var separatorView: UIView = { [unowned self] in
        let view = UILabel(frame: CGRect.zero)
        view.isHidden = !LightboxConfig.PageIndicator.enabled
        view.backgroundColor = LightboxConfig.PageIndicator.separatorColor
        
        return view
        }()
    
    let gradientColors = [UIColor(hex: "040404").alpha(0.1), UIColor(hex: "040404")]
    open weak var delegate: FooterViewDelegate?
    
    // MARK: - Initializers
    
    var ui_view = UIView()
    
    public init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.clear
        let height:CGFloat = 100
        let ui_header_view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        ui_header_view.backgroundColor = .white
        self.addSubview(ui_header_view)
        
        let ui_separator = UIView(frame: CGRect(x: 74, y: 17, width: 2, height: 15))
        ui_separator.backgroundColor = UIColor(red: 69/255, green: 79/255, blue: 98/255, alpha: 1)
        ui_separator.layer.masksToBounds = true
        ui_separator.layer.cornerRadius = 1
        self.addSubview(ui_separator)
        
        _ = addGradientLayer(gradientColors)
        
        [pageLabel, infoLabel, separatorView, replyButton, albumButton].forEach { addSubview($0) }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func expand(_ expand: Bool) {
        expand ? infoLabel.expand() : infoLabel.collapse()
    }
    
    func updatePage(_ page: Int, _ numberOfPages: Int) {
        let text = "\(page)/\(numberOfPages)"
        
        pageLabel.attributedText = NSAttributedString(string: text,
                                                      attributes: LightboxConfig.PageIndicator.textAttributes)
        pageLabel.sizeToFit()
    }
    
    public func updateText(_ text: String) {
        infoLabel.fullText = text
        
        if text.isEmpty {
            _ = removeGradientLayer()
        } else if !infoLabel.expanded {
            _ = addGradientLayer(gradientColors)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        do {
            let bottomPadding: CGFloat
            if #available(iOS 11, *) {
                bottomPadding = safeAreaInsets.bottom
            } else {
                bottomPadding = 0
            }
            
            pageLabel.frame.origin = CGPoint(
                x: (frame.width - pageLabel.frame.width) / 2,
                y: frame.height - pageLabel.frame.height - 2 - bottomPadding
            )
        }
        
        separatorView.frame = CGRect(
            x: 0,
            y: pageLabel.frame.minY - 2.5,
            width: frame.width,
            height: 0.5
        )
        
        resizeGradientLayer()
    }
    
    // MARK: - Actions
    @objc func replyButtonDidPress(_ button: UIButton) {
        delegate?.footerView(self, didPressReplyButton: button)
    }
    
    @objc func albumButtonDidPress(_ button: UIButton) {
        delegate?.footerView(self, didPressAlbumButton: button)
    }
}

// MARK: - LayoutConfigurable
extension FooterView: LayoutConfigurable {
    
    @objc public func configureLayout() {
        infoLabel.frame = CGRect(x: UIScreen.main.bounds.width - 100 - 15, // 15 for padding
            y: 15,
            width: 100,
            height: 50)
        infoLabel.configureLayout()
        
        replyButton.frame.origin = CGPoint(
            x: 105,
            y: 13
        )
        
        albumButton.frame.origin = CGPoint(
            x: 26,
            y: 13
        )
    }
}

extension FooterView: InfoLabelDelegate {
    
    public func infoLabel(_ infoLabel: InfoLabel, didExpand expanded: Bool) {
        _ = (expanded || infoLabel.fullText.isEmpty) ? removeGradientLayer() : addGradientLayer(gradientColors)
        delegate?.footerView(self, didExpand: expanded)
    }
}
