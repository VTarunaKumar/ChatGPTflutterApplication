import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgpt_ai_app_flutter/chat_message.dart';
import 'package:chatgpt_ai_app_flutter/three_dots.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];


ChatGPT? chatGPT;
StreamSubscription? _subscription;
bool _isTyping  =  false;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatGPT = ChatGPT.instance;
  }
@override
  void dispose() {
   _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage(){
    ChatMessage message = ChatMessage(text: _controller.text, sender: "user");
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });
    _controller.clear();
   final request =  CompleteReq(prompt: message.text, model : kTranslateModelV3, max_tokens : 200 );

    _subscription = chatGPT!
        .builder("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",orgId: "")
        .onCompleteStream(request: request)
        .listen((response) {
      Vx.log(response!.choices[0].text);
      ChatMessage botMessage  = ChatMessage(text: response!.choices[0].text, sender: "bot",);
      setState(() {
        _isTyping = false;
        _messages.insert(0, botMessage);
      });

    });


  }




  Widget _buildTextComposer(){
    return Row(
      children: [
        Expanded(child: TextField(
          controller: _controller,
          onSubmitted: (value) => _sendMessage(),

          decoration: const InputDecoration.collapsed(hintText: "Send a message"),
        ),),
        IconButton(


            onPressed: () => _sendMessage(),


            icon: Icon(Icons.send))
      ],
    ).px16();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: const Text("ChatGPT BOT"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(child: ListView.builder(
              reverse: true,
              padding: Vx.m8,
              itemCount: _messages.length,
                itemBuilder: (context,index){
            return _messages[index];

            },),),
            if(_isTyping) ThreeDots(),
            Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
              ),
              child: _buildTextComposer(),
            )
          ],
        ),
      ),
    );
  }
}

