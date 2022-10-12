import SwiftUI
import WebKit
import Combine

struct BrowserView: UIViewRepresentable {
    
    public typealias UIViewType = WKWebView
    @ObservedObject var viewModel: LaunchData

    private let webView: WKWebView = WKWebView()
    public func makeUIView(context: UIViewRepresentableContext<BrowserView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator as? WKUIDelegate
        webView.load(URLRequest(url: URL(string: viewModel.launchSettings?.url ?? "https://www.numbas.org.uk")!))
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

        private var urlrequestCurrent: URLRequest?

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let launchSettings = viewModel.launchSettings else {
                decisionHandler(.allow)
                return
            }
            if let currentrequest = self.urlrequestCurrent {
                if currentrequest == navigationAction.request {
                    self.urlrequestCurrent = nil
                    decisionHandler(.allow)
                    return
                }
            }

            decisionHandler(.cancel)

            var customRequest = navigationAction.request
            customRequest.setValue("Basic \(launchSettings.token)", forHTTPHeaderField: "Authorization")
            self.urlrequestCurrent = customRequest
            webView.load(customRequest)
        }

    }

}
