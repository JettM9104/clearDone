import SwiftUI
import MapKit
import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}


// MARK: - UIColor extension for contrasting text color

extension UIColor {
    var isLight: Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return true
        }
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness > 0.6
    }

    var inverted: UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return .black
        }
        return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
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

// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    @State private var circles = [
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.6766666, longitude: -79.63), radius: 5556, color: .red, label: "C: CYYZ-YYZ"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.6766666, longitude: -79.63), radius: 12964, color: .red, label: "C: CYYZ-YYZ"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.65391, longitude: -79.65785), radius: 1852, color: .red, label: "C: CPA5"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.61778, longitude: -79.56397), radius: 1852, color: .red, label: "C: CPY5"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.56141, longitude: -79.70274), radius: 1852, color: .red, label: "C: CPK6"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.633099, longitude: -79.394402), radius: 5556, color: .yellow, label: "E: CPZ9"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.6275, longitude: -79.3961111), radius: 5556, color: .red, label: "C: CYTZ-YTZ"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.6568465, longitude: -79.3878803), radius: 1852, color: .red, label: "C: CNW8"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.65415, longitude: -79.37847), radius: 1852, color: .red, label: "C: CTM4"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.7213, longitude: -79.3707651), radius: 1852, color: .red, label: "C: CNY8"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.811571, longitude: -79.062912), radius: 1852, color: .orange, label: "F: CYR Nuclear Plant"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.75972, longitude: -79.87389), radius: 5556, color: .red, label: "C: CNC3"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.836111, longitude: -79.017222), radius: 1852, color: .red, label: "C: CPE2"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.9255, longitude: -78.8968), radius: 5556, color: .red, label: "C: CYOO-YOO"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.9255, longitude: -78.8968), radius: 9260, color: .red, label: "C: CYOO-YOO"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.88510, longitude: -79.23059), radius: 1852, color: .red, label: "C: CPH7"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.85216, longitude: -79.69482), radius: 1852, color: .red, label: "C: CNB2"),
        
    ]

    @State private var polygons = [
        PolygonOverlay(
            coordinates: [
                CLLocationCoordinate2D(latitude: 43.54482, longitude: -79.38163),
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
            label: ""
        )
    ]

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6766666, longitude: -79.63),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    var body: some View {
        ZStack {
            MapViewWrapper(circles: $circles, polygons: $polygons, region: $region)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: {
                            region.span.latitudeDelta /= 2
                            region.span.longitudeDelta /= 2
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.title)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }

                        Button(action: {
                            region.span.latitudeDelta *= 2
                            region.span.longitudeDelta *= 2
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                                .font(.title)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - MapViewWrapper

struct MapViewWrapper: UIViewRepresentable {
    @Binding var circles: [CircleOverlay]
    @Binding var polygons: [PolygonOverlay]
    @Binding var region: MKCoordinateRegion

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper

        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? ColoredCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = circle.color.withAlphaComponent(0.3)
                renderer.strokeColor = circle.color
                renderer.lineWidth = 1
                return renderer
            }

            if let polygon = overlay as? ColoredPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = polygon.color.withAlphaComponent(0.3)
                renderer.strokeColor = polygon.color
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

            let zoomFactor = CGFloat(mapView.region.span.latitudeDelta)
            let scale = max(1.0, 0.5 / zoomFactor)
            annotationView?.centerOffset = CGPoint(x: labelAnnotation.textDeltaX * scale, y: labelAnnotation.textDeltaY * scale)

            let zoomThreshold: CLLocationDegrees = 0.5
            annotationView?.alpha = mapView.region.span.latitudeDelta > zoomThreshold ? 0 : 1

            return annotationView
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        updateMapAnnotationsAndOverlays(mapView)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if mapView.region.center.latitude != region.center.latitude ||
            mapView.region.center.longitude != region.center.longitude ||
            mapView.region.span.latitudeDelta != region.span.latitudeDelta {
            UIView.animate(withDuration: 0.2) {
                mapView.setRegion(region, animated: true)
            }
        }

        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        updateMapAnnotationsAndOverlays(mapView)
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

    func centroid(of coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let lat = coordinates.reduce(0) { $0 + $1.latitude } / Double(coordinates.count)
        let lon = coordinates.reduce(0) { $0 + $1.longitude } / Double(coordinates.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
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
