# loot-fight

Loot &amp; Fight game
======================

Loot & Fight is a strategy game which let's user purchase an initial character, make it more powerful by either purchasing certain equipments or by winning certain loot through fights, which they with other in game characters. Player has to choose the best strategy i.e. increase their power with least spends and getting into less risky fights in order to reach the top of the leaderboard.


Details of the files
=====================

MysteryBox.sol : This smart contract randomly generates the characters of this game and assigns them to buyers.   

lootCharEquip.sol : This smart contract defines the character's properties such as weapon, chest, head, waist etc. It lists various types of equipments (a.k.a. loot) which can be equipped by character properties. For example, Hammer, Quarterstaff, Mace, Club etc. for weapon; Divine robe, Silk robe etc. for chest; and so on. 
It also holds the logic to equip the loot to the characters and other operational functions. It also contains a few privileges functions which let's admin to mint and pause token geneation.

figting_engine.sol : This contract contains the fighting and winning logic between the characters and contains utility functions to get the health status of characters.
