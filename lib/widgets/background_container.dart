import 'package:flutter/material.dart';
import 'package:counter/utils/colors.dart';
class BackgroundContainer<T> extends StatelessWidget {
  const BackgroundContainer(this.child, this.padding, {super.key});
  final T child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
        )
        // gradient: LinearGradient(
        //   colors: [
        //     AppColorTemplate.lightBlue,
        //     AppColorTemplate.darkBlue,
        //   ],
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        // ),
      ),
      child: 
        Padding(
          padding: padding,
          child:_buildChild(),
        ),
    );
  }
  Widget _buildChild() {
    if (child is Widget) {
      return child as Widget;
    } else if (child is List<Widget>) {
      return Column(
        children: child as List<Widget>,
      );
    } else {
      throw ArgumentError('Child must be either a Widget or a List<Widget>');
    }
  }
}