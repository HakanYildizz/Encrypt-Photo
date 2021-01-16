//paketler
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Images;
import 'dart:math';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
      ),
      home: MyHomePage(baslik: 'Fotoğraf Şifreleme Uygulaması'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.baslik}) : super(key: key);
  final String baslik;
  static String path;
  @override
  _MyHomePageState createState() => _MyHomePageState();

  Future<List<int>> sifrele(var key) async {
    var imageData = await File(path).readAsBytes();
    List<int> bytes = Uint8List.view(imageData.buffer);
    var avatar = Images.decodeImage(bytes);

    List<int> xrlist = List<int>(); //xor listesi
    int xor = 0, piksel = 0;
    for (int y = 0; y <= avatar.height; y++) {
      for (int x = 0; x <= avatar.width; x++) {
        piksel = avatar.getPixelSafe(x, y); //sırasıyla pikseller çekiliyor.
        xor = piksel.hashCode ^ key.hashCode; //pikseller xor'lanıyor

        xrlist.add(xor); //xr listesine xor'lanmıs degerler atılıyor
      }
    }

    //FRAKTAL
    int m = avatar.width;
    int n = avatar.length;
    int sayi = 0;
    int ortadakisayi = (sqrt(n * m) - 1).toInt(); //
    int adimsiniri = ortadakisayi * 2 + 1, Y, X;
    bool ortanokta = true;

    for (int Z = 0; Z < adimsiniri; Z++) {
      int adimmodu = Z % ortadakisayi;
      if (ortanokta) {
        if (Z % 2 == 0) {
          X = m - 1;
          Y = Z;
          for (int i = 0; i < Z + 1; i++) {
            sayi++;
            avatar.setPixelSafe(
                X,
                Y,
                xrlist[i]); //xr listesindeki elemanları sırası ile renk byte'ı olarak setPixel yapıyor.
            X--;
            Y--;
          }
        } else {
          X = m - 1 - Z;
          Y = 0;

          for (int i = 0; i < Z + 1; i++) {
            sayi++;
            avatar.setPixelSafe(X, Y, xrlist[i]);
            X++;
            Y++;
          }
        }
        if (Z == ortadakisayi) {
          ortanokta = false;
        }
      } else {
        if (adimmodu % 2 == 0) {
          if (sayi == n * m - 1) {
            X = 0;
            Y = n - 1;
            adimmodu = ortadakisayi;
          } else {
            X = 0;
            Y = adimmodu;
          }
          for (int i = 0; i < (ortadakisayi - adimmodu + 1); i++) {
            avatar.setPixelSafe(X, Y, xrlist[i]);
            sayi++;
            X++;
            Y++;
          }
        } else {
          if (sayi == n * m - 1) {
            X = 0;
            Y = n - 1;
            adimmodu = ortadakisayi;
          } else {
            X = m - adimmodu;
            Y = n - 1;
          }
          for (int i = 0; i < (ortadakisayi - adimmodu + 1); i++) {
            avatar.setPixelSafe(X, Y, xrlist[i]);
            sayi++;
            X--;
            Y--;
          }
        }
      }
    }
    return Images.encodeJpg(avatar);
  }

  //Şifre Çözümü
  Future<List<int>> sifre() async {
    var imageData = await File(path).readAsBytes();
    List<int> bytes = Uint8List.view(imageData.buffer);
    var decImage = Images.decodeImage(bytes);
    return Images.encodeJpg(decImage);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int control = 0;

  Future openGallery() async {
    final picker = ImagePicker();
    final image = await picker.getImage(source: ImageSource.gallery);
    MyHomePage.path = image.path;
    _image = await image.readAsBytes();
    control = 1;
    setState(() {
      _image = _image;
    });
  }

  List<int> _image;
  var key = 'dd121e36961a04627eacff629765dd3528471ed745c1e32222db4a8a5f3421c4';
  //şifreleme için kullanılacak key

  void sifrele() {
    widget.sifrele(key).then((List<int> image) {
      setState(() {
        control = 2;
        _image = image;
        print("Tek Boyutlu Dizi: " + image.toString());
      });
    });
  }

  void sifreCoz() {
    widget.sifre().then((List<int> image) {
      setState(() {
        _image = image;
        control = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image == null
                    ? Text("Ekranda görüntü yoksa 'Galeriden fotoğraf seç'e tıklayın",
                    style: TextStyle(height: 2, fontSize: 15))
                    : Image.memory(
                  _image,
                  width: 450,
                  height: 450,
                  fit: BoxFit.contain,
                ),

                RaisedButton(
                  //Foto seçme butonu
                  child: Text(
                    'Galeriden fotoğraf seç',
                    style: TextStyle(fontSize: 15),
                  ),
                  textColor: Colors.blueAccent,
                  onPressed: openGallery,
                ),

                RaisedButton(
                  //encrypt butonu
                  child: Text(
                    'Şifrele',
                    style: TextStyle(fontSize: 15),
                  ),
                  textColor: Colors.blueAccent,
                  onPressed: control == 1 ? sifrele : null,
                ),

                RaisedButton(
                  //decrypt butonu
                  child: Text(
                    'Şifreyi Çöz',
                    style: TextStyle(fontSize: 15),
                  ),
                  textColor: Colors.blueAccent,
                  onPressed: control == 2 ? sifreCoz : null,
                ),
              ],
            ),
          )),
    );
  }
}
