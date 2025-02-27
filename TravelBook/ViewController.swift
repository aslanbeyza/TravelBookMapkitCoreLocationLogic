//
//  ViewController.swift
//  TravelBook
//
//  Created by Beyza Aslan on 26.02.2025.
//
import UIKit
import MapKit //harita için
import CoreLocation //konumunu almak için
import CoreData  //modellerle işin varsa importu unutma kardesimm :D

// uygulama kapsamında kullanıcının lokasyonunu bulmam lazım geziyo görüyo orayı işaretlicek kaydetcek o yüzden bi onu öğrenmemiz lazım 2. si harita açıldığında çok zoom edilmemiş şeklinde açılıyo nasıl zoom yapılır vs onları ogrenemmız lazım
//kullancı konumunu alma mapkit ile olmuyo aslında  haritalarla kullanıcının konumunu almak arasında pek bir bağlantı yok
class ViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    //konum ile alakalı birşey yapıyorsanız bunu kullanmanız lazım diyo yani kullanıcının konumunu alıcaksan kullanıcının konumu ile ilgili işlemler yapıcaksam ve bunu kendi haritamda göstericeksem vs bunu kullanmam lazım
    var locationManager:CLLocationManager!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedTitleID:UUID?
    
    var annotationTitle = ""
    var annotationSubTitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //en çok pil yiyo sadece ama tam konumu bulamk için lazım
        locationManager.requestWhenInUseAuthorization() //app imi kullanırken
        locationManager.startUpdatingLocation() //kullanıcının yerini bununla alıyoruz
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3  //3 sn basarsa bunu algıla
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        if selectedTitle != "" {
            //Core datadan çekicez Fİltreleme sadece id si şu olanı çağır diyoruz
            //napıyoruz entity e kaydederken appdelegate ı cagırıyoruz
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id == %@",idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title  = result.value(forKey: "title") as? String{
                            annotationTitle = title
                        }
                        if let subTitle = result.value(forKey: "subTitle") as? String{
                            annotationSubTitle = subTitle
                            
                        }
                        if let latitude = result.value(forKey: "latitude") as? Double{
                             annotationLatitude = latitude
                        }
                        
                        if let longitude = result.value(forKey: "longitude") as? Double{
                            annotationLongitude = longitude
                            
                            
                            let annotation = MKPointAnnotation() //Bu bir pin oluşturur
                            annotation.title = annotationTitle
                            annotation.subtitle = annotationSubTitle
                         let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                            mapView.addAnnotation(annotation)
                            annotation.coordinate = coordinate
                            mapView.addAnnotation(annotation)
                            nameText.text = annotationTitle
                            commentText.text = annotationSubTitle
                            locationManager.stopUpdatingLocation() //kullanıcının yerini durdur
                            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            let region = MKCoordinateRegion(center: coordinate, span: span)
                            mapView.setRegion(region, animated: true)  //Bu kod Swift programlama dilinde MapKit framework’ü kullanılarak bir harita görüntüsünü belirli bir bölgeye (region) odaklamak için kullanılır.
                        }
                    }
                }
            } catch  {
                print("Hata: \(error)")
            }

            
            
        }
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        //adam uzun bastı basladı mesela ya da cancel dedi falan
        if gestureRecognizer.state == .began {
               //dokunulan noktaları alıcam
            let touchedPoint = gestureRecognizer.location(in: mapView)
//            convert nerden çevireyim ve nereye çevireyim noktayı koordidnat sistemne çevirecektir dokunulan koordinatları vericek
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = "💕 (\(nameText.text ?? "Bu noktadayıızzz"))"
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
    }
     //bu bana güncellenen loksayonları dizi içinde veriyor bana devamlı güncelleniyo ya ondan dizi içinde veriyor güncellendikçe lokasyonları alabiliyorum ilk lokasyonu alsak bize yeter BU locationManager FONKSİYONLA BELİRTİLEN ENLEM VE BOYLAMA ZOOM YAPCAK
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == "" {
            //CLLocation: bu içinde enlem ve boylam barındırıyor bi tane lokasyon oluşturucam bu oluşturduğum lokasyona zoomla dicem
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude:locations[0].coordinate.longitude)
            //zoom  seviyesi ayarlamamız lazım bide
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            //nereyi merkez alcak locaiton kısmını dedik zaten
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
        else
        {
            //
        }
    }
    //Pin özelleştirme i var ya o tıklandıgını anlarsak  yapcaz
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {  //kulanıcının yerini göstren anatasyon ben bunu istemiyorum
            return nil
        }
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true //bir baloncukla birlikte eksta bilgi gösterebildiğimiz yer
            pinView?.tintColor = UIColor.black  //pinler kırmızı çıkıyo ya  onu siyah da gösterebiliriz bu şekilde
            let button = UIButton(type: .detailDisclosure) //detay göstereceğim bir buton
            pinView?.rightCalloutAccessoryView = button //ssağ tarafında göster butonu
        }else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    // i var ya o tıklandıgını anlarsak  yapcaz onun içinde calloutAccessoryControlTapped fonsiyonu kullanılıyo
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
            var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            //koordinatlar ve yerler arasında bağlantı kurmamıza yarar CLGeocoder
            CLGeocoder().reverseGeocodeLocation(requestLocation) {(placemarks, error) in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item .name = self.annotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving ]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
            }
        }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        //napıyoruz entity e kaydederken appdelegate ı cagırıyoruz
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        //şimdi kullanıcının kaydetmek için koycağımız yere geldik yarabbi şükürr
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subTitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")

       //hepsini giridk simdi context.save yapcaz ama do try catch le alış buna kardeş
        do {
            try context.save()
            print("veritabanına kayıt başarılı")
        } catch  {
            print("veritabanına kayıt başarısız")
        }
        //save button da işlemlerim bittikten sonra bizi al Notification center kısmından bir mesaj yolla ondan sonrada bir önceki controller a geri getir  Mesela listeye bi konum ekledim  tablonun olduğu ilks sayfaya bakınca gelmiyo anında gelsin istiyorsan notification center kullanman gerekir
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)  //* Mevcut sayfayı geri kapatıp, önceki ekrana dönmesini sağlar.
    }
    }



