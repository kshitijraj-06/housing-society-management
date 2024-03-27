import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Cards extends StatefulWidget{

  final String title;
  final String url;
  final Function () onTapp;


  Cards({
    Key? key,
    required this.title,
    required this.url,
    required this.onTapp,

}) : super (key: key);

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {


  Widget _cards(
      String title, String url, Function() onTapp
      ) {
    return GestureDetector(
      onTap: onTapp,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 10.8,
          width: MediaQuery.of(context).size.width / 2.25,
          child: Card(
            surfaceTintColor: Colors.white,
            elevation: 3,
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7)
            ),
            child: Stack(
              children: [
                Center(
                  child: Row(
                    children: [
                      Image.network(
                        url,
                        height: 100,
                        //width: 100,
                        fit: BoxFit.fitHeight,
                      ),
                      Text(title,
                        style: GoogleFonts.montserrat(
                            textStyle : const TextStyle(
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600
                            )
                        ),)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  
  

  @override
  Widget build(BuildContext context) {

    return _cards(widget.title, widget.url, widget.onTapp);
  }}