import SwiftUI
import MapKit

// MARK: - UIColor extension for contrasting text color

import UIKit

extension UIColor {
    var isLight: Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return true // Assume light if unable to get color components
        }
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness > 0.6
    }
    var inverted: UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return .black
        }
        return UIColor(red: 1.0 - red,
                       green: 1.0 - green,
                       blue: 1.0 - blue,
                       alpha: alpha)
    }

    var contrastingTextColor: UIColor {
        return self.inverted
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
            color: .red,
            label: "C: CYYZ-YYZ",
            textDeltaX: 0,
            textDeltaY: 0
        ),
        CircleOverlay(
            coordinate: CLLocationCoordinate2D(latitude: 43.6766666, longitude: -79.63),
            radius: 12964,
            color: .red,
            label: "C: CYYZ-YYZ",
            textDeltaX: 0,
            textDeltaY: 0
        ),
        CircleOverlay(
            coordinate: CLLocationCoordinate2D(latitude: 43.65391, longitude: -79.65785),
            radius: 1852,
            color: .red,
            label: "C: CPA5",
            textDeltaX: 0,
            textDeltaY: 0
        ),
        CircleOverlay(
            coordinate: CLLocationCoordinate2D(latitude: 43.61778, longitude: -79.56397),
            radius: 1852,
            color: .red,
            label: "C: CPY5",
            textDeltaX: 0,
            textDeltaY: 0
        ),
        CircleOverlay(
            coordinate: CLLocationCoordinate2D(latitude: 43.56141, longitude: -79.70274),
            radius: 1852,
            color: .red,
            label: "C: CPK6",
            textDeltaX: 0,
            textDeltaY: 0
        ),
        CircleOverlay(
            coordinate: CLLocationCoordinate2D(latitude: 43.633099, longitude: -79.394402),
            radius: 5556,
            color: .yellow,
            label: "E: CPZ9",
            textDeltaX: 0,
            textDeltaY: 0
        ),
        CircleOverlay(
            coordinate: CLLocationCoordinate2D(latitude: 43.6275, longitude: -79.3961111),
            radius: 5556,
            color: .red,
            label: "C: CYTZ-YTZ",
            textDeltaX: 0,
            textDeltaY: 0
        )
    ]

    @State private var polygons = [
        PolygonOverlay(
            coordinates: [
                CLLocationCoordinate2D(latitude: 43.54482, longitude: -79.38163),
                CLLocationCoordinate2D(latitude: 43.60815, longitude: -79.50105),
                CLLocationCoordinate2D(latitude: 43.60815, longitude: -79.50105),
                CLLocationCoordinate2D(latitude: 43.62296, longitude: -79.48799),
                CLLocationCoordinate2D(latitude: 43.63908, longitude: -79.47831),
                CLLocationCoordinate2D(latitude: 43.65608, longitude: -79.47209),
                CLLocationCoordinate2D(latitude: 43.67355, longitude: -79.46948),
                CLLocationCoordinate2D(latitude: 43.69108, longitude: -79.47098),
                CLLocationCoordinate2D(latitude: 43.70675, longitude: -79.39830),
                CLLocationCoordinate2D(latitude: 43.72510, longitude: -79.40217),
                CLLocationCoordinate2D(latitude: 43.74397, longitude: -79.31054),
                CLLocationCoordinate2D(latitude: 43.67114, longitude: -79.28000),
                CLLocationCoordinate2D(latitude: 43.62569, longitude: -79.28140),
                CLLocationCoordinate2D(latitude: 43.62569, longitude: -79.28140),
                CLLocationCoordinate2D(latitude: 43.61260, longitude: -79.28296),
                CLLocationCoordinate2D(latitude: 43.59988, longitude: -79.28762),
                CLLocationCoordinate2D(latitude: 43.58786, longitude: -79.29499),
                CLLocationCoordinate2D(latitude: 43.57683, longitude: -79.30488),
                CLLocationCoordinate2D(latitude: 43.56706, longitude: -79.31704),
                CLLocationCoordinate2D(latitude: 43.55880, longitude: -79.33117),
                CLLocationCoordinate2D(latitude: 43.55225, longitude: -79.34691),
                CLLocationCoordinate2D(latitude: 43.54758, longitude: -79.36388),
                CLLocationCoordinate2D(latitude: 43.54482, longitude: -79.38163)
            ],
            color: .red,
            label: "",
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
        mapView.pointOfInterestFilter = .excludingAll


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
                renderer.lineWidth = 0.5
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

                annotationView?.frame = CGRect(x: 0, y: 0, width: 250, height: 20)
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
