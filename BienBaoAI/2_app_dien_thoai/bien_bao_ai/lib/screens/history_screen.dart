import 'package:flutter/material.dart';
import '../services/history.dart';
import '../services/signs.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem>? _items;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    await SignDb.load();
    final v = await HistoryStore.load();
    if (mounted) setState(() => _items = v);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử nhận diện'), actions: [
        IconButton(
          tooltip: 'Xóa lịch sử',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            await HistoryStore.clear();
            _reload();
          },
        ),
      ]),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('Chưa có lần nhận diện nào'))
              : Column(children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      'Số lần: ${items.length}   ·   Thời gian chạy mô hình trung bình: '
                      '${(items.map((e) => e.inferenceMs).reduce((a, b) => a + b) / items.length).toStringAsFixed(1)} ms',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final h = items[i];
                        final s = SignDb.byId(h.signId);
                        final t = h.time;
                        return ListTile(
                          leading: Image.asset(s.asset, width: 40, height: 40, fit: BoxFit.cover),
                          title: Text(h.confident ? s.name : 'Chưa chắc chắn: ${s.name}'),
                          subtitle: Text('${_two(t.day)}/${_two(t.month)} ${_two(t.hour)}:${_two(t.minute)}  ·  '
                              '${(h.prob * 100).toStringAsFixed(1)}%  ·  ${h.inferenceMs.toStringAsFixed(1)} ms'),
                        );
                      },
                    ),
                  ),
                ]),
    );
  }
}
