import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmerWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;

  LoadingShimmerWidget({this.child, this.enabled});

  @override
  _LoadingShimmerWidgetState createState() => _LoadingShimmerWidgetState();
}

class _LoadingShimmerWidgetState extends State<LoadingShimmerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        period: Duration(seconds: 3),
        enabled: widget.enabled,
        child: widget.child,
      ),
    );
  }
}
