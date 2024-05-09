import 'package:flutter/material.dart';
class LoadingDialog extends StatelessWidget {

  String mesaggeText;
  LoadingDialog({super.key,required this.mesaggeText});

  @override
  Widget build(BuildContext context) {
    return Dialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black87,
      child: Container(
        margin: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),

        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(width: 5,),
              const CircularProgressIndicator(valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),

                ),
              const SizedBox(width: 8,),
              Text(mesaggeText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white
              ),
              ),

            ],

          ),
        ),
      ),
    );
  }
}
