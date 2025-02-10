//
//  ContentView.swift
//  My Apprenticeship App
//

import Foundation
import SwiftUI
import SafariServices
@preconcurrency import WebKit

struct ContentView: View {
    var body: some View {
        WebView(url: "https://my-apprenticeship.apprenticeships.education.gov.uk/")
    }
}

struct WebView: UIViewRepresentable{
    var url: String
    
    func makeUIView(context: Context) -> some WKWebView {
        guard let url = URL(string: self.url) else {
            return WKWebView()
        }
        
        let request = URLRequest(url: url)
        let wkWebView = WKWebView(frame: .zero)
        
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.uiDelegate = context.coordinator
        
        wkWebView.load(request)
        return wkWebView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<WebView>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if navigationAction.targetFrame == nil {
            UIApplication.shared.open(navigationAction.request.url!)
        }
        
        if navigationAction.request.url?.scheme == "tel" {
            UIApplication.shared.open(navigationAction.request.url!)
            decisionHandler(.cancel)
        }
        else if navigationAction.request.url?.scheme == "mailto" {
            UIApplication.shared.open(navigationAction.request.url!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

#Preview {
    ContentView()
}
