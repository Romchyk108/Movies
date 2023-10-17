//
//  PlayerViewController.swift
//  Movies
//
//  Created by Roman Shestopal on 23.10.2023.
//

import Foundation
import AVFoundation
import UIKit
import WebKit

class PlayerViewController: UIViewController {
    private let url: URL
    private var webView = WKWebView()
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfig = WKWebViewConfiguration()
        webConfig.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: self.view.frame, configuration: webConfig)
        view.addSubview(webView)
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    
    
}
