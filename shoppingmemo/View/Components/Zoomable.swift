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

//struct ZoomableModifier: ViewModifier {
//    let maxScale: CGFloat
//    @State private var scale: CGFloat = 1
//    @State private var baseScale: CGFloat = 1
//    @State private var offset: CGSize = .zero
//    @State private var baseOffset: CGSize = .zero
//
//    func body(content: Content) -> some View {
//        GeometryReader { geometry in
//            content
//                .scaleEffect(scale)
//                .offset(offset)
//                .gesture(
//                    magnifyGesture(size: geometry.size)
//                )
//                .simultaneousGesture(
//                    dragGesture(size: geometry.size)
//                )
//                .onTapGesture(count: 2) {
//                    withAnimation(.spring()) {
//                        scale = 1
//                        baseScale = 1
//                        offset = .zero
//                        baseOffset = .zero
//                    }
//                }
//                .frame( width: geometry.size.width, height: geometry.size.height)
//                .clipped()
//        }
//    }
//
//    private func magnifyGesture(size: CGSize) -> some Gesture {
//        MagnifyGesture()
//            .onChanged { value in
//                let newScale = min(max(baseScale * value.magnification, 1), maxScale)
//                let scaleDelta = newScale / scale
//                let anchorX = value.startAnchor.x * size.width
//                let anchorY = value.startAnchor.y * size.height
//                let dx = (anchorX - size.width / 2) * (1 - scaleDelta)
//                let dy = (anchorY - size.height / 2) * (1 - scaleDelta)
//                offset.width += dx
//                offset.height += dy
//                scale = newScale
//                offset = clampedOffset(offset, scale: scale, size: size)
//            }
//            .onEnded { _ in
//                baseScale = scale
//                baseOffset = offset
//            }
//    }
//
//    private func dragGesture(size: CGSize) -> some Gesture {
//        DragGesture()
//            .onChanged { value in
//                guard scale > 1 else { return }
//                let proposed = CGSize(width: baseOffset.width + value.translation.width, height: baseOffset.height + value.translation.height)
//                offset = clampedOffset(proposed, scale: scale, size: size)
//            }
//            .onEnded { _ in
//                baseOffset = offset
//            }
//    }
//
//    private func clampedOffset(_ proposed: CGSize, scale: CGFloat, size: CGSize) -> CGSize {
//        guard scale > 1 else { return .zero }
//        let maxX = (size.width * (scale - 1)) / 2
//        let maxY = (size.height * (scale - 1)) / 2
//        return CGSize(
//            width: min(max(proposed.width, -maxX), maxX),
//            height: min(max(proposed.height, -maxY), maxY)
//        )
//    }
//}
//
//extension View {
//    func zoomable(maxScale: CGFloat = 5) -> some View {
//        modifier(ZoomableModifier(maxScale: maxScale))
//    }
//}
