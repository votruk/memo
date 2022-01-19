import 'package:collection/collection.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/widgets.dart';
import 'package:memo/app_images.dart';
import 'package:memo/card_state.dart';
import 'package:rxdart/rxdart.dart';

class MainBloc {
  static const maxAttemptsCount = 20;

  final List<GlobalKey<FlipCardState>> keys =
      List.generate(20, (_) => GlobalKey<FlipCardState>());

  final cardStatesSubject = BehaviorSubject<List<CardState>>();
  final turnsSubject = BehaviorSubject<int>.seeded(0);
  final gameStateSubject =
      BehaviorSubject<GameState>.seeded(GameState.inProgress);

  MainBloc() {
    cardStatesSubject.add(getRandomStandardImages());
  }

  Stream<List<CardState>> observeCardStates() => cardStatesSubject;

  Stream<int> observeTurnsCount() => turnsSubject.distinct();

  Stream<GameState> observeGameState() => gameStateSubject.distinct();

  void onCardClicked(final String id) {
    final CardState currentState =
        cardStatesSubject.value.singleWhere((state) => state.id == id);
    if (currentState.opened || currentState.found) {
      return;
    }
    final List<CardState> updatedList = List.of(cardStatesSubject.value);
    final openedAndNotFoundCards = updatedList.where(
        (state) => state.opened && !state.found && state.id != currentState.id);
    if (openedAndNotFoundCards.length == 0) {
      print("0 cards opened");
      changeItemInList(updatedList, currentState, true, false);
    } else if (openedAndNotFoundCards.length == 1) {
      turnsSubject.add(turnsSubject.value + 1);
      print("1 cards opened");
      final CardState secondCardCurrentState = cardStatesSubject.value
          .singleWhere((state) =>
              state.path == currentState.path && state.id != currentState.id);
      if (secondCardCurrentState.opened) {
        changeItemInList(updatedList, currentState, true, true);
        changeItemInList(updatedList, secondCardCurrentState, true, true);
      } else {
        changeItemInList(updatedList, currentState, true, false);
      }
      final bool allFound = updatedList.every((state) => state.found);
      if (allFound) {
        gameStateSubject.add(GameState.won);
      } else {
        final currentTurn = turnsSubject.value;
        if (currentTurn == maxAttemptsCount) {
          gameStateSubject.add(GameState.lost);
        }
      }
    } else {
      print("2 cards opened");
      changeItemInList(updatedList, currentState, true, false);
      openedAndNotFoundCards.forEach((openedCard) {
        changeItemInList(updatedList, openedCard, false, false);
        openedCard.key.currentState!.toggleCard();
      });
    }
    cardStatesSubject.add(updatedList);
    currentState.key.currentState!.toggleCard();
  }

  void startNewGame() {
    keys.forEach((element) {
      if (!element.currentState!.isFront) {
        element.currentState!.toggleCard();
      }
    });
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      gameStateSubject.add(GameState.inProgress);
      cardStatesSubject.add(getRandomStandardImages());
      turnsSubject.add(0);
    });
  }

  void changeItemInList(
    final List<CardState> list,
    final CardState state,
    final bool opened,
    final bool found,
  ) {
    final int firstItemIndex = list.indexOf(state);
    list[firstItemIndex] = state.changeState(opened: opened, found: found);
  }

  List<CardState> getRandomStandardImages() {
    final list = [...AppImages.defaultImages, ...AppImages.defaultImages];
    list.shuffle();
    return list
        .mapIndexed((index, path) => CardState.initial(keys[index], path))
        .toList();
  }

  void dispose() {
    cardStatesSubject.close();
    turnsSubject.close();
    gameStateSubject.close();
  }
}

enum GameState { inProgress, won, lost }
