import 'package:flutter/material.dart';

import '../helper/constant.dart';

class Style {
  InputDecoration dekorasiInput({hint, icon}) {
    return InputDecoration(
      label: Text(hint ?? ""),
      prefixIcon: icon,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.black12,
          width: .5,
        ),
      ),
    );
  }

  BoxDecoration dekorasiDropdown() {
    return BoxDecoration(
      color: warnaFill,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.black,
        width: .5,
      ),
    );
  }

  BoxDecoration dekorasiFoto() {
    return BoxDecoration(
      color: warnaFill,
      borderRadius: const BorderRadius.all(
        Radius.circular(10),
      ),
    );
  }

  BoxDecoration dekorasiIconButton({warna}) {
    return BoxDecoration(
      color: warna ?? warnaPrimary,
      borderRadius: const BorderRadius.all(
        Radius.circular(10),
      ),
    );
  }
}
