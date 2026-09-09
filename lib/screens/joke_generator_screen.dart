import 'package:flutter/material.dart';
import '../services/joke_service.dart';

class JokeGeneratorScreen extends StatefulWidget {
  const JokeGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<JokeGeneratorScreen> createState() => _JokeGeneratorScreenState();
}

class _JokeGeneratorScreenState extends State<JokeGeneratorScreen> {
  String _joke = 'Tap the button to get a random joke!';
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _fetchJoke() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _joke = 'Loading...';
    });

    try {
      final joke = await JokeService.getRandomJokeNoAuth();
      setState(() {
        _joke = joke;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _joke = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Joke Generator'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Joke Display Card
                Expanded(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const CircularProgressIndicator()
                            else if (_errorMessage.isNotEmpty)
                              Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  const Icon(
                                    Icons.emoji_emotions_outlined,
                                    size: 48,
                                    color: Colors.purple,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _joke,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(height: 1.6),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Fetch Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchJoke,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Get Another Joke'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade400,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
