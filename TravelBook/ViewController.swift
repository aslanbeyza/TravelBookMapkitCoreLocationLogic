//
//  ViewController.swift
//  TravelBook
//
//  Created by Beyza Aslan on 26.02.2025.
//

import UIKit
import MapKit //harita için
import CoreLocation //konumunu almak için

// uygulama kapsamında kullanıcının lokasyonunu bulmam lazım geziyo görüyo orayı işaretlicek kaydetcek o yüzden bi onu öğrenmemiz lazım 2. si harita açıldığında çok zoom edilmemiş şeklinde açılıyo nasıl zoom yapılır vs onları ogrenemmız lazım
//kullancı konumunu alma mapkit ile olmuyo aslında  haritalarla kullanıcının konumunu almak arasında pek bir bağlantı yok
class ViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    //konum ile alakalı birşey yapıyorsanız bunu kullanmanız lazım diyo yani kullanıcının konumunu alıcaksan kullanıcının konumu ile ilgili işlemler yapıcaksam ve bunu kendi haritamda göstericeksem vs bunu kullanmam lazım
    var localtionManager:CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        localtionManager = CLLocationManager()
        localtionManager.delegate = self
        localtionManager.desiredAccuracy = kCLLocationAccuracyBest //en çok pil yiyo sadece ama tam konumu bulamk için lazım
        localtionManager.requestWhenInUseAuthorization() //app imi kullanırken
        localtionManager.startUpdatingLocation() //kullanıcının yerini bununla alıyoruz
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3  //3 sn basarsa bunu algıla
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        //adam uzun bastı basladı mesela ya da cancel dedi falan
        if gestureRecognizer.state == .began {
               //dokunulan noktaları alıcam
            let touchedPoint = gestureRecognizer.location(in: mapView)
//            convert nerden çevireyim ve nereye çevireyim noktayı koordidnat sistemne çevirecektir dokunulan koordinatları vericek
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = "Bu noktadayızz 💕"
            annotation.subtitle = "Travel Booking"
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
     //bu bana güncellenen loksayonları dizi içinde veriyor bana devamlı güncelleniyo ya ondan dizi içinde veriyor güncellendikçe lokasyonları alabiliyorum ilk lokasyonu alsak bize yeter BU locationManager FONKSİYONLA BELİRTİLEN ENLEM VE BOYLAMA ZOOM YAPCAK
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //CLLocation: bu içinde enlem ve boylam barındırıyor bi tane lokasyon oluşturucam bu oluşturduğum lokasyona zoomla dicem
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude:locations[0].coordinate.longitude)
        //zoom  seviyesi ayarlamamız lazım bide
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        //nereyi merkez alcak locaiton kısmını dedik zaten
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }

    
    
    
    
    
}

