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
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.811571, longitude: -79.062912), radius: 1852, color: .blue, label: "F: CYR Nuclear Plant"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.75972, longitude: -79.87389), radius: 5556, color: .red, label: "C: CNC3"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.836111, longitude: -79.017222), radius: 1852, color: .red, label: "C: CPE2"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.9255, longitude: -78.8968), radius: 5556, color: .orange, label: "D: CYOO-YOO"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.9255, longitude: -78.8968), radius: 9260, color: .orange, label: "D: CYOO-YOO"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.88510, longitude: -79.23059), radius: 1852, color: .red, label: "C: CPH7"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.85216, longitude: -79.69482), radius: 1852, color: .red, label: "C: CNB2"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 43.917, longitude: -79.555616667), radius: 1852, color: .yellow, label: "E: CKC3"),
        CircleOverlay(coordinate: CLLocationCoordinate2D(latitude: 44.129167, longitude: -78.941944), radius: 5556, color: .yellow, label: "E: CSV6")
        
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
        ),
        PolygonOverlay(
            coordinates: [
                CLLocationCoordinate2D(latitude: 43.87788, longitude: -79.59869),
                CLLocationCoordinate2D(latitude: 43.87788, longitude: -79.59875),
                CLLocationCoordinate2D(latitude: 43.89373, longitude: -79.61151),
                CLLocationCoordinate2D(latitude: 43.89492, longitude: -79.61267),
                CLLocationCoordinate2D(latitude: 43.89594, longitude: -79.61410),
                CLLocationCoordinate2D(latitude: 43.89677, longitude: -79.61575),
                CLLocationCoordinate2D(latitude: 43.89738, longitude: -79.61758),
                CLLocationCoordinate2D(latitude: 43.89775, longitude: -79.61953),
                CLLocationCoordinate2D(latitude: 43.89787, longitude: -79.62154),
                CLLocationCoordinate2D(latitude: 43.89774, longitude: -79.62355),
                CLLocationCoordinate2D(latitude: 43.89736, longitude: -79.62549),
                CLLocationCoordinate2D(latitude: 43.89674, longitude: -79.62731),
                CLLocationCoordinate2D(latitude: 43.89590, longitude: -79.62896),
                CLLocationCoordinate2D(latitude: 43.89487, longitude: -79.63038),
                CLLocationCoordinate2D(latitude: 43.89368, longitude: -79.63153),
                CLLocationCoordinate2D(latitude: 43.89236, longitude: -79.63238),
                CLLocationCoordinate2D(latitude: 43.89096, longitude: -79.63290),
                CLLocationCoordinate2D(latitude: 43.88951, longitude: -79.63307),
                CLLocationCoordinate2D(latitude: 43.88806, longitude: -79.63289),
                CLLocationCoordinate2D(latitude: 43.88666, longitude: -79.63236),
                CLLocationCoordinate2D(latitude: 43.88535, longitude: -79.63150),
                CLLocationCoordinate2D(latitude: 43.86949, longitude: -79.61873),
                CLLocationCoordinate2D(latitude: 43.86690, longitude: -79.62040),
                CLLocationCoordinate2D(latitude: 43.86410, longitude: -79.62144),
                CLLocationCoordinate2D(latitude: 43.86121, longitude: -79.62179),
                CLLocationCoordinate2D(latitude: 43.85832, longitude: -79.62144),
                CLLocationCoordinate2D(latitude: 43.85552, longitude: -79.62040),
                CLLocationCoordinate2D(latitude: 43.85289, longitude: -79.61870),
                CLLocationCoordinate2D(latitude: 43.85051, longitude: -79.61639),
                CLLocationCoordinate2D(latitude: 43.84846, longitude: -79.61354),
                CLLocationCoordinate2D(latitude: 43.84680, longitude: -79.61024),
                CLLocationCoordinate2D(latitude: 43.84557, longitude: -79.60659),
                CLLocationCoordinate2D(latitude: 43.84482, longitude: -79.60270),
                CLLocationCoordinate2D(latitude: 43.84457, longitude: -79.59869),
                CLLocationCoordinate2D(latitude: 43.84457, longitude: -79.59865),
                CLLocationCoordinate2D(latitude: 43.82871, longitude: -79.58588),
                CLLocationCoordinate2D(latitude: 43.82752, longitude: -79.58472),
                CLLocationCoordinate2D(latitude: 43.82650, longitude: -79.58329),
                CLLocationCoordinate2D(latitude: 43.82567, longitude: -79.58164),
                CLLocationCoordinate2D(latitude: 43.82506, longitude: -79.57981),
                CLLocationCoordinate2D(latitude: 43.82469, longitude: -79.57787),
                CLLocationCoordinate2D(latitude: 43.82457, longitude: -79.57587),
                CLLocationCoordinate2D(latitude: 43.82470, longitude: -79.57387),
                CLLocationCoordinate2D(latitude: 43.82508, longitude: -79.57193),
                CLLocationCoordinate2D(latitude: 43.82570, longitude: -79.57011),
                CLLocationCoordinate2D(latitude: 43.82654, longitude: -79.56846),
                CLLocationCoordinate2D(latitude: 43.82757, longitude: -79.56704),
                CLLocationCoordinate2D(latitude: 43.82876, longitude: -79.56589),
                CLLocationCoordinate2D(latitude: 43.83008, longitude: -79.56504),
                CLLocationCoordinate2D(latitude: 43.83148, longitude: -79.56452),
                CLLocationCoordinate2D(latitude: 43.83293, longitude: -79.56435),
                CLLocationCoordinate2D(latitude: 43.83438, longitude: -79.56453),
                CLLocationCoordinate2D(latitude: 43.83578, longitude: -79.56506),
                CLLocationCoordinate2D(latitude: 43.83709, longitude: -79.56591),
                CLLocationCoordinate2D(latitude: 43.85294, longitude: -79.57867),
                CLLocationCoordinate2D(latitude: 43.85554, longitude: -79.57699),
                CLLocationCoordinate2D(latitude: 43.85834, longitude: -79.57595),
                CLLocationCoordinate2D(latitude: 43.86123, longitude: -79.57560),
                CLLocationCoordinate2D(latitude: 43.86412, longitude: -79.57595),
                CLLocationCoordinate2D(latitude: 43.86692, longitude: -79.57699),
                CLLocationCoordinate2D(latitude: 43.86955, longitude: -79.57869),
                CLLocationCoordinate2D(latitude: 43.87193, longitude: -79.58100),
                CLLocationCoordinate2D(latitude: 43.87398, longitude: -79.58385),
                CLLocationCoordinate2D(latitude: 43.87565, longitude: -79.58715),
                CLLocationCoordinate2D(latitude: 43.87688, longitude: -79.59080),
                CLLocationCoordinate2D(latitude: 43.87763, longitude: -79.59469),
                CLLocationCoordinate2D(latitude: 43.87788, longitude: -79.59870)
            ],
            color: .yellow,
            label: "E: CTV4"
        ),
        PolygonOverlay(
            coordinates: [
                CLLocationCoordinate2D(latitude: 43.92318, longitude: -79.05115),
                CLLocationCoordinate2D(latitude: 43.92243, longitude: -79.05504),
                CLLocationCoordinate2D(latitude: 43.92120, longitude: -79.05869),
                CLLocationCoordinate2D(latitude: 43.92014, longitude: -79.06079),
                CLLocationCoordinate2D(latitude: 43.92820, longitude: -79.08646),
                CLLocationCoordinate2D(latitude: 43.92866, longitude: -79.08837),
                CLLocationCoordinate2D(latitude: 43.92888, longitude: -79.09036),
                CLLocationCoordinate2D(latitude: 43.92884, longitude: -79.09237),
                CLLocationCoordinate2D(latitude: 43.92855, longitude: -79.09435),
                CLLocationCoordinate2D(latitude: 43.92802, longitude: -79.09623),
                CLLocationCoordinate2D(latitude: 43.92726, longitude: -79.09795),
                CLLocationCoordinate2D(latitude: 43.92630, longitude: -79.09946),
                CLLocationCoordinate2D(latitude: 43.92516, longitude: -79.10072),
                CLLocationCoordinate2D(latitude: 43.92388, longitude: -79.10168),
                CLLocationCoordinate2D(latitude: 43.92250, longitude: -79.10232),
                CLLocationCoordinate2D(latitude: 43.92106, longitude: -79.10262),
                CLLocationCoordinate2D(latitude: 43.91961, longitude: -79.10257),
                CLLocationCoordinate2D(latitude: 43.91819, longitude: -79.10217),
                CLLocationCoordinate2D(latitude: 43.91684, longitude: -79.10143),
                CLLocationCoordinate2D(latitude: 43.91560, longitude: -79.10038),
                CLLocationCoordinate2D(latitude: 43.91451, longitude: -79.09905),
                CLLocationCoordinate2D(latitude: 43.91361, longitude: -79.09747),
                CLLocationCoordinate2D(latitude: 43.91292, longitude: -79.09570),
                CLLocationCoordinate2D(latitude: 43.90485, longitude: -79.07001),
                CLLocationCoordinate2D(latitude: 43.90387, longitude: -79.06989),
                CLLocationCoordinate2D(latitude: 43.90107, longitude: -79.06885),
                CLLocationCoordinate2D(latitude: 43.89844, longitude: -79.06715),
                CLLocationCoordinate2D(latitude: 43.89833, longitude: -79.06704),
                CLLocationCoordinate2D(latitude: 43.88035, longitude: -79.08118),
                CLLocationCoordinate2D(latitude: 43.87903, longitude: -79.08202),
                CLLocationCoordinate2D(latitude: 43.87762, longitude: -79.08253),
                CLLocationCoordinate2D(latitude: 43.87617, longitude: -79.08269),
                CLLocationCoordinate2D(latitude: 43.87472, longitude: -79.08250),
                CLLocationCoordinate2D(latitude: 43.87332, longitude: -79.08196),
                CLLocationCoordinate2D(latitude: 43.87201, longitude: -79.08109),
                CLLocationCoordinate2D(latitude: 43.87083, longitude: -79.07992),
                CLLocationCoordinate2D(latitude: 43.86981, longitude: -79.07848),
                CLLocationCoordinate2D(latitude: 43.86899, longitude: -79.07682),
                CLLocationCoordinate2D(latitude: 43.86839, longitude: -79.07499),
                CLLocationCoordinate2D(latitude: 43.86803, longitude: -79.07304),
                CLLocationCoordinate2D(latitude: 43.86791, longitude: -79.07103),
                CLLocationCoordinate2D(latitude: 43.86805, longitude: -79.06903),
                CLLocationCoordinate2D(latitude: 43.86844, longitude: -79.06709),
                CLLocationCoordinate2D(latitude: 43.86906, longitude: -79.06527),
                CLLocationCoordinate2D(latitude: 43.86990, longitude: -79.06363),
                CLLocationCoordinate2D(latitude: 43.87093, longitude: -79.06222),
                CLLocationCoordinate2D(latitude: 43.87213, longitude: -79.06108),
                CLLocationCoordinate2D(latitude: 43.89012, longitude: -79.04692),
                CLLocationCoordinate2D(latitude: 43.89036, longitude: -79.04311),
                CLLocationCoordinate2D(latitude: 43.89111, longitude: -79.03922),
                CLLocationCoordinate2D(latitude: 43.89234, longitude: -79.03557),
                CLLocationCoordinate2D(latitude: 43.89339, longitude: -79.03349),
                CLLocationCoordinate2D(latitude: 43.88533, longitude: -79.00781),
                CLLocationCoordinate2D(latitude: 43.88487, longitude: -79.00590),
                CLLocationCoordinate2D(latitude: 43.88465, longitude: -79.00391),
                CLLocationCoordinate2D(latitude: 43.88469, longitude: -79.00190),
                CLLocationCoordinate2D(latitude: 43.88498, longitude: -78.99993),
                CLLocationCoordinate2D(latitude: 43.88551, longitude: -78.99806),
                CLLocationCoordinate2D(latitude: 43.88627, longitude: -78.99634),
                CLLocationCoordinate2D(latitude: 43.88723, longitude: -78.99483),
                CLLocationCoordinate2D(latitude: 43.88837, longitude: -78.99357),
                CLLocationCoordinate2D(latitude: 43.88965, longitude: -78.99261),
                CLLocationCoordinate2D(latitude: 43.89103, longitude: -78.99197),
                CLLocationCoordinate2D(latitude: 43.89247, longitude: -78.99167),
                CLLocationCoordinate2D(latitude: 43.89392, longitude: -78.99172),
                CLLocationCoordinate2D(latitude: 43.89534, longitude: -78.99212),
                CLLocationCoordinate2D(latitude: 43.89669, longitude: -78.99286),
                CLLocationCoordinate2D(latitude: 43.89793, longitude: -78.99391),
                CLLocationCoordinate2D(latitude: 43.89902, longitude: -78.99524),
                CLLocationCoordinate2D(latitude: 43.89992, longitude: -78.99682),
                CLLocationCoordinate2D(latitude: 43.90061, longitude: -78.99859),
                CLLocationCoordinate2D(latitude: 43.90867, longitude: -79.02425),
                CLLocationCoordinate2D(latitude: 43.90967, longitude: -79.02437),
                CLLocationCoordinate2D(latitude: 43.91247, longitude: -79.02541),
                CLLocationCoordinate2D(latitude: 43.91510, longitude: -79.02711),
                CLLocationCoordinate2D(latitude: 43.91520, longitude: -79.02720),
                CLLocationCoordinate2D(latitude: 43.93319, longitude: -79.01304),
                CLLocationCoordinate2D(latitude: 43.93451, longitude: -79.01220),
                CLLocationCoordinate2D(latitude: 43.93592, longitude: -79.01169),
                CLLocationCoordinate2D(latitude: 43.93737, longitude: -79.01153),
                CLLocationCoordinate2D(latitude: 43.93882, longitude: -79.01172),
                CLLocationCoordinate2D(latitude: 43.94022, longitude: -79.01226),
                CLLocationCoordinate2D(latitude: 43.94153, longitude: -79.01313),
                CLLocationCoordinate2D(latitude: 43.94271, longitude: -79.01430),
                CLLocationCoordinate2D(latitude: 43.94373, longitude: -79.01574),
                CLLocationCoordinate2D(latitude: 43.94455, longitude: -79.01740),
                CLLocationCoordinate2D(latitude: 43.94515, longitude: -79.01923),
                CLLocationCoordinate2D(latitude: 43.94551, longitude: -79.02118),
                CLLocationCoordinate2D(latitude: 43.94563, longitude: -79.02319),
                CLLocationCoordinate2D(latitude: 43.94549, longitude: -79.02520),
                CLLocationCoordinate2D(latitude: 43.94510, longitude: -79.02714),
                CLLocationCoordinate2D(latitude: 43.94448, longitude: -79.02896),
                CLLocationCoordinate2D(latitude: 43.94364, longitude: -79.03060),
                CLLocationCoordinate2D(latitude: 43.94261, longitude: -79.03201),
                CLLocationCoordinate2D(latitude: 43.94141, longitude: -79.03315),
                CLLocationCoordinate2D(latitude: 43.92343, longitude: -79.04730),
                CLLocationCoordinate2D(latitude: 43.92319, longitude: -79.05114)
            ],
            color: .yellow,
            label: "E: CAJ5"
        ),
        PolygonOverlay(
            coordinates: [
                CLLocationCoordinate2D(latitude: 43.95051, longitude: -79.21788),
                CLLocationCoordinate2D(latitude: 43.93748, longitude: -79.31096),
                CLLocationCoordinate2D(latitude: 43.93708, longitude: -79.31290),
                CLLocationCoordinate2D(latitude: 43.93644, longitude: -79.31471),
                CLLocationCoordinate2D(latitude: 43.93559, longitude: -79.31634),
                CLLocationCoordinate2D(latitude: 43.93455, longitude: -79.31774),
                CLLocationCoordinate2D(latitude: 43.93335, longitude: -79.31887),
                CLLocationCoordinate2D(latitude: 43.93202, longitude: -79.31969),
                CLLocationCoordinate2D(latitude: 43.93061, longitude: -79.32018),
                CLLocationCoordinate2D(latitude: 43.92916, longitude: -79.32032),
                CLLocationCoordinate2D(latitude: 43.92772, longitude: -79.32011),
                CLLocationCoordinate2D(latitude: 43.92632, longitude: -79.31955),
                CLLocationCoordinate2D(latitude: 43.92502, longitude: -79.31867),
                CLLocationCoordinate2D(latitude: 43.92385, longitude: -79.31749),
                CLLocationCoordinate2D(latitude: 43.92284, longitude: -79.31604),
                CLLocationCoordinate2D(latitude: 43.92203, longitude: -79.31437),
                CLLocationCoordinate2D(latitude: 43.92144, longitude: -79.31253),
                CLLocationCoordinate2D(latitude: 43.92109, longitude: -79.31057),
                CLLocationCoordinate2D(latitude: 43.92099, longitude: -79.30856),
                CLLocationCoordinate2D(latitude: 43.92114, longitude: -79.30656),
                CLLocationCoordinate2D(latitude: 43.93417, longitude: -79.21348),
                CLLocationCoordinate2D(latitude: 43.93457, longitude: -79.21154),
                CLLocationCoordinate2D(latitude: 43.93521, longitude: -79.20973),
                CLLocationCoordinate2D(latitude: 43.93606, longitude: -79.20810),
                CLLocationCoordinate2D(latitude: 43.93710, longitude: -79.20670),
                CLLocationCoordinate2D(latitude: 43.93830, longitude: -79.20557),
                CLLocationCoordinate2D(latitude: 43.93963, longitude: -79.20475),
                CLLocationCoordinate2D(latitude: 43.94104, longitude: -79.20426),
                CLLocationCoordinate2D(latitude: 43.94249, longitude: -79.20412),
                CLLocationCoordinate2D(latitude: 43.94393, longitude: -79.20433),
                CLLocationCoordinate2D(latitude: 43.94533, longitude: -79.20489),
                CLLocationCoordinate2D(latitude: 43.94663, longitude: -79.20577),
                CLLocationCoordinate2D(latitude: 43.94780, longitude: -79.20695),
                CLLocationCoordinate2D(latitude: 43.94881, longitude: -79.20840),
                CLLocationCoordinate2D(latitude: 43.94962, longitude: -79.21007),
                CLLocationCoordinate2D(latitude: 43.95021, longitude: -79.21191),
                CLLocationCoordinate2D(latitude: 43.95056, longitude: -79.21387),
                CLLocationCoordinate2D(latitude: 43.95066, longitude: -79.21588),
                CLLocationCoordinate2D(latitude: 43.95051, longitude: -79.21789)
            ],
            color: .yellow,
            label: "E: CNU8"
        ),
        PolygonOverlay(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 44.01440, longitude: -79.22764),
                    CLLocationCoordinate2D(latitude: 43.98731, longitude: -79.31556),
                    CLLocationCoordinate2D(latitude: 43.98662, longitude: -79.31734),
                    CLLocationCoordinate2D(latitude: 43.98572, longitude: -79.31893),
                    CLLocationCoordinate2D(latitude: 43.98464, longitude: -79.32028),
                    CLLocationCoordinate2D(latitude: 43.98341, longitude: -79.32134),
                    CLLocationCoordinate2D(latitude: 43.98206, longitude: -79.32209),
                    CLLocationCoordinate2D(latitude: 43.98064, longitude: -79.32250),
                    CLLocationCoordinate2D(latitude: 43.97919, longitude: -79.32256),
                    CLLocationCoordinate2D(latitude: 43.97775, longitude: -79.32227),
                    CLLocationCoordinate2D(latitude: 43.97637, longitude: -79.32164),
                    CLLocationCoordinate2D(latitude: 43.97509, longitude: -79.32069),
                    CLLocationCoordinate2D(latitude: 43.97395, longitude: -79.31944),
                    CLLocationCoordinate2D(latitude: 43.97298, longitude: -79.31794),
                    CLLocationCoordinate2D(latitude: 43.97221, longitude: -79.31623),
                    CLLocationCoordinate2D(latitude: 43.97167, longitude: -79.31436),
                    CLLocationCoordinate2D(latitude: 43.97137, longitude: -79.31239),
                    CLLocationCoordinate2D(latitude: 43.97132, longitude: -79.31037),
                    CLLocationCoordinate2D(latitude: 43.97153, longitude: -79.30837),
                    CLLocationCoordinate2D(latitude: 43.97198, longitude: -79.30645),
                    CLLocationCoordinate2D(latitude: 43.99907, longitude: -79.21853),
                    CLLocationCoordinate2D(latitude: 43.99976, longitude: -79.21675),
                    CLLocationCoordinate2D(latitude: 44.00066, longitude: -79.21516),
                    CLLocationCoordinate2D(latitude: 44.00174, longitude: -79.21381),
                    CLLocationCoordinate2D(latitude: 44.00297, longitude: -79.21275),
                    CLLocationCoordinate2D(latitude: 44.00432, longitude: -79.21200),
                    CLLocationCoordinate2D(latitude: 44.00574, longitude: -79.21159),
                    CLLocationCoordinate2D(latitude: 44.00719, longitude: -79.21153),
                    CLLocationCoordinate2D(latitude: 44.00863, longitude: -79.21182),
                    CLLocationCoordinate2D(latitude: 44.01001, longitude: -79.21245),
                    CLLocationCoordinate2D(latitude: 44.01129, longitude: -79.21340),
                    CLLocationCoordinate2D(latitude: 44.01243, longitude: -79.21465),
                    CLLocationCoordinate2D(latitude: 44.01340, longitude: -79.21615),
                    CLLocationCoordinate2D(latitude: 44.01417, longitude: -79.21787),
                    CLLocationCoordinate2D(latitude: 44.01471, longitude: -79.21974),
                    CLLocationCoordinate2D(latitude: 44.01501, longitude: -79.22172),
                    CLLocationCoordinate2D(latitude: 44.01506, longitude: -79.22374),
                    CLLocationCoordinate2D(latitude: 44.01485, longitude: -79.22574),
                    CLLocationCoordinate2D(latitude: 44.01440, longitude: -79.22766),
                ],
                color: .yellow,
                label: "E: CBB2"
            ),
        
        PolygonOverlay(
                coordinates:[
                    CLLocationCoordinate2D(latitude: 43.9889, longitude: -79.6779),
                    CLLocationCoordinate2D(latitude: 43.9998, longitude: -79.7731),
                    CLLocationCoordinate2D(latitude: 43.9999, longitude: -79.7751),
                    CLLocationCoordinate2D(latitude: 43.9997, longitude: -79.7771),
                    CLLocationCoordinate2D(latitude: 43.9993, longitude: -79.7791),
                    CLLocationCoordinate2D(latitude: 43.9987, longitude: -79.7809),
                    CLLocationCoordinate2D(latitude: 43.9978, longitude: -79.7825),
                    CLLocationCoordinate2D(latitude: 43.9968, longitude: -79.7839),
                    CLLocationCoordinate2D(latitude: 43.9956, longitude: -79.785),
                    CLLocationCoordinate2D(latitude: 43.9943, longitude: -79.7858),
                    CLLocationCoordinate2D(latitude: 43.9929, longitude: -79.7863),
                    CLLocationCoordinate2D(latitude: 43.9914, longitude: -79.7865),
                    CLLocationCoordinate2D(latitude: 43.99, longitude: -79.7863),
                    CLLocationCoordinate2D(latitude: 43.9886, longitude: -79.7857),
                    CLLocationCoordinate2D(latitude: 43.9873, longitude: -79.7848),
                    CLLocationCoordinate2D(latitude: 43.9861, longitude: -79.7836),
                    CLLocationCoordinate2D(latitude: 43.9851, longitude: -79.7822),
                    CLLocationCoordinate2D(latitude: 43.9843, longitude: -79.7805),
                    CLLocationCoordinate2D(latitude: 43.9837, longitude: -79.7787),
                    CLLocationCoordinate2D(latitude: 43.9833, longitude: -79.7767),
                    CLLocationCoordinate2D(latitude: 43.9725, longitude: -79.6815),
                    CLLocationCoordinate2D(latitude: 43.9724, longitude: -79.6795),
                    CLLocationCoordinate2D(latitude: 43.9725, longitude: -79.6775),
                    CLLocationCoordinate2D(latitude: 43.9729, longitude: -79.6756),
                    CLLocationCoordinate2D(latitude: 43.9736, longitude: -79.6738),
                    CLLocationCoordinate2D(latitude: 43.9744, longitude: -79.6721),
                    CLLocationCoordinate2D(latitude: 43.9755, longitude: -79.6707),
                    CLLocationCoordinate2D(latitude: 43.9767, longitude: -79.6696),
                    CLLocationCoordinate2D(latitude: 43.978, longitude: -79.6688),
                    CLLocationCoordinate2D(latitude: 43.9794, longitude: -79.6683),
                    CLLocationCoordinate2D(latitude: 43.9809, longitude: -79.6681),
                    CLLocationCoordinate2D(latitude: 43.9823, longitude: -79.6684),
                    CLLocationCoordinate2D(latitude: 43.9837, longitude: -79.6689),
                    CLLocationCoordinate2D(latitude: 43.985, longitude: -79.6698),
                    CLLocationCoordinate2D(latitude: 43.9862, longitude: -79.671),
                    CLLocationCoordinate2D(latitude: 43.9872, longitude: -79.6724),
                    CLLocationCoordinate2D(latitude: 43.988, longitude: -79.6741),
                    CLLocationCoordinate2D(latitude: 43.9886, longitude: -79.6759),
                    CLLocationCoordinate2D(latitude: 43.9889, longitude: -79.6779),
                ],
                color: .yellow,
                label: "E: CSV8"
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
