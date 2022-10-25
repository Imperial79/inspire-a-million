import 'package:flutter/material.dart';

double sdp(BuildContext context, double dp) {
  double width = MediaQuery.of(context).size.width;
  return (dp / 300) * width;
}
