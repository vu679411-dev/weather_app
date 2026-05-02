import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();

  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', history);
  }


  void searchCity() async {
    final city = controller.text.trim();
    if (city.isEmpty) return;

    setState(() {
      history.remove(city);
      history.insert(0, city);
      if (history.length > 5) history.removeLast();
    });

    await saveHistory();

    Navigator.pop(context, city); //TRẢ CITY VỀ HOME
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');

    setState(() {
      history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search City"),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: clearHistory,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// INPUT
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter city...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: searchCity,
                ),
              ),
              onSubmitted: (_) => searchCity(),
            ),

            const SizedBox(height: 20),

            /// HISTORY
            if (history.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Searches",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final city = history[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(city),

                              ///  TRẢ CITY
                              onTap: () {
                                Navigator.pop(context, city);
                              },

                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () async {
                                  setState(() {
                                    history.removeAt(index);
                                  });
                                  await saveHistory();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text("No search history"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}