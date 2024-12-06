//
//  ContentView.swift
//  My Apprenticeship App
//

import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebView()
    }
}

struct WebView: UIViewRepresentable {
 
    let webView: WKWebView
    
    init() {
        webView = WKWebView(frame: .zero)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {

        webView.load(URLRequest(url: URL(string: "https://demo-apprentice-app.apprenticeships.education.gov.uk")!))
        
        webView.allowsBackForwardNavigationGestures = false;
    }
}
#Preview {
    ContentView()
}
