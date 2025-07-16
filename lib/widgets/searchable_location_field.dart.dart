import 'package:flutter/material.dart';

class SearchableLocationField extends StatefulWidget {
  final ValueChanged<String>? onLocationSelected;
  final List<String> suggestions;

  const SearchableLocationField({
    super.key,
    this.onLocationSelected,
    required this.suggestions,
  });

  @override
  State<SearchableLocationField> createState() =>
      _SearchableLocationFieldState();
}

class _SearchableLocationFieldState extends State<SearchableLocationField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  List<String> _filtered = [];
  OverlayEntry? _overlay;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _overlay?.remove();
    super.dispose();
  }

  void _updateOverlay() {
    _overlay?.remove();
    final render = context.findRenderObject() as RenderBox;
    final pos = render.localToGlobal(Offset.zero);
    _overlay = OverlayEntry(
      builder: (ctx) => Positioned(
        left: pos.dx + 16,
        top: pos.dy + render.size.height + 4,
        right: 16,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _filtered.length,
            itemBuilder: (ctx, i) {
              return ListTile(
                title: Text(_filtered[i]),
                onTap: () {
                  _controller.text = _filtered[i];
                  widget.onLocationSelected?.call(_filtered[i]);
                  _overlay?.remove();
                  _focus.unfocus();
                },
              );
            },
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _onChanged(String val) {
    _filtered = widget.suggestions
        .where((s) => s.toLowerCase().contains(val.toLowerCase()))
        .toList();
    if (_focus.hasFocus && _filtered.isNotEmpty) {
      _updateOverlay();
    } else {
      _overlay?.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focus,
      decoration: InputDecoration(
        labelText: 'Location',
        hintText: 'Type to search location',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      onChanged: _onChanged,
      onTap: () {
        if (_filtered.isNotEmpty) _updateOverlay();
      },
      validator: (v) => v == null || v.isEmpty ? 'Enter Location' : null,
    );
  }
}
