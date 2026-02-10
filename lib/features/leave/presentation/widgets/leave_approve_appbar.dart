import 'package:flutter/material.dart';

class LeaveApproveAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String> onSearch;
  final ValueChanged<DateTime?> onPickDate;
  final VoidCallback onClear;

  const LeaveApproveAppBar({
    super.key,
    required this.onSearch,
    required this.onPickDate,
    required this.onClear,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  State<LeaveApproveAppBar> createState() => _LeaveApproveAppBarState();
}

class _LeaveApproveAppBarState extends State<LeaveApproveAppBar> {
  bool _isSearching = false;
  DateTime? _selectedDate;
  final TextEditingController _controller = TextEditingController();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onPickDate(picked);
    }
  }

  void _clear() {
    setState(() {
      _isSearching = false;
      _selectedDate = null;
      _controller.clear();
    });

    widget.onSearch('');
    widget.onPickDate(null);
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0056B3),
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        "Manager - Leave Requests",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,

      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            if (_isSearching) {
              _clear();
            } else {
              setState(() => _isSearching = true);
            }
          },
        ),
      ],

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_isSearching ? 72 : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _isSearching ? 72 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFF0056B3),
          child: _isSearching
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search name / code / leave type...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: .15),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => widget.onSearch(v.toLowerCase()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                      onPressed: _pickDate,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
