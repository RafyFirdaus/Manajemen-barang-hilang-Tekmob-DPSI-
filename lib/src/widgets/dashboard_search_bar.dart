import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onRefreshPressed;
  final Function(String)? onSearchChanged;
  final String hintText;

  const DashboardSearchBar({
    Key? key,
    required this.controller,
    this.onRefreshPressed,
    this.onSearchChanged,
    this.hintText = 'Telusuri laporan',
  }) : super(key: key);

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          widget.onSearchChanged?.call('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ),
         if (widget.onRefreshPressed != null) ...[
           const SizedBox(width: 12),
           Container(
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(12),
             ),
             child: IconButton(
               onPressed: widget.onRefreshPressed,
               icon: const Icon(
                 Icons.refresh,
                 size: 24,
                 color: Color(0xFF1F41BB),
               ),
             ),
           ),
         ],
      ],
    );
  }
}