import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgpt_flutterapp/chatmessage.dart';
import 'package:chatgpt_flutterapp/threeDots.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller=TextEditingController();

  ChatGPT? chatGPT;
  StreamSubscription? _subscription;
  @override
  void initState() {
    super.initState();
    chatGPT=ChatGPT.instance;
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  final List<ChatMessage> _messages= []; 
  bool _isTyping=false; 

  void _sendMessage(){
    ChatMessage message= ChatMessage(text: _controller.text, sender: "user");
    setState(() {
      _messages.insert(0, message);
      _isTyping=true;

    });
    
      final request = CompleteReq(prompt: message.text, model: kTranslateModelV3,
      max_tokens: 200);
      _subscription = chatGPT!.builder("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",
      orgId: "").onCompleteStream(request: request)
      .listen((response) { 
        Vx.log(response!.choices[0].text);
        ChatMessage botMessage =ChatMessage(text: response!.choices[0].text, sender: "Bot");
        setState(() {
          _isTyping=false;
          _messages.insert(0, botMessage);
        });
      }) ;
      
    _controller.clear();
  }
  Widget _buildTextComposer(){
    return Row(
      children: [
        Expanded(
          child: TextField(
            onSubmitted:(value) => _sendMessage() ,
            controller: _controller,
            decoration:const InputDecoration.collapsed(hintText: "Send a message"),
          ),
        ),
        IconButton(
          onPressed: _sendMessage, 
          
          icon: const Icon(Icons.send))
      ],
    ).px16();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT App'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(child: 
            ListView.builder(
              reverse: true,
              padding: Vx.m8,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
              return _messages[index];
            } )),
            if(_isTyping) ThreeDots(),

          const  Divider(height: 1.0,),
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