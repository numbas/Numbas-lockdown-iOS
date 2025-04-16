import SwiftUI
import WebKit
import Combine
import os

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

struct BrowserView: UIViewRepresentable {
    
    public typealias UIViewType = WKWebView
    @ObservedObject var viewModel: LaunchData

    private let webView: WKWebView = WKWebView()
    
    public func makeUIView(context: UIViewRepresentableContext<BrowserView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator as? WKUIDelegate
        guard let url: String = viewModel.launchSettings?.url else {
            return webView
        }
        webView.load(URLRequest(url: URL(string: url)!))
        return webView
    }

    public func updateUIView(_ nsView: WKWebView, context: UIViewRepresentableContext<BrowserView>) {
        
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: LaunchData

        init(_ viewModel: LaunchData) {
           //Initialise the WebViewModel
           self.viewModel = viewModel
        }
        
        public func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) { }

        public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) { }

        //After the webpage is loaded, assign the data in WebViewModel class
        public func webView(_ web: WKWebView, didFinish: WKNavigation!) {
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let launchSettings = viewModel.launchSettings else {
                decisionHandler(.allow)
                return
            }
            
            // If this request already has an Authorization, usually because it is a modified one made on a previous iteration of this function, let it continue.
            if navigationAction.request.value(forHTTPHeaderField: "Authorization") != nil {
                decisionHandler(.allow)
                return
            }
            
            // Don't modify requests which are not in the main frame.
            if let isMainFrame = navigationAction.targetFrame?.isMainFrame {
                if(!isMainFrame) {
                    decisionHandler(.allow)
                    return
                }
            }

            // If the request is in the top-level frame, cancel it and re-load it with the Authorization header added.
            decisionHandler(.cancel)

            var customRequest = navigationAction.request
            customRequest.setValue("Basic \(launchSettings.token)", forHTTPHeaderField: "Authorization")
            
            

            webView.customUserAgent = "Numbas standalone (Version: \(Bundle.main.releaseVersionNumber ?? "")) (Build: \(Bundle.main.buildVersionNumber ?? "")) (Platform: ios)"
            webView.load(customRequest)
        }

    }

}
