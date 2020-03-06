//
//  AreaSelectorVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class AreaSelectorVC: BaseViewController {
    
    var completed: ((_ areaCode: String, _ countryId: String, _ countryName: String) -> ())?
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.tableFooterView = UIView()
            tableView.sectionIndexBackgroundColor = .clear
            tableView.sectionIndexColor = .white
        }
    }
    
    private let viewModel = AreaSelectorViewModel.shared()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.startLoadingHUD()
        self.viewModel.getDisplayList { [weak self] (_) in
            self?.stopLoadingHUD()
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "国家/地区")
    }
    
    private func signalSetup() -> Void {
        
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension AreaSelectorVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.displayCountryList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.displayCountryList[section].values.first?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.displayCountryIndexList[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.viewModel.displayCountryIndexList
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = kThemeColorBackground
        let label = UILabel()
        label.font = kThemeFontLarge
        label.textColor = .white
        label.text = self.viewModel.displayCountryList[section].keys.first
        header.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalTo(header).inset(UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0))
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.cellForRow(at: indexPath) ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.backgroundColor = .clear
        cell.textLabel?.font = kThemeFontNormal
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.font = kThemeFontSmall
        cell.detailTextLabel?.textColor = .lightGray
        
        if  let datas = self.viewModel.displayCountryList[indexPath.section].values.first,
            indexPath.row < datas.count {
            let model = datas[indexPath.row]
            cell.textLabel?.text = model.name
            cell.detailTextLabel?.text = "+\(model.mobileArea ?? "")"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  let callback = self.completed,
            let datas = self.viewModel.displayCountryList[indexPath.section].values.first,
            indexPath.row < datas.count {
            let model = datas[indexPath.row]
            callback(model.mobileArea ?? "", model.countryId ?? "", model.name ?? "")
        }
        self.pop()
    }
    
}
