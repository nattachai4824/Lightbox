import UIKit

protocol HeaderViewDelegate: class {
    func headerView(_ headerView: HeaderView, didPressDeleteButton deleteButton: UIButton)
    func headerView(_ headerView: HeaderView, didPressCloseButton closeButton: UIButton)
}

open class HeaderView: UIView {
    
    open fileprivate(set) lazy var closeButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
            string: "",
            attributes: LightboxConfig.CloseButton.textAttributes)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.setImage(AssetManager.image("icon_close"), for: .normal)
        button.setAttributedTitle(title, for: .normal)
        
        button.addTarget(self, action: #selector(closeButtonDidPress(_:)),
                         for: .touchUpInside)
        
        button.isHidden = !LightboxConfig.CloseButton.enabled
        
        return button
        }()
    
    open fileprivate(set) lazy var deleteButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
            string: LightboxConfig.DeleteButton.text,
            attributes: LightboxConfig.DeleteButton.textAttributes)
        
        let button = UIButton(type: .system)
        button.setAttributedTitle(title, for: .normal)
        
        button.addTarget(self, action: #selector(deleteButtonDidPress(_:)),
                         for: .touchUpInside)
        
        if let image = LightboxConfig.DeleteButton.image {
            button.setBackgroundImage(image, for: UIControlState())
        }
        
        button.isHidden = !LightboxConfig.DeleteButton.enabled
        
        return button
        }()
    
    weak var delegate: HeaderViewDelegate?
    
    
    // MARK: - Initializers
    
    public init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        let ui_header_view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
        ui_header_view.backgroundColor = .white
        self.addSubview(ui_header_view)
        
        [closeButton, deleteButton].forEach { addSubview($0) }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func deleteButtonDidPress(_ button: UIButton) {
        delegate?.headerView(self, didPressDeleteButton: button)
    }
    
    @objc func closeButtonDidPress(_ button: UIButton) {
        delegate?.headerView(self, didPressCloseButton: button)
    }
}

// MARK: - LayoutConfigurable

extension HeaderView: LayoutConfigurable {
    
    @objc public func configureLayout() {
        let topPadding: CGFloat
        
        if #available(iOS 11, *) {
            topPadding = safeAreaInsets.top
        } else {
            topPadding = 0
        }
        
        closeButton.frame.origin = CGPoint(
            x: 17,
            y: self.bounds.height - 35 ///topPadding
        )
        
        deleteButton.frame.origin = CGPoint(
            x: 17,
            y: topPadding
        )
    }
}
