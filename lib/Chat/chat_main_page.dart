import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChatMainPage extends StatefulWidget {
  const ChatMainPage({Key? key}) : super(key: key);

  @override
  State<ChatMainPage> createState() => _ChatMainPageState();
}

class _ChatMainPageState extends State<ChatMainPage> {
  List<Map<String, dynamic>> chats = [
    {
      'avatarText': 'A',
      'name': 'Ayşe',
      'message': 'Toplantı saat kaçta?',
      'time': '12:10',
      'unread': true,
      'isSent': false,
      'archived': false,
    },
    {
      'avatarText': 'G',
      'name': 'Galip',
      'message': 'Nasılsın?',
      'time': '13:45',
      'unread': false,
      'isSent': true,
      'archived': false,
    },
    {
      'avatarText': 'Z',
      'name': 'Zeynep',
      'message': 'Görüşürüz.',
      'time': 'Dün',
      'unread': false,
      'isSent': false,
      'archived': false,
    },
  ];

  void _showChatOptions(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(leading: const Icon(Icons.volume_off), title: const Text('Sessize al'), onTap: () {}),
              ListTile(leading: const Icon(Icons.info_outline), title: const Text('Kişi bilgisi'), onTap: () {}),
              ListTile(leading: const Icon(Icons.lock_outline), title: const Text('Sohbeti kilitle'), onTap: () {}),
              ListTile(leading: const Icon(Icons.cleaning_services_outlined), title: const Text('Sohbeti temizle'), onTap: () {}),
              ListTile(leading: const Icon(Icons.favorite_border), title: const Text('Favorilere ekle'), onTap: () {}),
              ListTile(leading: const Icon(Icons.list_alt), title: const Text('Listeye ekle'), onTap: () {}),
              const Divider(),
              ListTile(leading: const Icon(Icons.block, color: Colors.red), title: Text('$name kişisini engelle', style: const TextStyle(color: Colors.red)), onTap: () {}),
              ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Sohbeti sil', style: TextStyle(color: Colors.red)), onTap: () {}),
            ],
          ),
        );
      },
    );
  }

  void _archiveChat(int index) {
    setState(() {
      chats[index]['archived'] = true;
    });
  }

  void _unarchiveChat(int index) {
    setState(() {
      chats[index]['archived'] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final archivedChats = chats.where((c) => c['archived'] == true).toList();
    final activeChats = chats.where((c) => c['archived'] == false).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF57A20),
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Kullanıcı ara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (archivedChats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.archive, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text('Arşivlenmiş (${archivedChats.length})', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                ...activeChats.asMap().entries.map((entry) {
                  final i = chats.indexOf(entry.value);
                  final chat = entry.value;
                  return Slidable(
                    key: ValueKey(chat['name']),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.4,
                      children: [
                        SlidableAction(
                          onPressed: (_) => _showChatOptions(context, chat['name']),
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          icon: Icons.more_horiz,
                          label: 'Daha fazla',
                        ),
                        SlidableAction(
                          onPressed: (_) => _archiveChat(i),
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          icon: Icons.archive,
                          label: 'Arşivle',
                        ),
                      ],
                    ),
                    child: _ChatListTile(
                      avatarText: chat['avatarText'],
                      name: chat['name'],
                      message: chat['message'],
                      time: chat['time'],
                      unread: chat['unread'],
                      isSent: chat['isSent'],
                      avatarColor: const Color(0xFFF57A20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatDetailPage(name: chat['name'], avatarColor: const Color(0xFFF57A20))),
                        );
                      },
                    ),
                  );
                }),
                ...archivedChats.asMap().entries.map((entry) {
                  final i = chats.indexOf(entry.value);
                  final chat = entry.value;
                  return Slidable(
                    key: ValueKey('archived_${chat['name']}'),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.5,
                      children: [
                        SlidableAction(
                          onPressed: (_) => _showChatOptions(context, chat['name']),
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          icon: Icons.more_horiz,
                          label: 'Daha fazla',
                        ),
                        SlidableAction(
                          onPressed: (_) => _unarchiveChat(i),
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          icon: Icons.unarchive,
                          label: 'Arşivden çıkar',
                        ),
                      ],
                    ),
                    child: _ChatListTile(
                      avatarText: chat['avatarText'],
                      name: chat['name'],
                      message: chat['message'],
                      time: chat['time'],
                      unread: chat['unread'],
                      isSent: chat['isSent'],
                      avatarColor: const Color(0xFFF57A20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatDetailPage(name: chat['name'], avatarColor: const Color(0xFFF57A20))),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final String avatarText;
  final String name;
  final String message;
  final String time;
  final bool unread;
  final bool isSent;
  final VoidCallback onTap;
  final Color avatarColor;

  const _ChatListTile({
    required this.avatarText,
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.isSent,
    required this.onTap,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        child: Text(avatarText, style: const TextStyle(color: Colors.black)),
      ),
      title: Row(
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (unread)
            const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Icon(Icons.circle, color: Colors.amber, size: 10),
            ),
        ],
      ),
      subtitle: Text(message),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: const TextStyle(fontSize: 12)),
          if (isSent)
            const Icon(Icons.done_all, color: Colors.blue, size: 16)
          else
            const Icon(Icons.done, color: Colors.grey, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }
}

class ChatDetailPage extends StatelessWidget {
  final String name;
  final Color avatarColor;
  const ChatDetailPage({Key? key, required this.name, required this.avatarColor}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF57A20),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: avatarColor,
              child: Text(name[0], style: const TextStyle(color: Colors.black)),
            ),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(color: Colors.white)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(child: Text('Sohbet Detay Ekranı')), // Sonraki adımda doldurulacak
    );
  }
} 