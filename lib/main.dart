import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const DiceApp());
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DicePage(),
    );
  }
}

class DicePage extends StatefulWidget {
  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  final List<String> faces = [
    "1.png",
    "2.png",
    "3.png",
    "4.png",
    "5.png",
    "dinamite.png",
  ];

  final Random _random = Random();

  // Inicializa os dados aleatoriamente (0 a 4)
  List<int> valores = List.generate(5, (_) => Random().nextInt(5));
  List<bool> travados = List.generate(5, (_) => false);

  // Player de áudio
  final AudioPlayer _audioPlayer = AudioPlayer();

  void girarDado(int index) async {
    if (travados[index]) return;

    int vezes = 10 + _random.nextInt(10); // passos da animação
    for (int i = 0; i < vezes; i++) {
      await Future.delayed(const Duration(milliseconds: 80), () {
        setState(() {
          valores[index] = (valores[index] + 1) % faces.length;
        });
      });
    }

    // Se parou na dinamite
    if (faces[valores[index]] == "dinamite.png") {
      setState(() {
        travados[index] = true;
      });
      _audioPlayer.play(AssetSource('audio/explosao.mp3'));
    }

    // Verifica se 3 ou mais dados estão com "2.png"
    int countDois = valores.where((v) => faces[v] == "2.png").length;
    if (countDois >= 3) {
      _audioPlayer.play(AssetSource('audio/metralhadora.mp3'));
    }
  }

  void girarTodos() {
    for (int i = 0; i < valores.length; i++) {
      if (!travados[i]) {
        girarDado(i);
      }
    }
  }

  void liberarDinamites() {
    setState(() {
      for (int i = 0; i < travados.length; i++) {
        travados[i] = false;
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("Jogo dos Dados"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemCount: valores.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => girarDado(index),
                  child: Opacity(
                    opacity: travados[index] ? 0.5 : 1.0,
                    child: Image.asset(
                      "assets/images/${faces[valores[index]]}",
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: girarTodos,
                icon: const Icon(Icons.casino),
                label: const Text("Girar Todos"),
              ),
              ElevatedButton.icon(
                onPressed: liberarDinamites,
                icon: const Icon(Icons.refresh),
                label: const Text("Liberar Dinamites"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
