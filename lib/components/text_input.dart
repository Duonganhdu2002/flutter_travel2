import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final FocusNode? focusNode;

  const TextInput({super.key, required this.onSendMessage, this.focusNode});

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      widget.onSendMessage(_controller.text);
      _controller.clear();
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
                        controller: _controller,
                        focusNode: widget.focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Type your message',
                          hintStyle: TextStyle(
                              color: Color(0xFF7D848D),
                              fontSize: 17,
                              fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
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
                    icon: ImageFiltered(
                      imageFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcATop),
                      child: SvgPicture.asset(
                        "assets/images/voice.svg",
                        width: 24,
                        height: 24,
                      ),
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
