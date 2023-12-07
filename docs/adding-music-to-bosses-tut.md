# Intro
In some cases, you want your boss to have music in order to spice up the action a little or just to add more personality to your boss; in any case, adding music to your boss is easy BUT this page assumes you know how to make a boss from scratch and know about the VSH2 API, if not then please read [how to make your own boss](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/Creating-or-Adding-Bosses-(VSH2-Boss-Subplugin-Tutorial))


For the example codes, I will use the Christian Brutal Sniper's single theme song.

## Setting up the Music and Files
In order to install music to play for our boss' round, we first need to (literally) define the song(s) that we want to play. CBS's theme song of The Millionaire's Holiday by Combustible Edison is defined through a macro.
```ini
// cbs.cfg
"sounds" {
	"music" {
		"saxton_hale/the_millionaires_holiday.mp3"    "140.0"
	}
}
```

After we've defined all the music we need, we then set the file to be downloaded by prepping the sound which will precache and add the file to the downloads table.
```c++
public void AddCBSToDownloads() {
	...
	PrepareSound(CBSTheme);
	...
}
```
## Activating the Music
Alright, our files are in place and we've defined our song, how do we get it to play? In a file called `handler.sp`, there's a function called `ManageMusic` which plays periodically.
`ManageMusic` gives us two useful variables: `char song[PLATFORM_MAX_PATH]` which let's us copy our song's file name so that the VSH plugin internals will play the song for us AND `float& time` which is a float reference that let's us set how long to play the song for!

For example's sake, we want CBS's theme song to play for 140 seconds, which is longer than the actual song but the extra seconds are to leave some moment of silence. Setting up CBS's music looks exactly like this.

```c++
public void ManageMusic(char song[PLATFORM_MAX_PATH], float& time) {
	/// UNFORTUNATELY, we have to get a random boss so we can set our music, tragic I know...
	/// Remember that you can get a random boss filtered by type as well!
	BasePlayer currBoss = gamemode.GetRandomBoss(true);
	if( currBoss ) {
		switch( currBoss.iBossType ) {
			case -1: { song = ""; time = -1.0; }
			case CBS: {
				strcopy(song, sizeof(song), CBSTheme);
				time = 140.0;
			}
			...
		}
	}
}
```

We use `strcopy` to copy the string called `CBSTheme` (which is a define macro of the song's file name) to the `song` array and then we set the time to 140.0 and BINGO you're done. When you compile and load up the game, CBS's theme will play whenever a CBS boss exists or, in the case of multibosses, if the CBS player was chosen as the random boss for whose theme will play.

## Adding Multiple Songs
In certain cases, one song isn't enough. Sometimes your player base gets tired of hearing the same song. Such a situation can be rectified by adding multiple songs to a boss! The process is extremely similar to the previous examples, the only difference is that we're setting up our boss file to precache and add multiple songs for download, then we use a VSH2 hook `OnMusic` to shuffle or sequence the songs you give to the boss.

## Setting Up
The easiest AND most MINIMAL effort to get multiple songs for a boss is through a multidimensional char array, here's an example using a fake boss called **MyBoss**.

```c++
// myboss.sp
#define MyBossTheme1		"myboss_soundfolder/mybosstheme1.mp3"
#define MyBossTheme2		"myboss_soundfolder/mybosstheme2.mp3"
#define MyBossTheme3		"myboss_soundfolder/mybosstheme3.mp3"

char MyBossThemes[][] = {
	MyBossTheme1, MyBossTheme2, MyBossTheme3
};

float MyBossThemesTime[] = {
	160.0, 190.0, 150.0
};
```
As you can see, we still define our song file strings through a define-macro but I've made it easier to use by making a multidimensional char array for all our songs and made a float array for all the playtime of the songs (make sure they're all in order). There are other ways to organize how you want your boss to have multiple theme songs but this example is just a minimal way of doing so.

## Activating Multiple Songs
Activating multiple songs is also the same but since our example has an array available as to what song we can choose, I will use a simple form of song shuffling as an example.
```c++
VSH2_Hook(OnMusic, MyBoss_OnMusic);

...

public void MyBoss_OnMusic(char song[PLATFORM_MAX_PATH], float& time, VSH2Player player) {
	int picked_song = player.GetPropInt("iSongPick");
	int pick = ( picked_song == -1 || picked_song > 2 )
		? GetRandomInt(0, sizeof(MyBossThemes))
		: picked_song;
	strcopy(song, sizeof(song), MyBossThemes[pick]);
	time = MyBossThemesTime[pick];
}
```

As you can see in this example, we get a random number and use that as an index to what song will be played for the boss and how much time the song needs to play. The Boss methodmap itself has a property called `iSongPick` which is builtin to allow players to have an option to choose a song (on repeat). Please Note that VSH2 will not loop over the same song, the songs are shuffled in real time and, though the same song might be picked, the `ManageMusic` function will be called again.

## Preventing Playing The Same Song
Sometimes, even with having multiple songs, the code might still pick the same song that it just played. A convenient way to prevent this is by using the the stock convenience function `ShuffleIndex` which takes the amount of songs available as a size and a "current index" number to then shuffle to a randomized index that is not the current index.

So with the code above, we could prevent repeating a song by modifying it as so:
```c++
VSH2_Hook(OnMusic, MyBoss_OnMusic);

...

public void MyBoss_OnMusic(char song[PLATFORM_MAX_PATH], float& time, VSH2Player player) {
	static int curr_index = -1;
	int picked_song = player.GetPropInt("iSongPick");
	int num_songs = sizeof(MyBossThemes) - 1;
	int pick = ( picked_song < 0 || picked_song > num_songs )? ShuffleIndex(sizeof(MyBossThemes), curr_index) : picked_song;
	strcopy(song, sizeof(song), MyBossThemes[pick]);
	time = MyBossThemesTime[pick];
	curr_index = pick;
}
```

With the code above, we not only let a player have the choice of what music they want to kill RED players to the tune of but also make sure that players who didn't pick their songs won't have to hear the same track they just previously heard.