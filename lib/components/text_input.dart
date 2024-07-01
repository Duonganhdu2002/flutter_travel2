import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final TextEditingController controller;
  final FocusNode? focusNode;

  const TextInput({
    Key? key,
    required this.onSendMessage,
    required this.controller,
    this.focusNode,
  }) : super(key: key);

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  void _sendMessage() {
    if (widget.controller.text.isNotEmpty) {
      widget.onSendMessage(widget.controller.text);
      widget.controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Type your message',
                          hintStyle: TextStyle(
                              color: Color(0xFF7D848D),
                              fontSize: 17,
                              fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF7D848D),
                        BlendMode.srcATop,
                      ),
                      child: SvgPicture.asset(
                        "assets/images/file.svg",
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFD521),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: widget.controller.text.isNotEmpty
                        ? SvgPicture.asset(
                            "assets/images/send.svg",
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          )
                        : SvgPicture.asset(
                            "assets/images/voice.svg",
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                    onPressed: _sendMessage,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
