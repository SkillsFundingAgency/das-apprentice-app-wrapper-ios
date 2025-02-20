//
//  ContentView.swift
//  My Apprenticeship App
//

import Foundation
import SwiftUI
import AppTrackingTransparency
import SafariServices
@preconcurrency import WebKit

class AppConfig {
    static var baseUrl: String = "my-apprenticeship.apprenticeships.education.gov.uk"
}

struct ContentView: View {
    @State private var shouldLoadContinueURL = false

    private var webviewLoaderURL: String {
        shouldLoadContinueURL
            ? "https://" + AppConfig.baseUrl + "/Home/Index"
            : "https://" + AppConfig.baseUrl + "/Home/Empty"
    }

    var body: some View {
        WebView(url: webviewLoaderURL)
            .id(shouldLoadContinueURL) // Force reload when this changes
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                handleAppActivation()
            }
    }

    private func handleAppActivation() {
        ATTrackingManager.requestTrackingAuthorization { status in
            if status == .authorized || status == .denied {
                shouldLoadContinueURL = true
            }
        }
    }
}

struct WebView: UIViewRepresentable {
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
        if isTrackingAccessAvailable() {
            print("accepted ATT")
            // if accepted set cookie
            let allowCookie = HTTPCookie(properties: [
                .domain: AppConfig.baseUrl,
                .path: "/",
                .name: "SFA.ApprenticeApp.CookieTrack",
                .value: "1",
                .secure: "true",
                .expires: NSDate(timeIntervalSinceNow: 31556926)
            ])!
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(allowCookie)
        }
        else
        {
            print("declined ATT")
            // if declined set cookie
            let disallowedCookie = HTTPCookie(properties: [
                .domain: AppConfig.baseUrl,
                .path: "/",
                .name: "SFA.ApprenticeApp.CookieTrack",
                .value: "0",
                .secure: "true",
                .expires: NSDate(timeIntervalSinceNow: 31556926)
            ])!
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(disallowedCookie)
        }
        
        /* Debug for cookie information */
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                print("name: " + cookie.name + " | value:" + cookie.value)
            }
        }

        // Check navigator url targets
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
    
    func isTrackingAccessAvailable() -> Bool {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined,.restricted,.denied:
            return false
        @unknown default:
            return false
        }
    }
}

#Preview {
    ContentView()
}
