<?php
/*
  Quick and dirty example of shuffling a deck of cards and dealing a hand. The cards in the example are Magic The Gatering cards.
*/





$deck = array(
'Narcomoeba',
'Narcomoeba',
'Narcomoeba',
'Narcomoeba',
'Stinkweed Imp',
'Stinkweed Imp',
'Stinkweed Imp',
'Stinkweed Imp',
'Prized Amalgam',
'Prized Amalgam',
'Prized Amalgam',
'Prized Amalgam',
'Bloodghast',
'Bloodghast',
'Bloodghast',
'Bloodghast',
'Golgari Grave-Troll',
'Golgari Grave-Troll',
'Golgari Grave-Troll',
'Golgari Grave-Troll',
'Life from the Loam',
'Life from the Loam',
'Life from the Loam',
'Insolent Neonate',
'Insolent Neonate',
'Insolent Neonate',
'Insolent Neonate',
'Scourge Devil',
'Conflagrate',
'Conflagrate',
'Conflagrate',
'Shriekhorn',
'Faithless Looting',
'Faithless Looting',
'Faithless Looting',
'Faithless Looting',
'Cathartic Reunion',
'Cathartic Reunion',
'Cathartic Reunion',
'Cathartic Reunion',
'Aether Hub',
'Aether Hub',
'Aether Hub',
'Aether Hub',
'Mana Confluence',
'Mana Confluence',
'Mana Confluence',
'Mana Confluence',
'Wooded Foothills',
'Wooded Foothills',
'Wooded Foothills',
'Wooded Foothills',
'Bloodstained Mire',
'Bloodstained Mire',
'Bloodstained Mire',
'Bloodstained Mire',
'Blood Crypt',
'Stomping Ground',
'Mountain',
'Forest',
);


shuffle($deck);
shuffle($deck);
shuffle($deck);

$hand = array();
$hand []= $deck[0];
$hand []= $deck[1];
$hand []= $deck[2];
$hand []= $deck[3];
$hand []= $deck[4];
$hand []= $deck[5];
$hand []= $deck[6];

// remove the cards we just put in the hand.
array_splice($deck, 0, 0);
array_splice($deck, 0, 1);
array_splice($deck, 0, 2);
array_splice($deck, 0, 3);
array_splice($deck, 0, 4);
array_splice($deck, 0, 5);
array_splice($deck, 0, 6);

echo "<pre>";
var_dump($hand);

echo "<hr>Deck\n\n";
var_dump($deck);
echo "</pre>";
