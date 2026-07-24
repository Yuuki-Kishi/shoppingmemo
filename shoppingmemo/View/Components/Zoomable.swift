//
//  ZoomableModifier.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/18.
//

import SwiftUI

extension View {
    func zoomable(maxScale: CGFloat = 5) -> some View {
        modifier(
            ZoomableModifier(maxScale: maxScale)
        )
    }
}

private struct ZoomableModifier: ViewModifier {
    let maxScale: CGFloat
    func body(content: Content) -> some View {
        ZoomableContainer(maxScale: maxScale) {
            content
        }
    }
}

private struct ZoomableContainer<Content: View>: UIViewRepresentable {
    let maxScale: CGFloat
    let content: Content
    
    init(maxScale: CGFloat, @ViewBuilder content: () -> Content) {
        self.maxScale = maxScale
        self.content = content()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = maxScale
        scrollView.bouncesZoom = true
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        let hostingController = context.coordinator.hostingController
        hostingController.rootView = AnyView(content)
        let hostedView = hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.backgroundColor = .clear
        scrollView.addSubview(hostedView)
        
        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostedView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            hostedView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
        
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        context.coordinator.scrollView = scrollView
        DispatchQueue.main.async {
            context.coordinator.centerContent(in: scrollView)
        }
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = AnyView(content)
    }
    
    final class Coordinator: NSObject, UIScrollViewDelegate {
        let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
        weak var scrollView: UIScrollView?
        
        override init() {
            super.init()
            hostingController.view.backgroundColor = .clear
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerContent(in: scrollView)
        }
        
        func centerContent(in scrollView: UIScrollView) {
            guard let view = hostingController.view else { return }
            let boundsSize = scrollView.bounds.size
            var frame = view.frame
            frame.origin.x = max((boundsSize.width - frame.size.width) / 2, 0)
            frame.origin.y = max((boundsSize.height - frame.size.height) / 2, 0)
            view.frame = frame
        }
        
        @objc
        func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            guard let scrollView else { return }
            if scrollView.zoomScale > 1 {
                scrollView.setZoomScale(1, animated: true)
                return
            }
            let point = recognizer.location( in: hostingController.view)
            let targetScale = min(2, scrollView.maximumZoomScale)
            let width = scrollView.bounds.width / targetScale
            let height = scrollView.bounds.height / targetScale
            let zoomRect = CGRect(x: point.x - width / 2, y: point.y - height / 2, width: width, height: height)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
}
