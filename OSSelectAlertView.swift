//
//  OSSelectAlertView.swift
//  OEMP-System
//
//  Created by 柳柳晨 on 2019/3/21.
//  Copyright © 2019 XXL. All rights reserved.
//

import UIKit
typealias AlertSelectCompletion = (_ selectIndex:Int , _ selectContent:String) -> Void

class OSSelectAlertView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    //动画效果
    enum OSSAlertAnimation {
        case shake
    }
    
    //接受返回值的闭包
    var selectCompletion: AlertSelectCompletion?
    
    //全局内容数组
    var content: NSArray = NSArray()
    
    //全局标题
    fileprivate var title: String!
    
    //全局动画效果,默认抖动效果
    fileprivate var style: OSSAlertAnimation = .shake
    
    //默认弹框宽度
    fileprivate let alertWidth: CGFloat = Screen.width - 110*SCALING
    
    //默认弹框高度
    fileprivate let alertHeight: CGFloat = Screen.height - 170*SCALING
    
    //默认单行cell高度
    fileprivate let cellHeight: CGFloat = 40*SCALING
    
    //内容距离低端距离
    fileprivate let bottomDistanceHeight: CGFloat = 5*SCALING

    //标题视图
    fileprivate var titleView: AlertTitleView!
    
    //tableView内容视图
    lazy var tab: UITableView = {
        var tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView();
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 20*SCALING, bottom: 0, right: 20*SCALING)
        tableView.backgroundColor = UIColor.white
        return tableView;
    }()
    
    
    //底部视图
    lazy var bottomView: UIView = {
        var backView = UIView()
        backView.backgroundColor = UIColor.white
        return backView
    }()

    
    /// 视图加载方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - contentArr: 内容
    ///   - style: 动画样式
    @discardableResult
    init(title: String , contentArr: [String] , style: OSSAlertAnimation, completion: @escaping AlertSelectCompletion) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
        selectCompletion = completion
        self.title = title
        content = contentArr as NSArray
        self.style = style
        
        let dismissView = UIView(frame: self.frame)
        let layer = CALayer()
        layer.opacity = 0.5
        layer.frame = bounds
        layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        dismissView.layer.addSublayer(layer)
        addSubview(dismissView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        dismissView.addGestureRecognizer(tap)
        
        let titleHeight: CGFloat = title.height(with: CGSize(width: alertWidth-AlertTitleView.deleteMaxX*2, height: .infinity), font: UIFont.systemFont(ofSize: 18))+AlertTitleView.startPosition+AlertTitleView.endPosition
        titleView = AlertTitleView(frame: CGRect(x: 0, y: 0, width: alertWidth, height: titleHeight))
        titleView.deleteBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        titleView.title = title
        bottomView.addSubview(titleView)
        bottomView.addSubview(tab)
        bottomView.layer.masksToBounds = true
        bottomView.layer.cornerRadius = 4
        addSubview(bottomView)
        
        //动态计算高度
        let totalHeight = CGFloat(contentArr.count)*cellHeight+cellHeight*0.5+titleHeight+bottomDistanceHeight>=alertHeight ? alertHeight : CGFloat(contentArr.count)*cellHeight+cellHeight*0.5+titleHeight+bottomDistanceHeight
        bottomView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: self.alertWidth, height: totalHeight))
        }
        titleView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(titleHeight)
        }
        tab.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleView.snp.bottom)
            make.bottom.equalToSuperview().offset(-bottomDistanceHeight)
        }
        show()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - UITableView代理方法
extension OSSelectAlertView  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.content.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AlertCell.reusableWithClassCell(tableView) as! AlertCell
        cell.contentLabel.text = self.content.object(at: indexPath.row) as? String
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! AlertCell
        cell.selectState = true
        selectCompletion?(indexPath.row , cell.contentLabel?.text ?? "")
        self.close()
    }
}

// MARK: - 自定义cell
class AlertCell: UITableViewCell {
    
    fileprivate var contentLabel : UILabel!
    fileprivate var iconImgView : UIImageView!
    var selectState : Bool?{
        willSet {
            self.iconImgView.isHidden = !(newValue != nil)
            self.contentLabel.textColor = (newValue != nil) ? UIColor(hexString: "#4C88FF") : UIColor(hexString: "#999999")
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        self.createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() -> Void {
        
        selectionStyle = .none
        let imgHeight : CGFloat = 16*SCALING
        iconImgView = UIImageView()
        iconImgView.image = UIImage.init(named: "leave_pop_point")
        iconImgView.isHidden = true
        contentView.addSubview(iconImgView)
        
        contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.textAlignment = NSTextAlignment.center
        contentLabel.textColor = UIColor(hexString: "#999999")
        contentView.addSubview(contentLabel)
        
        contentLabel.snp.makeConstraints { (make) in
            make.centerY.centerX.height.equalToSuperview()
            make.width.equalTo(150*SCALING)
        }
        self.iconImgView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(contentLabel.snp.leading).offset(-5*SCALING)
            make.size.equalTo(CGSize(width: imgHeight, height: imgHeight))
        }
    }
    
}


// MARK: - 动画加载视图+动画关闭视图
extension OSSelectAlertView {
    
    func show() -> Void {
        UIApplication.shared.delegate?.window??.addSubview(self)
        switch self.style {
        case .shake:
            self.bottomView.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomView.transform =
                    CGAffineTransform(scaleX: 1.005, y: 1.005)
            }) { (Bool) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.bottomView.transform =
                        CGAffineTransform(scaleX: 1, y: 1)
                })
            }
        }
    }
    
    @objc func close() -> Void {
        switch self.style {
        case .shake:
            UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .transitionFlipFromTop, animations: {
                self.alpha = 0
            }) { (Bool) in
                self.dismissPage()
            }
        }
    }
    
    @objc func dismissPage() {
        self.bottomView.removeFromSuperview()
        self.removeFromSuperview()
    }
}

fileprivate class AlertTitleView: UIView {
    
    static fileprivate let startPosition: CGFloat = 30*SCALING
    
    static fileprivate let deleteMaxX: CGFloat = 40*SCALING
    
    static fileprivate let endPosition: CGFloat = 10*SCALING
    
    var title: String! {
        willSet {
            titleLabel.text = newValue
        }
    }
    
    var deleteBtn: UIButton!
    
    fileprivate var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createSubView() {
        titleLabel = UILabel(frame: CGRect(x: AlertTitleView.deleteMaxX, y: AlertTitleView.startPosition, width: width-AlertTitleView.deleteMaxX*2, height: height-AlertTitleView.startPosition-AlertTitleView.endPosition))
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.black
        addSubview(titleLabel)
        
        deleteBtn = UIButton(type: .roundedRect)
        deleteBtn.frame = CGRect(x: width-AlertTitleView.deleteMaxX+4*SCALING, y: AlertTitleView.startPosition, width: AlertTitleView.startPosition,  height: height-AlertTitleView.startPosition-AlertTitleView.endPosition)
        deleteBtn.setImage(UIImage(named: "atten_icon_close_blue"), for: .normal)
        addSubview(deleteBtn)
    }
}

