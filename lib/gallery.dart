import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_editor/addphoto_page.dart';


class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff22264C),
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text("Gallery"),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff22264C),
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddPhotos()));
          },
          child: Icon(Icons.add,size: 35,),

        ),
        body:StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('Gallery').snapshots(),
            builder:(context, snapshot){
              if(snapshot.hasData){
                QuerySnapshot snap=snapshot.data;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2 ,
                    childAspectRatio:1.0 ,
                  ),
                  itemCount: snap.documents.length,
                  itemBuilder: (BuildContext context, int index){
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      elevation: 2.0,
                      margin: EdgeInsets.all(3.0),
                      child: CachedNetworkImage(
                        placeholder: (context,name)=>Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, error, object) {
                          return Container(
                            child: Center(child: CircularProgressIndicator()),
                            width: 50.0,
                            height: 50.0,
                            padding: EdgeInsets.all(15.0),
                          );
                        },
                        imageUrl:snap.documents[index]['url'],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              }else{
                return Center(child: CircularProgressIndicator());
              }
            }
        )
    );
  }
}
