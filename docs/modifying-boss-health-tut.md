# Overview
Usually, VSH2 handles boss health calculations as well as the health calculation for multi-bosses. Boss health calculation is handled the same way FF2 does for clarity: Using a familiar boss health formula and then dividing it amongst bosses based on the amount of bosses.

## Boss Health Formula
Boss' health formula is as follows...

`round( [ ([(a+b) * (b-c)]^d) + x ] / y )`
* `a` - initial health amount.
* `b` - amount of red players.
* `c` - subtraction iota.
* `d` - exponent iota.
* `x` - additional health iota.
* `y` - amount of bosses.

This formula is better represented by the stock function `CalcBossHealth`

```cpp
stock int CalcBossHealth(float initial, int playing, float subtract, float exponent, float additional) {
	return RoundFloat( Pow((((initial)+playing)*(playing-subtract)), exponent)+additional );
}
```

and is fully utilized in `ArenaRoundStart` event...

`boss.iMaxHealth = CalcBossHealth(760.8, gamemode.iPlaying, 1.0, 1.0341, 2046.0) / (bosscount);`

## Changing/Overriding Boss Health
As VSH2 was designed to do, you have full control over every boss' individual data, that includes health and max health!

The preferred way to override boss health for the round is through the event function hook `OnBossCalcHealth`.

Example, let's say we had a boss that has the total health of ALL players! Let's say red team has 20 players that are all soldiers! (200 x 20 = 4000).

In our Boss module plugin, we hook the function `OnBossCalcHealth`.

```cpp
VSH2_Hook(OnBossCalcHealth, MyCustomBoss_OnBossCalcHealth);
```

For our purposes, the hook `OnBossCalcHealth` will use the function prototype:
```cpp
function void (VSH2Player player, int& max_health, int boss_count, int red_players);
```

So it would look like this in our addon plugin:
```cpp
public void MyCustomBoss_OnBossCalcHealth(VSH2Player player, int& max_health, int boss_count, int red_players) {
	int new_health;
	for( int n=1; n <= MaxClients; n++ ) {
		if( !IsClientValid(n) || !IsPlayerAlive(n) || IsClientObserver(n) || VSH2Player(n).bIsBoss ) {
			continue;
		}
		new_health += GetEntProp(n, Prop_Data, "m_iMaxHealth");
	}
	max_health = new_health;
}
```