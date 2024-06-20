//
//  OpebWebViewController.swift
//  V.I.P Nashville
//
//  Created by Apple on 26/09/22.
//

import UIKit
import WebKit

class OpebWebViewController : UIViewController, WKUIDelegate,WKNavigationDelegate{
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var webUrl : String?
    var barName : String?
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    override func viewDidLoad() {
        guard webUrl != nil, barName != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
          
            return
        }
        
        
        navigationBar.topItem?.title = barName
        
        webView.uiDelegate  =  self
        webView.navigationDelegate = self
        progressView.progress = 0.0
               
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addSubview(progressView)
    
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
           if keyPath == "estimatedProgress" {
                     self.progressView.alpha = 1.0
                      progressView.setProgress(Float(webView.estimatedProgress), animated: true)
                      if webView.estimatedProgress >= 1.0 {
                          UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
                              self.progressView.alpha = 0.0
                          }) { (BOOL) in
                              self.progressView.progress = 0
                          }
                          
                      }
                      
                  }
       }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    
   
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
           let urls = URL(string:webUrl!)
           let request = URLRequest(url: urls!)
           webView.load(request)
       }
}

