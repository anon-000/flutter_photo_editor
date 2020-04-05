import 'dart:io';
import 'dart:async';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib ;
import 'package:path/path.dart';

class EditingPage extends StatefulWidget {
  File photo;
  EditingPage(this.photo);
  @override
  _EditingPageState createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  String fileName;
  List<Filter> filters = presetFiltersList;





  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: widget.photo.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Color(0xff22264C),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        )
    );
    if (croppedFile != null) {

      setState(() {
        widget.photo = croppedFile;
      });
    }
  }

  Future addFilter(context) async {
    if(widget.photo!=null){
      fileName = basename(widget.photo.path);
      var image = imageLib.decodeImage(widget.photo.readAsBytesSync());
      image = imageLib.copyResize(image, width: 600);
      Map imageFileTemp = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new PhotoFilterSelector(
            title: Text("Select Any Filter"),
            image: image,
            filters: presetFiltersList,
            filename: fileName,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      );
      if (imageFileTemp != null && imageFileTemp.containsKey('image_filtered')) {
        setState(() {
          widget.photo = imageFileTemp['image_filtered'];
        });
        print(widget.photo.path);
      }
    }else{
      print("No Images selected yet.");
    }

  }


  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Yes"),
      onPressed:  () {
        Navigator.pop(context, null);
        Navigator.pop(context, null);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue Editing"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      elevation: 5,
      backgroundColor:Color(0xff22264C),
      title: Text("Confirm", style: TextStyle(color: Colors.white),),
      content: Text("Do you really want to exit without saving the changes ?", style: TextStyle(color: Colors.white)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(title: Text("My Photo Editor"), centerTitle: true,backgroundColor: Colors.black,
        leading: BackButton(color: Colors.white,
          onPressed: (){
            showAlertDialog(context);
          },
        ),
        actions: <Widget>[
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right:18),
              child: Icon(Icons.done,size: 30,),
            ),
            onTap: (){
              Navigator.pop(context, widget.photo);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 550,
              color: Color(0xff22264C),
              child: Center(
                child: widget.photo == null
                    ? Text('No image selected.', style: TextStyle(color: Colors.white, fontSize: 18),)
                    : Image.file(widget.photo),
              ),
            ),
            SizedBox(height: 10,),
            Stack(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        color: Colors.teal,
                        child: Text("Camera", style: TextStyle(color: Colors.white)),
                        onPressed: (){} ,
                      ),
                      SizedBox(width: 90,),

                      RaisedButton(
                        color: Colors.teal,
                        child: Text("Gallery", style: TextStyle(color: Colors.white),),
                        onPressed: (){},
                      ),
                    ]),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [FloatingActionButton(
                      backgroundColor:  Color(0xff387F7F),
                      child: Icon(Icons.add_a_photo),
                      onPressed: (){},
                    )]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(width:50,height:70,
                        child: RaisedButton(
                          child: Icon(Icons.crop, color: Colors.white,),
                          onPressed: _cropImage ,
                          color: Color(0xff22264C),
                        )
                    ),
                    SizedBox(width:50,height:70,
                        child: RaisedButton(
                          child: Icon(Icons.menu, color: Colors.white,),
                          onPressed: () => addFilter(context) ,
                          color: Color(0xff22264C),
                        )
                    ),

                  ],)
              ],
            ),
            SizedBox(height: 18,)
          ],
        ),

      ),


    );
  }
}
