import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../screens/login/num_screen.dart';

Widget CustomButton({
  required String hint,
  required Function onPress,
  Color? color,
  required BorderRadius borderRadius,
}) {
  const buttonHeight =
      50.0; // You can adjust the height according to your preference
  const fontSize =
      buttonHeight * 0.38; // Adjust font size relative to button height

  return SizedBox(
    height: buttonHeight,
    width: double.infinity,
    child: ClipRRect(
      borderRadius: borderRadius,
      child: EasyButton(
        type: EasyButtonType.elevated,
        onPressed: onPress as void Function()?,
        buttonColor: color ?? const Color(0xFF0000FF),
        idleStateWidget: Text(
          hint,
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        loadingStateWidget: const CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white,
          ),
        ),
        useWidthAnimation: false,
        useEqualLoadingStateWidgetDimension: true,
        height: 45,
        elevation: 0.0,
        contentGap: 5.1,
      ),
    ),
  );
}

class VehicleCard extends StatelessWidget {
  final String vName;
  final String image;
  final double height;
  final Function() onPress;

  VehicleCard({
    super.key,
    required this.vName,
    required this.image,
    required this.onPress,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPress,
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 130,
                    child: Center(
                      child: SvgPicture.asset(
                        image,
                        height: height,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          vName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Get.to(() => const LocationDetail());
                          onPress();
                        },
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      'Book for your delivery',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

TextFormField formField(String fieldName, IconData icon,
    {TextEditingController? controller,
    IconData? sufIcon,
    bool obscure = false,
    bool capital = false,
    bool isNum = false,
    bool? read = false,
    String? hint}) {
  return TextFormField(
    initialValue: hint,
    controller: controller,
    cursorColor: Colors.black,
    obscureText: obscure,
    keyboardType: isNum ? TextInputType.number : TextInputType.text,
    textCapitalization:
        capital ? TextCapitalization.characters : TextCapitalization.sentences,
    // inputFormatters: [
    //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 @.-]')),
    // ],
    readOnly: read != true ? false : true,
    decoration: InputDecoration(
      labelText: fieldName,
      labelStyle: const TextStyle(color: Colors.black),
      border: const OutlineInputBorder(borderSide: BorderSide()),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.black,
      ),
      suffixIcon: sufIcon != null
          ? IconButton(
              icon: Icon(sufIcon),
              onPressed: () {
                Get.off(const NumberScreen());
              },
            )
          : null,
    ),
  );
}

class CustomDropdownFormField extends StatelessWidget {
  final String? hint;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;

  const CustomDropdownFormField({
    Key? key,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      hint: Text(hint!),
      menuMaxHeight: 300,
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(color: Colors.black),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class ForwardIcon extends StatelessWidget {
  final Function() onTap;

  const ForwardIcon({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Ionicons.chevron_forward_outline,
          size: 30,
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final String? value;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final Function() onTap;

  const SettingItem({
    super.key,
    required this.title,
    this.value,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          value != null
              ? Text(
                  value!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                )
              : const SizedBox(),
          const SizedBox(width: 15),
          ForwardIcon(
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class EditItem extends StatelessWidget {
  final String title;
  final Widget widget;

  const EditItem({
    super.key,
    required this.widget,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
        // const SizedBox(width: 30),
        Expanded(
          flex: 5,
          child: widget,
        ),
      ],
    );
  }
}

class ProgressDialog extends StatelessWidget {
  final String message;

  ProgressDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // backgroundColor: Colors.black,
      elevation: 0.0,
      child: Container(
        margin: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(width: 6),
              const CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0000FF)),
              ),
              const SizedBox(width: 15),
              Text(
                message!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
