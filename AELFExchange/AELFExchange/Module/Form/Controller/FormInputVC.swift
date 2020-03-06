//
//  FormInputVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

class FormInputVC: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.contentInset = UIEdgeInsets(top: -35.0, left: 0, bottom: 0, right: 0)
        t.backgroundColor = .clear
        t.separatorInset = .zero
        t.separatorStyle = .none
        t.showsVerticalScrollIndicator = false
        t.showsHorizontalScrollIndicator = false
        t.delegate = self
        t.dataSource = self
        return t
    }()
    
    let viewModel = FormInputViewModel()
    
    // MARK: - Lifecycle
    convenience init(withMode mode: FormInputMode) {
        self.init()
        self.viewModel.mode = mode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.viewModel.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.viewModel.shouldPopAutomatically {
            self.pop()
        }
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @objc private func confirmPressed() {
        self.view.endEditing(true)
        guard self.viewModel.formValidation() == true else {
            return
        }
        self.viewModel.submit()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.viewModel.controller = self
        self.viewModel.tableView = self.tableView
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func signalSetup() -> Void {
        self.viewModel.loadedSignal.observeValues { [weak self] (_) in
            self?.title = self?.viewModel.title
            for i in 0..<(self?.viewModel.forms.count ?? 0) {
                self?.tableView.register(UINib(nibName: "FormInputCell", bundle: Bundle(identifier: "FormInputCell")), forCellReuseIdentifier: "cell-\(i)")
            }
            self?.tableView.reloadData()
        }
    }
    
    private func rightButtonPressed(with data: FormInputViewItem?) {
        guard let type = data?.rightButtonType else { return }
        if type == .scanForImport {
            let scanner = GeneralQRScanVC()
            scanner.completion = { [weak self] (content) in
                self?.viewModel.fillContentForScan(with: data!, result: content)
            }
            self.push(to: scanner, animated: true)
        }
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension FormInputVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.forms.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.viewModel.footerInfo == nil ? 85.0:285.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        let button = Button(type: .custom)
        button.SubmitMode = "1"
        button.setTitle(self.viewModel.confirmButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(confirmPressed), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40.0)
            make.left.equalToSuperview().offset(20.0)
            make.right.equalToSuperview().offset(-20.0)
            make.height.equalTo(45.0)
        }
        
        if self.viewModel.footerInfo != nil {
            let label = UILabel()
            label.numberOfLines = 999
            label.attributedText = self.viewModel.footerInfo
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(button.snp.bottom).offset(25.0)
                make.left.right.equalTo(button)
                make.bottom.equalToSuperview()
            }
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell-\(indexPath.row)")
        cell?.selectionStyle = .none
        if  indexPath.row < self.viewModel.forms.count,
            let cell = cell as? FormInputCell {
            cell.textfield.tag = indexPath.row+1
            cell.sync(withData: self.viewModel.forms[indexPath.row])
            cell.rightButtonItemPressedCallback = { [weak self] (data) in
                self?.rightButtonPressed(with: data)
            }
        }
        return cell!
    }
    
}
