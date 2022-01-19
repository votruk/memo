import 'package:collection/collection.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:memo/app_images.dart';
import 'package:memo/card_state.dart';
import 'package:memo/main_bloc.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainBloc bloc = MainBloc();

  @override
  Widget build(BuildContext context) {
    return Provider.value(value: bloc, child: _MainPageContent());
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class _MainPageContent extends StatelessWidget {
  const _MainPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14181B),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Text(
                "Мемори",
                style: TextStyle(color: Colors.white, fontSize: 60),
              ),
            ),
            Spacer(),
            TriesCountWidget(),
            const SizedBox(height: 12),
            Stack(
              children: [
                CardsWidget(),
                TerminalStateOverlay(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TerminalStateOverlay extends StatelessWidget {
  const TerminalStateOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainBloc>();
    return StreamBuilder<GameState>(
      stream: bloc.observeGameState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final GameState gameState = snapshot.data!;
        if (gameState == GameState.inProgress) {
          return const SizedBox.shrink();
        }
        return Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.75),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  gameState == GameState.won ? "Победа 😎" : "Поражение 😢",
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
                const SizedBox(height: 16),
                const RestartButton()
              ],
            ),
          ),
        );
      },
    );
  }
}

class RestartButton extends StatelessWidget {
  const RestartButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainBloc>();
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        side: BorderSide(color: Colors.white54, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: bloc.startNewGame,
      child: Text(
        "Начать заново".toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }
}

class TriesCountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<int>(
      initialData: 0,
      stream: bloc.observeTurnsCount(),
      builder: (context, snapshot) {
        final int count =
            !snapshot.hasData || snapshot.data == null ? 0 : snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("Попытки",
                      style: TextStyle(fontSize: 30, color: Colors.white)),
                  Text(
                    "$count/${MainBloc.maxAttemptsCount}",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  )
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: count / MainBloc.maxAttemptsCount,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<List<CardState>>(
      stream: bloc.observeCardStates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final List<CardState> states = snapshot.data!;
        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          padding: EdgeInsets.symmetric(horizontal: 16),
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          children: states.mapIndexed((index, state) {
            return FlipCard(
              flipOnTouch: false,
              key: state.key,
              front: GestureDetector(
                onTap: () => bloc.onCardClicked(state.id),
                child: const BackgroundCard(),
              ),
              back: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  state.found ? Colors.grey : Colors.transparent,
                  BlendMode.saturation,
                ),
                child: AssetCardWithImage(path: state.path),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class BackgroundCard extends StatelessWidget {
  const BackgroundCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Image.asset(
        AppImages.memory2,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
      ),
    );
  }
}

class AssetCardWithImage extends StatelessWidget {
  final String path;

  const AssetCardWithImage({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Container(
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.black45,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
