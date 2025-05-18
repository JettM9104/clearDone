import SwiftUI
import MapKit

// MARK: - UIColor extension for contrasting text color

extension UIColor {
    var isLight: Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness > 0.6
    }

    var contrastingTextColor: UIColor {
        return isLight ? .black : .white
    }
}

// MARK: - Models

struct CircleOverlay: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let radius: CLLocationDistance
    let color: UIColor
    var label: String
    
    var textDeltaX: CGFloat = 0
    var textDeltaY: CGFloat = 0
}

struct PolygonOverlay: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let color: UIColor
    var label: String
    
    var textDeltaX: CGFloat = 0
    var textDeltaY: CGFloat = 0
}

// MARK: - Annotation Class

class LabelAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    let color: UIColor
    let id: UUID
    
    var textDeltaX: CGFloat = 0
    var textDeltaY: CGFloat = 0
    
    init(id: UUID, coordinate: CLLocationCoordinate2D, title: String, color: UIColor) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.color = color
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var circles = [
        CircleOverlay(
            coordinate: CLLocationCoordinate2D(latitude: 43.6766666, longitude: -79.63),
            radius: 5556,
            color: .cyan,
            label: "Circle 1",
            textDeltaX: 0,  // example offset
            textDeltaY: 0
        )
    ]

    @State private var polygons = [
        PolygonOverlay(
            coordinates: [
                CLLocationCoordinate2D(latitude: 43.65, longitude: -79.38),
                CLLocationCoordinate2D(latitude: 43.66, longitude: -79.38),
                CLLocationCoordinate2D(latitude: 43.66, longitude: -79.36),
                CLLocationCoordinate2D(latitude: 43.65, longitude: -79.36)
            ],
            color: .blue,
            label: "Polygon A",
            textDeltaX: 0,
            textDeltaY: 0
        )
    ]

    var body: some View {
        MapViewWrapper(circles: $circles, polygons: $polygons)
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Map Wrapper

struct MapViewWrapper: UIViewRepresentable {
    @Binding var circles: [CircleOverlay]
    @Binding var polygons: [PolygonOverlay]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        if let first = circles.first {
            let region = MKCoordinateRegion(
                center: first.coordinate,
                latitudinalMeters: first.radius * 4,
                longitudinalMeters: first.radius * 4
            )
            mapView.setRegion(region, animated: false)
        }

        updateMapAnnotationsAndOverlays(mapView)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        updateMapAnnotationsAndOverlays(uiView)
    }

    private func updateMapAnnotationsAndOverlays(_ mapView: MKMapView) {
        for circle in circles {
            let mkCircle = ColoredCircle(center: circle.coordinate, radius: circle.radius, color: circle.color)
            mapView.addOverlay(mkCircle)

            let annotation = LabelAnnotation(id: circle.id, coordinate: circle.coordinate, title: circle.label, color: circle.color)
            annotation.textDeltaX = circle.textDeltaX
            annotation.textDeltaY = circle.textDeltaY
            mapView.addAnnotation(annotation)
        }

        for polygon in polygons {
            let center = centroid(of: polygon.coordinates)
            let mkPolygon = ColoredPolygon(coordinates: polygon.coordinates, color: polygon.color)
            mapView.addOverlay(mkPolygon)

            let annotation = LabelAnnotation(id: polygon.id, coordinate: center, title: polygon.label, color: polygon.color)
            annotation.textDeltaX = polygon.textDeltaX
            annotation.textDeltaY = polygon.textDeltaY
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func centroid(of coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let count = Double(coordinates.count)
        let lat = coordinates.reduce(0) { $0 + $1.latitude } / count
        let lon = coordinates.reduce(0) { $0 + $1.longitude } / count
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper

        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let coloredCircle = overlay as? ColoredCircle {
                let renderer = MKCircleRenderer(circle: coloredCircle)
                renderer.fillColor = coloredCircle.color.withAlphaComponent(0.3)
                renderer.strokeColor = coloredCircle.color
                renderer.lineWidth = 1
                return renderer
            }

            if let coloredPolygon = overlay as? ColoredPolygon {
                let renderer = MKPolygonRenderer(polygon: coloredPolygon)
                renderer.fillColor = coloredPolygon.color.withAlphaComponent(0.3)
                renderer.strokeColor = coloredPolygon.color
                renderer.lineWidth = 2
                return renderer
            }

            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let labelAnnotation = annotation as? LabelAnnotation else { return nil }

            let identifier = "PlainLabel"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
                annotationView?.isEnabled = false

                let label = UILabel()
                label.tag = 101
                label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                label.textAlignment = .center
                label.backgroundColor = UIColor.clear
                annotationView?.addSubview(label)

                annotationView?.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
                label.frame = annotationView!.bounds

                annotationView?.centerOffset = CGPoint(x: 0, y: 0)
            } else {
                annotationView?.annotation = annotation
            }

            if let label = annotationView?.viewWithTag(101) as? UILabel {
                label.text = labelAnnotation.title
                label.textColor = labelAnnotation.color.contrastingTextColor
            }

            // Zoom-based scale factor for offset
            let zoomFactor = CGFloat(mapView.region.span.latitudeDelta)
            let scale = max(1.0, 0.5 / zoomFactor)  // Adjust as needed

            annotationView?.centerOffset = CGPoint(
                x: labelAnnotation.textDeltaX * scale,
                y: labelAnnotation.textDeltaY * scale
            )

            // Alpha based on zoom level
            let zoomThreshold: CLLocationDegrees = 0.5
            let spanLatDelta = mapView.region.span.latitudeDelta
            let targetAlpha: CGFloat = spanLatDelta > zoomThreshold ? 0 : 1
            annotationView?.alpha = targetAlpha

            return annotationView
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let zoomThreshold: CLLocationDegrees = 0.5
            let spanLatDelta = mapView.region.span.latitudeDelta

            for annotationView in mapView.annotations.compactMap({ mapView.view(for: $0) }) {
                let targetAlpha: CGFloat = spanLatDelta > zoomThreshold ? 0 : 1

                if annotationView.alpha != targetAlpha {
                    UIView.animate(withDuration: 0.25) {
                        annotationView.alpha = targetAlpha
                    }
                }
            }
        }
    }
}

// MARK: - Custom Overlay Classes

class ColoredCircle: MKCircle {
    var color: UIColor = .red

    convenience init(center: CLLocationCoordinate2D, radius: CLLocationDistance, color: UIColor) {
        self.init(center: center, radius: radius)
        self.color = color
    }
}

class ColoredPolygon: MKPolygon {
    var color: UIColor = .blue

    convenience init(coordinates: [CLLocationCoordinate2D], color: UIColor) {
        var coords = coordinates
        self.init(coordinates: &coords, count: coords.count)
        self.color = color
    }
}
