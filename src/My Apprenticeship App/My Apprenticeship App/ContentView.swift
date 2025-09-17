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
    // static var baseUrl: String = "pp-apprentice-app.apprenticeships.education.gov.uk"
    static var baseUrl: String = "my-apprenticeship.apprenticeships.education.gov.uk"
}

struct ContentView: View {
    @State private var shouldLoadContent = false
    @State private var isLoading = true
    @State private var reloadTrigger = UUID()
    
    private var webviewLoaderURL: String {
        shouldLoadContent
            ? "https://" + AppConfig.baseUrl + "/Home/Index"
            : "https://" + AppConfig.baseUrl + "/Home/Empty"
    }

    var body: some View {
        ZStack {
            WebView(
                url: webviewLoaderURL,
                isLoading: $isLoading,
                reloadTrigger: $reloadTrigger
            )
            .id(reloadTrigger)  // Force reload when URL changes
            
            // Loading indicator with background
            if isLoading {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .frame(width: 100, height: 100)
                        .shadow(radius: 10)
                    
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        Text("Loading...")
                            .padding(.top, 8)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .onAppear {
            handleInitialATTStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            handleAppActivation()
        }
    }
    
    private func handleInitialATTStatus() {
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        // Handle already determined status immediately
        if status != .notDetermined {
            // If already determined, load content immediately
            shouldLoadContent = true
        }
    }

    private func handleAppActivation() {
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        if status == .notDetermined {
            // Request ATT permission if not determined
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    // Always load main content after ATT request
                    self.shouldLoadContent = true
                    self.reloadTrigger = UUID()  // Force reload with new URL
                }
            }
        } else if !shouldLoadContent {
            // If content not loaded but ATT already determined
            shouldLoadContent = true
            reloadTrigger = UUID()
        }
    }
}

struct WebView: UIViewRepresentable {
    var url: String
    @Binding var isLoading: Bool
    @Binding var reloadTrigger: UUID
    
    func makeUIView(context: Context) -> WKWebView {
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
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Only reload if URL has changed
        if context.coordinator.currentURL != url {
            uiView.load(URLRequest(url: URL(string: url)!))
            context.coordinator.currentURL = url
        }
        // Or if we need to retry
        else if context.coordinator.needsReload {
            uiView.reload()
            context.coordinator.needsReload = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, reloadTrigger: $reloadTrigger)
    }
}

class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    @Binding var isLoading: Bool
    @Binding var reloadTrigger: UUID
    var needsReload = false
    var currentURL: String?
    private var retryCount = 0
    private let maxRetries = 3
    
    init(isLoading: Binding<Bool>, reloadTrigger: Binding<UUID>) {
        _isLoading = isLoading
        _reloadTrigger = reloadTrigger
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        retryCount = 0  // Reset retry count on success
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Handle regular navigation errors
        isLoading = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Handle provisional loading errors (initial page load)
        if retryCount < maxRetries {
            retryCount += 1
            needsReload = true
            reloadTrigger = UUID()  // Trigger reload
        } else {
            isLoading = false
            retryCount = 0  // Reset after max retries
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Set tracking cookie based on ATT status
        if isTrackingAccessAvailable() {
            print("accepted ATT")
            let allowCookie = HTTPCookie(properties: [
                .domain: AppConfig.baseUrl,
                .path: "/",
                .name: "SFA.ApprenticeApp.CookieTrack",
                .value: "1",
                .secure: "true",
                .expires: NSDate(timeIntervalSinceNow: 31556926)
            ])!
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(allowCookie)
        } else {
            print("declined ATT")
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
        
        // Debug: Print all cookies
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                print("Cookie: \(cookie.name)=\(cookie.value)")
            }
        }

        // Handle special URL schemes
        if navigationAction.targetFrame == nil {
            UIApplication.shared.open(navigationAction.request.url!)
            decisionHandler(.cancel)
            return
        }
        
        if navigationAction.request.url?.scheme == "tel" {
            UIApplication.shared.open(navigationAction.request.url!)
            decisionHandler(.cancel)
            return
        }
        
        if navigationAction.request.url?.scheme == "mailto" {
            UIApplication.shared.open(navigationAction.request.url!)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func isTrackingAccessAvailable() -> Bool {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized:
            return true
        default:
            return false
        }
    }
}

#Preview {
    ContentView()
}
