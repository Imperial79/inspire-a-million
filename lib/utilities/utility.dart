import 'package:blog_app/services/globalVariable.dart';
import 'package:flutter/material.dart';

import '../services/database.dart';

Widget ShowModal(String blogId) {
  return StatefulBuilder(builder: (context, StateSetter setModalState) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: TextStyle(
              color: isDarkMode! ? Colors.white : Colors.grey.shade700,
              fontSize: 50,
              // fontWeight: FontWeight.w100,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          MaterialButton(
            onPressed: () {
              deletePost(blogId);
              Navigator.pop(context);
            },
            color: isDarkMode! ? Colors.grey.shade700 : Colors.grey.shade200,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.delete,
                    color: isDarkMode! ? Colors.white : Colors.grey.shade800,
                  ),
                  Text(
                    'Delete Blog',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.7,
                      color: Colors.grey.shade800,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}

deletePost(final blogId) async {
  await DatabaseMethods().deletePostDetails(blogId);
}
