import 'dart:io';
import 'package:image/image.dart' as Im;

import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_editor/editing_page.dart';

class AddPhotos extends StatefulWidget {
  @override
  _AddPhotosState createState() => _AddPhotosState();
}

class _AddPhotosState extends State<AddPhotos> {
  GlobalKey<ScaffoldState> _scaffoldKey=GlobalKey<ScaffoldState>();
  bool isLoading=false;
  List<File> images;


  Future getImageFromGallery() async {
    List<File> files = await FilePicker.getMultiFile(type: FileType.image);
    if(files!=null){

      print('Lentgh of selected files :'+ files.length.toString());

      if(files.length>5){
        files.removeRange(5, files.length);
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("You can choose maximum 5 images. Others are ignored.")));

      }
      if(files!=null){
        print('Lentgh of selected files :'+ files.length.toString());
      }

    }


    if(files!=null){
      files=await compressImage(files);
      setState(()  {
        images=files;
      });
    }

  }

  Future uploadPictures() async {



      for(int i=0; i<images.length; i++){
        if(images!=null){
          setState(() {
            isLoading=true;
          });
        String fileName=basename(images[i].path);
        print("file path $i : $fileName");
        StorageReference ref =FirebaseStorage.instance.ref().child('Images').child(fileName);
        print('ref : '+ref.toString());
        StorageUploadTask uploadTask = ref.putFile(images[i]);
        StorageTaskSnapshot snap=await uploadTask.onComplete;
        print('snapshot '+snap.toString());
        String downloadURL = await snap.ref.getDownloadURL();
        print('url image :'+downloadURL.toString());
        Map<String, dynamic> data={
          'name':fileName,
          'url':downloadURL,
        };
        Firestore.instance.collection('Gallery').document()
            .setData(data)
            .then((res){
              print('response :');
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Images uploaded successfully.")));
          setState(() {
            isLoading=false;
          });

        }).catchError((err){
          setState(() {
            isLoading=false;
          });

          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(err.toString())));

        });


      }

    }
  }




  Future compressImage(List<File> imageFiles) async {
    print('Compression Starts');
    List<File> compressedImages;

    compressedImages=imageFiles;
    for(int i=0;i<imageFiles.length;i++){
      int quality=90;
      print('$i before comp : '+imageFiles[i].lengthSync().toString());
      int before=int.parse(imageFiles[i].lengthSync().toString());
      assert(before is int);
      print(before);
      if(before>280000){
        quality=((240000/before)*100).toInt();
        print(quality);
      }
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;
      int rand = new Math.Random().nextInt(10000);
      Im.Image image = Im.decodeImage(imageFiles[i].readAsBytesSync());
      compressedImages[i] = new File('$path/img_$rand.jpg')..writeAsBytesSync(Im.encodeJpg(image, quality: quality));
      print('$i after comp : '+compressedImages[i].lengthSync().toString());

    }
    print('Compression Ends');
    return compressedImages;
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff22264C),
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          centerTitle: true,
          title: Text("Add Photos"),
          actions: <Widget>[
            (images!=null)?InkWell(
              onTap: uploadPictures,
              child: Padding(
                padding: const EdgeInsets.only(right:20.0),
                child: Icon(Icons.cloud_upload, size: 32,),
              ),
            ):Text(""),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.black54,
          onPressed: getImageFromGallery,
          label: Text("Add", style: TextStyle(fontSize: 18),),
          icon: Icon(Icons.add,size: 30,),
        ),
        body: images == null
            ? Center(child: Text('No images selected.', style: TextStyle(color: Colors.white, fontSize: 18),))
            : GridView.builder(
          itemCount: images.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index){

            return InkWell(
              onTap: ()async {
                var resultEdit=await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditingPage(images[index])));
                if(resultEdit!=null){
                  setState(() {
                    images[index]=resultEdit;
                  });
                }
              },
              child:isLoading?Center(child: CircularProgressIndicator()): Card(
                elevation: 2,
                child: Image.file(images[index]),

              ),
            );
          },
        )

    );
  }
}

