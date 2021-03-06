///////////////////////////////////////////////////////////////////////////////
//~~~~~~~~~~~~~~~~~~~~The Terror of Necromancy FFC Scripts~~~~~~~~~~~~~~~~~~~//
///////////////////////////////////////////////////////////////////////////////

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Free Form Combos~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//~~~~~Constants/globals~~~~~//
//start
const int COMPASS_BEEP = 69; //Set this to the SFX id you want to hear when you have the compass,

const int COMPASS_SFX = 20; 			//Set this to the SFX id you want to hear when you have the compass.

CONFIG CB_SIGNPOST = CB_A;				//Button to press to read a sign

const int SFX_SWITCH_PRESS = 0; 		//SFX when a switch is pressed
const int SFX_SWITCH_RELEASE = 0; 		//SFX when a switch is released
const int SFX_SWITCH_ERROR = 62; 		//SFX when the wrong switch is pressed

const int ICE_BLOCK_SCRIPT = 1; 		// Slot number that the ice_block script is assigned to
const int ICE_BLOCK_SENSITIVITY = 8; 	// Number of frames the blocks need to be pushed against to begin moving

const int D_DEATHS = 0;
const int MSG_LINK_BEATEN = 23;

bool levelEntries[512]; 

//end

//~~~~~VoiceOverText~~~~~//
//D0: Starting message
//D1: Number of strings in sequence
@Author("Deathrider365")
ffc script VoiceOverText //start
{	
	void run(int msg, int numStrings)
	{
		for (int i = 0; i < numStrings; ++i)
		{
			Audio->PlaySound(" ");
			Screen->Message(msg + i);
		}

	}
} //end

//~~~~~SwitchPressed (used for switch scripts)~~~~~//
int SwitchPressed(int x, int y, bool noLink) //start
{
	int xOff = 0;
	int yOff = 4;
	int xDist = 8;
	int yDist = 8;
	if(Abs(Link->X+xOff-x)<=xDist&&Abs(Link->Y+yOff-y)<=yDist&&Link->Z==0&&!noLink)
		return 1;
	if(Screen->MovingBlockX>-1){
		if(Abs(Screen->MovingBlockX-x)<=8&&Abs(Screen->MovingBlockY-y)<=8)
			return 1;
	}
	if(Screen->isSolid(x+4, y+4)||
		Screen->isSolid(x+12, y+4)||
		Screen->isSolid(x+4, y+12)||
		Screen->isSolid(x+12, y+12)){
		return 2;
	}
	return 0;
}
//end

//~~~~~BossNameString~~~~~//
//D0: String number
@Author("Deathrider365")
ffc script BossNameString //start
{
	void run(int string)
	{
		Waitframes(4);
		if (EnemiesAlive())
			Screen->Message(string);
	}
}

//end

//~~~~~CompassBeep~~~~~//
@Author("Demonlink")
ffc script CompassBeep //start
{
	void run()
	{
		if(!Screen->State[ST_ITEM] && !Screen->State[ST_CHEST] && !Screen->State[ST_LOCKEDCHEST] && !Screen->State[ST_BOSSCHEST] && 
			!Screen->State[ST_SPECIALITEM] && (Game->LItems[Game->GetCurLevel()] & LI_COMPASS))
			Audio->PlaySound(COMPASS_BEEP);
	}
}
//end

//~~~~~OpenForItem~~~~~//
//D0: Item number to check for
//D1: 0 for non-perm, 1 for perm
@Author("Moosh")
ffc script OpenForItemID //start
{
	void run(int itemid, bool perm)
	{
		if(Screen->State[ST_SECRET]) 
			Quit();
		while(true)
		{
			if(Link->Item[itemid])
			{
				Screen->TriggerSecrets();
				
				if(perm) 
					Screen->State[ST_SECRET] = true;
					
				return;
			}
			Waitframe();
		}
	}
}
//end

//~~~~~BossMusic~~~~~//
//D0: Index value 
//D1: 0 for no 1 for yes to fanfare music
@Author("Deathrider365")
ffc script BossMusic //start
{	
	void run(int musicChoice, int isFanfare)
	{
		char32 areaMusic[256];

		if (Screen->State[ST_SECRET])
			Quit();
		
		Waitframes(4);
		
		unless (EnemiesAlive())
			return;
		
		switch(musicChoice)
		{		
			case 1:
				Audio->PlayEnhancedMusic("Middle Boss - OoT.ogg", 0);
				break;
				
			case 2:
				Audio->PlayEnhancedMusic("Metroid Prime - Parasite Queen.ogg", 0);
				break;
				
			case 2:
				Audio->PlayEnhancedMusic("", 0);
				break;
		}
		
		while(EnemiesAlive())
			Waitframe();
			
		if (isFanfare == 1)
		{
			Audio->PlayEnhancedMusic("Boss Fanfare - Wind Waker.ogg", 0);
			Waitframes(1465);
		}

		Game->GetDMapMusicFilename(Game->GetCurDMap(), areaMusic);
		Audio->PlayEnhancedMusic(areaMusic, 0);

	}
}

//end

//~~~~~Leviathan1Cabin~~~~~//
//D0: Number of dmap to play music for
@Author("Deathrider365")
ffc script Leviathan1Cabin //start
{
	void run()
	{
		Audio->PlayEnhancedMusic("WW - Ship Theme.ogg", 0);
	}
}
//end

//~~~~~MessageThenWarp~~~~~//
//D0: Message number to show
//D1: Dmap to warp Link to
//D2: Screen on the specified dmap to warp Link to
@Author("Deathrider365")
ffc script MessageThenWarp //start
{	
	void run(int msg, int dmap, int scr)
	{
		NoAction();
		Link->PressStart = false;
		Link->InputStart = false;
		Link->PressMap = false;
		Link->InputMap = false;
		Screen->Message(msg);
		Waitframe();
		Hero->WarpEx({WT_IWARPBLACKOUT, dmap, scr, -1, WARP_A, WARPFX_NONE, 0, 0, DIR_DOWN});
	}
}
//end

//~~~~~ScreenBeforeLeviathan1~~~~~//
//D0: Message number to show
//D1: Dmap to warp Link to
//D2: Screen on the specified dmap to warp Link to
@Author("Deathrider365")
ffc script ScreenBeforeLeviathan1 //start
{	
	CONFIG SFX_ROCKINGSHIP = 9;
	void run(int msg, int dmap, int scr, int timeUntilWarp)
	{
		Audio->PlayEnhancedMusic("WW - The Great Sea.ogg", 0);
		int timer = 0;
		while(true)
		{
			++timer;
			Waitframe();
			
			if (timer == timeUntilWarp)
			{
				NoAction();
				Link->PressStart = false;
				Link->InputStart = false;
				Link->PressMap = false;
				Link->InputMap = false;
				Screen->Message(msg);
				Waitframe();
				
				for (int i = 0; i < 240; ++i)
				{
					if(i % 60 == 0)
					{
						Screen->Quake = 20;
						Audio->PlaySound(SFX_ROCKINGSHIP);
					}
					Waitframe();
				}
				
				Screen->Message(msg + 1);
				Waitframe();
				
				Hero->WarpEx({WT_IWARPOPENWIPE, dmap, scr, -1, WARP_A, WARPEFFECT_OPENWIPE, 0, 0, DIR_UP});
				
			}
		}
	}
}
//end

//~~~~~NormalString~~~~~//
//D0: Number of string to show
@Author("Deathrider365")
ffc script NormalString //start
{
	void run(int m, int triggerOnSecret)
	{
		if (triggerOnSecret)
		{
			if (Screen->State[ST_SECRET])
			{
				Waitframes(2);
				Screen->Message(m);
			}
			else
				Waitframe();
		}
		else
		{
			Waitframes(2);
			Screen->Message(m);
		}
	}
}

//end

//~~~~~ItemGuy~~~~~//
//D0: Number of string to show
//D1: Item to be given
//D2: X position of where the item will appear
//D3: Y position of where the item will appear
@Author("Deathrider365")
ffc script ItemGuy //start
{
	void run(int message, int itemID, int x, int y)
	{
		if (Screen->State[ST_SPECIALITEM])
			return;
		
		Waitframes(2);
		itemsprite it = CreateItemAt(itemID, x, y);
		it->Pickup = IP_HOLDUP | IP_ST_SPECIALITEM;
		
		unless(getScreenD(255))
			Screen->Message(message);
		
		setScreenD(255, true);
	}
}

//end

//~~~~~ItemGuySecret~~~~~//
//D0: Number of string to show
//D1: Item to be given
//D2: X position of where the item will appear
//D3: Y position of where the item will appear
@Author("Deathrider365")
ffc script ItemGuySecret //start
{
    void run(int message, int itemID, int x, int y)
    {
        while (true)
        {
            if (Screen->State[ST_SPECIALITEM])
                return;
            
            if (Screen->State[ST_SECRET])
            {
                Waitframes(2);
                itemsprite it = CreateItemAt(itemID, x, y);
                it->Pickup = IP_HOLDUP | IP_ST_SPECIALITEM;
				
				unless(getScreenD(255))
					Screen->Message(message);
				
				setScreenD(255, true);
				
                return;
            }
            Waitframe();
        }
    }
}

//end

//~~~~~DungeonString~~~~~//
//D0: Number of string to show
@Author("Deathrider365")
ffc script DungeonString //start
{
	void run(int m)
	{		
		unless (levelEntries[Game->GetCurLevel()])
		{
			levelEntries[Game->GetCurLevel()] = true;
			Waitframes(2);
			Screen->Message(m);		
		}
	}
}

//end

//~~~~~TradeGuy~~~~~//
@Author("Deathrider365")
ffc script TradeGuy //start
{
	void run(int hasItemString, int noItemString, int requiredItem, int obtainedItem)
	{
		if (Hero->Item[requiredItem])
		{
			Screen->Message(hasItemString);	
			Hero->Item[obtainedItem] = true;
			Hero->Item[requiredItem] = false;
		}
		else
			Screen->Message(noItemString);
	}
}

//end

//~~~~~SignPost~~~~~//
//D0: Number of string to show
//D1: 0 for not anyside 1 for anyside
@Author("Joe123")
ffc script Signpost //start
{
	void run(int msg, bool anySide)
	{
		int loc = ComboAt(this->X, this->Y);
		
		while(true)
		{
			until(AgainstComboBase(loc, anySide) && Input->Press[CB_SIGNPOST]) 
			{
				if (AgainstComboBase(loc, anySide))
					Screen->FastCombo(7, Link->X - 10, Link->Y - 15, 48, 0, OP_OPAQUE);
					
				Waitframe();
			}			
			
			Input->Button[CB_SIGNPOST] = false;
			Screen->Message(msg);
			Waitframe();
		}
	}
	
	bool AgainstComboBase(int loc, bool anySide) //start
	{
		if(Hero->Z) 
			return false;
			
		if(Hero->BigHitbox && !anySide)
			return (Hero->Dir == DIR_UP && Hero->Y == ComboY(loc) + 16 && Abs(Hero->X-ComboX(loc)) < 8);
		else unless(Hero->BigHitbox||anySide)
			return (Hero->Dir == DIR_UP && Hero->Y == ComboY(loc) + 8 && Abs(Hero->X-ComboX(loc)) < 8);
		else if (Hero->BigHitbox && anySide)
			return ((Hero->Dir == DIR_UP && Hero->Y == ComboY(loc) + 16 && Abs(Hero->X-ComboX(loc)) < 8)
			|| (Hero->Dir == DIR_DOWN && Hero->Y == ComboY(loc) - 16 && Abs(Hero->X-ComboX(loc)) < 8) 
			|| (Hero->Dir == DIR_LEFT && Hero->X == ComboX(loc) + 16 && Abs(Hero->Y-ComboY(loc)) < 8)
			|| (Hero->Dir == DIR_RIGHT && Hero->X == ComboX(loc) - 16 && Abs(Hero->Y-ComboY(loc)) < 8));
		else if (!Hero->BigHitbox && anySide)
			return ((Hero->Dir == DIR_UP && Hero->Y == ComboY(loc) + 8 && Abs(Hero->X-ComboX(loc)) < 8) 
			|| (Hero->Dir == DIR_DOWN && Hero->Y == ComboY(loc) - 16 && Abs(Hero->X-ComboX(loc)) < 8) 
			|| (Hero->Dir == DIR_LEFT && Hero->X == ComboX(loc) + 16 && Abs(Hero->Y-ComboY(loc)) < 8)
			|| (Hero->Dir == DIR_RIGHT && Hero->X == ComboX(loc) - 16 && Abs(Hero->Y-ComboY(loc)) < 8));
		else 
			return false;
	} //end
}

//end

//~~~~~Message~~~~~//
//D0: Number of string to show
@Author("Deathrider365")
ffc script Message //start
{
	void run(int msg)
	{
		unless(getScreenD(255))
			Screen->Message(msg);
		
		setScreenD(255, true);
	}
}

//end

//~~~~~ScriptWeaponTrigger~~~~~//
//D0: The LW_ weapon type to check for (std_constants.zh)
//D1: The screen flag to check for on layer 0. If 0, the FFC itself is the trigger.
//D2: The type of secret it's using:
//		-0: Self only
//		-1: Trigger Secrets (Temp)
//		-2: Trigger Secrets (Perm)
//		-3: Hit All (Temp)
//		-4: Hit All (Perm)
//D3: The combo to set the trigger combo to. If 0, will increase the combo by 1
//D4: The CSet for the trigger combo
//D5: The sound to play when the secret is triggered
@Author("Moosh")
ffc script ScriptWeaponTrigger //start
{
	void run(int weapon_type, int marker_flag, int secret_type, int secret_combo, int secret_cset, int sfx)
	{
		int i; int j; int k;
		if(secret_type==4)
		{ //If a permanent trigger is set
			if(Screen->State[ST_SECRET])
			{
				if(marker_flag==0){ //If the FFC is the trigger
					if(secret_combo>0)
					{
						this->Data = secret_combo;
						this->CSet = secret_cset;
					}
					else
					{
						this->Data++;
					}
				}
				else
				{ //If a combo is the trigger
					for(j=0; j<176; j++)
					{
						if(ComboFI(j, marker_flag))
						{
							if(secret_combo>0)
							{
								Screen->ComboD[j] = secret_combo;
								Screen->ComboC[j] = secret_cset;
								Screen->ComboF[j] = 0;
							}
							else
							{
								Screen->ComboD[j]++;
								Screen->ComboF[j] = 0;
							}
						}
					}
				}
			}
		}
		bool trigger;
		while(!trigger)
		{
			//Cycle through weapons backwards to save the frames
			for(i=Screen->NumLWeapons(); i>=1; i--)
			{
				lweapon l = Screen->LoadLWeapon(i);
				if(l->ID==weapon_type)
				{ //First check if the weapon is the right type
					if(l->CollDetection&&l->DeadState<0)
					{ //Then check if it has collision
						if(marker_flag==0){ //If the FFC is the trigger
							if(Collision(this, l))
							{
								Game->PlaySound(sfx);
								SWT_BounceWeapon(l);
								if(secret_combo>0)
								{ //If a secret combo is specified, change to that
									this->Data = secret_combo;
									this->CSet = secret_cset;
								}
								else{ //Else increase by 1
									this->Data++;
								}
								if(secret_type==0)
								{ //A self only secret quits out here
									Quit();
								}
								else if(secret_type==1||secret_type==2)
								{ //A screen secret trigger breaks the loop
									trigger = true;
								}
								else if(secret_type==3||secret_type==4)
								{ //A hit all trigger breaks the loop
									if(CountFFCsRunning(this->Script)==1)
									{ //Only if it's the last one
										trigger = true;
									}
									else //Otherwise it quits
										Quit();
								}
							}
						}
						else
						{ //If a combo is the trigger
							int flagCount;
							for(j=0; j<176; j++)
							{
								if(ComboFI(j, marker_flag))
								{
									flagCount++;
									int x = l->X+l->HitXOffset;
									int y = l->Y+l->HitYOffset;
									if(RectCollision(ComboX(j), ComboY(j), ComboX(j)+15, ComboY(j)+15, x, y, x+l->HitWidth-1, y+l->HitHeight-1))
									{
										Game->PlaySound(sfx);
										SWT_BounceWeapon(l);
										if(secret_combo>0)
										{ //If a secret combo is specified, change to that
											Screen->ComboD[j] = secret_combo;
											Screen->ComboC[j] = secret_cset;
											Screen->ComboF[j] = 0;
										}
										else
										{ //Else increase by 1
											Screen->ComboD[j]++;
											Screen->ComboF[j] = 0;
										}
										if(secret_type==1||secret_type==2)
										{ //A screen secret triggers secrets
											Screen->TriggerSecrets();
											if(secret_type==2)
												Screen->State[ST_SECRET] = true;
										}
									}
								}
							}
							if(flagCount==0)
							{ //If all triggers are hit and type is 3 or 4, break out of the loop
								if(secret_type==3||secret_type==4)
								{
									trigger = true;
								}
							}
						}
					}
				}
				if(trigger)
					break;
			}
			Waitframe();
		}
		Screen->TriggerSecrets();
		if(secret_type==2||secret_type==4)
			Screen->State[ST_SECRET] = true;
	}
	void SWT_BounceWeapon(lweapon l)
	{
		if(l->ID==LW_BRANG||l->ID==LW_HOOKSHOT)
			l->DeadState = WDS_BOUNCE;
		else if(l->ID==LW_ARROW)
			l->DeadState = WDS_ARROW;
		else if(l->ID==LW_BEAM)
			l->DeadState = WDS_BEAMSHARDS;
	}
}
//end

//~~~~~EnemiesChest~~~~~//
// D0: Flag to trigger 
// D1: Combo to change into
// D2: Whether perm of not
// D3: (used only if perm) ScreenD reg
// D4: CSet
// D5: SFX
@Author("Venrob")
ffc script EnemiesChest //start
{
	void run(int flag, int combo, bool perm, int reg, int cset, int sfx)
	{
		if (perm && getScreenD(reg))
		{
			for (int q = 0; q < 176; ++q)
				if (ComboFI(q, flag))
				{
					Screen->ComboD[q] = combo;
					Screen->ComboC[q] = cset;
				}
			return;
		}
		
		Waitframes(6);
		
		while(EnemiesAlive())
			Waitframe();
			
		if (perm)
			setScreenD(reg, true);
		
		for (int q = 0; q < 176; ++q)
			if (ComboFI(q, flag))
			{
				Screen->ComboD[q] = combo;
				Screen->ComboC[q] = cset;
				Audio->PlaySound(sfx);
			}
	}
}
//end

//~~~~~SwitchSecret~~~~~//
// D0: Set to 1 to make the secret permanent
// D1: Set to the switch's ID if the secret is tiered, 0 otherwise.
// D2: If > 0, specifies a special secret sound. -1 for default, 0 for silent.
ffc script SwitchSecret //start
{
	void run(int perm, int id, int sfx)
	{
		int d;
		int db;
		
		if(id>0)
		{
			d = Floor((id-1)/16);
			db = 1<<((id-1)%16);
		}
		
		if(perm)
		{
			if(id>0)
			{
				if(Screen->D[d]&db)
				{
					this->Data++;
					Screen->TriggerSecrets();
					Quit();
				}
			}
			else if(Screen->State[ST_SECRET])
			{
				this->Data++;
				Quit();
			}
		}
		while(!SwitchPressed(this->X, this->Y, false)){
			Waitframe();
		}
		this->Data++;
		Screen->TriggerSecrets();
		Game->PlaySound(SFX_SWITCH_PRESS);
		if(sfx>0)
			Game->PlaySound(sfx);
		else if (sfx == -1)
			Game->PlaySound(SFX_SECRET);
		if(perm){
			if(id>0)
				Screen->D[d]|=db;
			else
				Screen->State[ST_SECRET] = true;
		}
	}
} //end

//~~~~~SwitchRemote~~~~~//
// D0: Set to 1 to make the switch a pressure switch (a block or Link must stay on it to keep it triggered). Set to 2 to make it a pressure switch that only reacts to push blocks.
// D1: Set to the switch's ID. 0 if the secret is temporary or the switch is pressure triggered.
// D2: Set to the flag that specifies the region for the remote secret.
// D3: If > 0, specifies a special secret sound. -1 for default, 0 for silent.
// D4 (2.55 version only): Specifies the layer for the remote secret.
ffc script SwitchRemote //start
{ 
	void run(int pressure, int id, int flag, int sfx){
		bool noLink;
		if(pressure==2){
			pressure = 1;
			noLink = true;
		}
		
		int data = this->Data;
		int i; int j; int k;
		int d;
		int db;
		if(id>0){
			d = Floor((id-1)/16);
			db = 1<<((id-1)%16);
		}
		int comboD[176];
		for(i=0; i<176; i++){
			if(Screen->ComboF[i]==flag){
				comboD[i] = Screen->ComboD[i];
				Screen->ComboF[i] = 0;
			}
		}
		if(id>0){
			if(Screen->D[d]&db){
				this->Data = data+1;
				for(i=0; i<176; i++){
					if(comboD[i]>0){
						Screen->ComboD[i] = comboD[i]+1;
					}
				}
				Quit();
			}
		}
		if(pressure){
			while(true){
				while(!SwitchPressed(this->X, this->Y, noLink)){
					Waitframe();
				}
				this->Data = data+1;
				Game->PlaySound(SFX_SWITCH_PRESS);
				for(i=0; i<176; i++){
					if(comboD[i]>0){
						Screen->ComboD[i] = comboD[i]+1;
					}
				}
				while(SwitchPressed(this->X, this->Y, noLink)){
					Waitframe();
				}
				this->Data = data;
				Game->PlaySound(SFX_SWITCH_RELEASE);
				for(i=0; i<176; i++){
					if(comboD[i]>0){
						Screen->ComboD[i] = comboD[i];
					}
				}
			}
		}
		else{
			while(!SwitchPressed(this->X, this->Y, noLink)){
				Waitframe();
			}
			this->Data = data+1;
			Game->PlaySound(SFX_SWITCH_PRESS);
			if(sfx>0)
				Game->PlaySound(sfx);
			else if (sfx == -1)
				Game->PlaySound(SFX_SECRET);
			for(i=0; i<176; i++){
				if(comboD[i]>0){
					Screen->ComboD[i] = comboD[i]+1;
				}
			}
			if(id>0){
				Screen->D[d] |= db;
			}
		}
	}
} //end

//~~~~~SwitchHitAll~~~~~//
// D0: Set this to the combo number used for the unpressed switches.
// D1: Set to 1 to make the switch a pressure switch (a block or Link must stay on it to keep it triggered). Set to 2 to make it a pressure switch that only reacts to push blocks.
// D2: Set to 1 to make the secret that's triggered permanent.
// D3: Set to the controller's ID. Set to 0 if the switch is temporary or you're using screen secrets.
// D4: Set to the flag that specifies the region for the remote secret. If you're using screen secrets instead of remote ones, this can be ignored.
// D5: If > 0, specifies a special secret sound. -1 for default, 0 for silent.
// D6: If you want the script to remember which switches were pressed after leaving the screen, set to the starting ID for the group of switches. This will reference this ID as well as the next n-1 ID's after that where n is the number of switches in the group. Be careful to thoroughly test that this doesn't bleed into other switch ID's or Screen->D used by other scripts. If you don't want to save the switches' states or the switches are pressure switches, this should be 0.
// D7 (2.55 version only): Specifies the layer for the remote secret. Switch combos themselves must still be placed on layer 0.
ffc script SwitchHitAll //start
{
	void run(int switchCmb, int pressure, int perm, int id, int flag, int sfx, int switchID){
		bool noLink;
		if(pressure==2){
			pressure = 1;
			noLink = true;
		}
		
		int i; int j; int k;
		int d;
		int db;
		if(flag==0)
			id = 0;
		int comboD[176];
		if(id>0){
			d = Floor((id-1)/16);
			db = 1<<((id-1)%16);
			for(i=0; i<176; i++){
				if(Screen->ComboF[i]==flag){
					comboD[i] = Screen->ComboD[i];
					Screen->ComboF[i] = 0;
				}
			}
		}
		int switches[34];
		int switchD[34];
		int switchDB[34];
		switchD[0] = switchID;
		bool switchesPressed[34];
		k = SizeOfArray(switches)-2;
		for(i=0; i<176&&switches[0]<k; i++){
			if(Screen->ComboD[i]==switchCmb){
				j = 2+switches[0];
				switches[j] = i;
				if(!pressure&&switchID>0){
					switchD[j] = Floor((switchID+switches[0]-1)/16);
					switchDB[j] = 1<<((switchID+switches[0]-1)%16);
					if(Screen->D[switchD[j]]&switchDB[j]){
						switchesPressed[j] = true;
						Screen->ComboD[i] = switchCmb+1;
						switches[1]++;
					}
				}
				switches[0]++;
			}
		}
		if(perm){
			if(id>0){
				if(Screen->D[d]&db){
					for(i=2; i<switches[0]+2; i++){
						Screen->ComboD[switches[i]] = switchCmb+1;
						switchesPressed[i] = true;
					}
					for(i=0; i<176; i++){
						if(comboD[i]>0){
							Screen->ComboD[i] = comboD[i]+1;
						}
					}
					while(true){
						Switches_Update(switches, switchD, switchDB, switchesPressed, switchCmb, false, noLink);
						Waitframe();
					}
				}
			}
			else if(Screen->State[ST_SECRET]){
				for(i=2; i<switches[0]+2; i++){
					Screen->ComboD[switches[i]] = switchCmb+1;
					switchesPressed[i] = true;
				}
				while(true){
					Switches_Update(switches, switchD, switchDB, switchesPressed, switchCmb, false, noLink);
					Waitframe();
				}
			}
		}
		if(pressure){
			while(switches[1]<switches[0]){
				Switches_Update(switches, switchD, switchDB, switchesPressed, switchCmb, true, noLink);
				Waitframe();
			}
			if(id>0){
				if(sfx>0)
					Game->PlaySound(sfx);
				else if (sfx == -1)
					Game->PlaySound(SFX_SECRET);
				for(i=0; i<176; i++){
					if(comboD[i]>0){
						Screen->ComboD[i] = comboD[i]+1;
					}
				}
			}
			else{
				if(sfx>0)
					Game->PlaySound(sfx);
				else if (sfx == -1)
					Game->PlaySound(SFX_SECRET);
				Screen->TriggerSecrets();
			}
			if(perm){
				if(id>0)
					Screen->D[d] |= db;
				else
					Screen->State[ST_SECRET] = true;
			}
		}
		else{
			while(switches[1]<switches[0]){
				Switches_Update(switches, switchD, switchDB, switchesPressed, switchCmb, false, noLink);
				Waitframe();
			}
			if(id>0){
				if(sfx>0)
					Game->PlaySound(sfx);
				else if (sfx == -1)
					Game->PlaySound(SFX_SECRET);
				for(i=0; i<176; i++){
					if(comboD[i]>0){
						Screen->ComboD[i] = comboD[i]+1;
					}
				}
			}
			else{
				if(sfx>0)
					Game->PlaySound(sfx);
				else
					Game->PlaySound(SFX_SECRET);
				Screen->TriggerSecrets();
			}
			if(perm){
				if(id>0)
					Screen->D[d] |= db;
				else
					Screen->State[ST_SECRET] = true;
			}
		}
		while(true){
			Switches_Update(switches, switchD, switchDB, switchesPressed, switchCmb, false, noLink);
			Waitframe();
		}
	}
	void Switches_Update(int switches, int switchD, int switchDB, bool switchesPressed, int switchCmb, bool pressure, bool noLink){
		if(pressure)
			switches[1] = 0;
		for(int i=0; i<switches[0]; i++){
			int j = i+2;
			int k = switches[j];
			int p = SwitchPressed(ComboX(k), ComboY(k), noLink);
			if(p){
				if(p!=2)
					Screen->ComboD[k] = switchCmb+1;
				if(!switchesPressed[j]){
					Audio->PlaySound(SFX_SWITCH_PRESS);
					if(switchD[0]>0){
						Screen->D[switchD[j]] |= switchDB[j];
					}
					switchesPressed[j] = true;
					if(!pressure)
						switches[1]++;
				}
				if(pressure)
					switches[1]++;
			}
			else{
				if(switchesPressed[j]){
					if(pressure){
						Audio->PlaySound(SFX_SWITCH_RELEASE);
						Screen->ComboD[k] = switchCmb;
						switchesPressed[j] = false;
					}
					else{
						if(Screen->ComboD[k]!=switchCmb+1)
							Screen->ComboD[k] = switchCmb+1;
					}
				}
			}
		}
	}
} //end

//~~~~~SwitchTrap~~~~~//
// D0: Set to the ID of the enemy to drop in
// D1: Set to the number of enemies to drop
ffc script SwitchTrap //start
{ 
	void run(int enemyid, int count){
		while(!SwitchPressed(this->X, this->Y, false)){
			Waitframe();
		}
		this->Data++;
		Game->PlaySound(SFX_SWITCH_PRESS);
		Game->PlaySound(SFX_SWITCH_ERROR);
		for(int i=0; i<count; i++){
			int pos = Switch_GetSpawnPos();
			npc n = CreateNPCAt(enemyid, ComboX(pos), ComboY(pos));
			Game->PlaySound(SFX_FALL);
			n->Z = 176;
			Waitframes(20);
		}
	}
	int Switch_GetSpawnPos(){
		int pos;
		bool invalid = true;
		int failSafe = 0;
		while(invalid&&failSafe<512){
			pos = Rand(176);
			if(Switch_ValidSpawn(pos))
				return pos;
		}
		for(int i=0; i<176; i++){
			pos = i;
			if(Switch_ValidSpawn(pos))
				return pos;
		}
	}
	bool Switch_ValidSpawn(int pos){
		int x = ComboX(pos);
		int y = ComboY(pos);
		if(Screen->isSolid(x+4, y+4)||
			Screen->isSolid(x+12, y+4)||
			Screen->isSolid(x+4, y+12)||
			Screen->isSolid(x+12, y+12)){
			return false;
		
		}
		if(ComboFI(pos, CF_NOENEMY)||ComboFI(pos, CF_NOGROUNDENEMY))
			return false;
		int ct = Screen->ComboT[pos];
		if(ct==CT_NOENEMY||ct==CT_NOGROUNDENEMY||ct==CT_NOJUMPZONE)
			return false;
		if(ct==CT_WATER||ct==CT_LADDERONLY||ct==CT_HOOKSHOTONLY||ct==CT_LADDERHOOKSHOT)
			return false;
		if(ct==CT_PIT||ct==CT_PITB||ct==CT_PITC||ct==CT_PITD||ct==CT_PITR)
			return false;
		return true;
	}
} //end

//~~~~~SwitchSequential~~~~~//
// D0: Set this to the flag marking all the switches on the screen. The order the switches have to be hit in will be determined by their combo numbers.
// D1: Set to 1 to make the secret that's triggered permanent.
// D2: If > 0, specifies a special secret sound. -1 for default, 0 for silent.
ffc script SwitchSequential //start
{
	void run(int flag, int perm, int sfx){
		int i; int j; int k;
		int switches[34];
		int switchCmb[34];
		int switchMisc[8];
		bool switchesPressed[34];
		k = SizeOfArray(switches)-2;
		for(i=0; i<176&&switches[0]<k; i++){
			if(Screen->ComboF[i]==flag){
				j = 2+switches[0];
				switches[j] = i;
				switchCmb[j] = Screen->ComboD[i];
				switches[0]++;
			}
		}
		int switchOrder[34];
		Switches_Organize(switches, switchOrder);
		if(perm&&Screen->State[ST_SECRET]){
			for(i=0; i<switches[0]; i++){
				switchesPressed[i+2] = true;
			}
			while(true){
				Switches_Update(switches, switchesPressed, switchOrder, switchCmb, switchMisc, false);
				Waitframe();
			}
		}
		while(switches[1]<switches[0]){
			Switches_Update(switches, switchesPressed, switchOrder, switchCmb, switchMisc, true);
			if(switchMisc[0]==1){
				switchMisc[0] = 0;
				for(i=0; i<30; i++){
					Switches_Update(switches, switchesPressed, switchOrder, switchCmb, switchMisc, false);
					Waitframe();
				}
				while(Switches_LinkOn(switches)){
					Switches_Update(switches, switchesPressed, switchOrder, switchCmb, switchMisc, false);
					Waitframe();
				}
			}
			Waitframe();
		}
		if(sfx>0)
			Game->PlaySound(sfx);
		else if (sfx == -1)
			Game->PlaySound(SFX_SECRET);
		Screen->TriggerSecrets();
		if(perm)
			Screen->State[ST_SECRET] = true;
		for(i=0; i<switches[0]; i++){
			switchesPressed[i+2] = true;
		}
		while(true){
			Switches_Update(switches, switchesPressed, switchOrder, switchCmb, switchMisc, false);
			Waitframe();
		}
		
	}
	void Switches_Organize(int switches, int switchOrder){
		bool banned[34];
		for(int j=0; j<switches[0]; j++){
			int lowest = -1;
			int lowestIndex = -1;
			for(int i=0; i<switches[0]; i++){
				int c = Screen->ComboD[switches[i+2]];
				if(c!=-1&&!banned[i+2]){
					if(lowest==-1||c<lowest){
						lowest = c;
						lowestIndex = i+2;
					}
				}
			}
			switchOrder[j] = lowestIndex;
			banned[lowestIndex] = true;
		}
	}
	bool Switches_LinkOn(int switches){
		for(int i=0; i<switches[0]; i++){
			int j = i+2;
			int k = switches[j];
			int p = SwitchPressed(ComboX(k), ComboY(k), false);
			if(p==1)
				return true;
		}
		return false;
	}
	void Switches_Update(int switches, bool switchesPressed, int switchOrder, int switchCmb, int switchMisc, bool canPress){
		bool reset;
		for(int i=0; i<switches[0]; i++){
			int j = i+2;
			int k = switches[j];
			int p = SwitchPressed(ComboX(k), ComboY(k), false);
			if(!switchesPressed[j]){
				if(p!=2)
					Screen->ComboD[k] = switchCmb[j];
				if(p&&canPress){
					if(j==switchOrder[switches[1]]){
						switches[1]++;
						Game->PlaySound(SFX_SWITCH_PRESS);
						switchesPressed[j] = true;
					}
					else{
						switches[1] = 0;
						Game->PlaySound(SFX_SWITCH_ERROR);
						reset = true;
					}
				}
			}
			else{
				if(p!=2)
					Screen->ComboD[k] = switchCmb[j]+1;
				if(p==0&&canPress){
					Game->PlaySound(SFX_SWITCH_RELEASE);
					switchesPressed[j] = false;
				}
			}
		}
		if(reset){
			switchMisc[0] = 1;
			for(int i=0; i<switches[0]; i++){
				int j = i+2;
				int k = switches[j];
				int p = SwitchPressed(ComboX(k), ComboY(k), false);
				switchesPressed[j] = false;
			}
		}
	}
} //end

//~~~~~IceBlock~~~~~//
@Author("Colossal")
ffc script IceBlock //start
{
	void run() 
	{
		int undercombo;
		int framecounter = 0;

		Waitframe();
		undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
		Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;

		while(true) 
		{
			// Check if Link is pushing against the block
			if((Link->X == this->X - 16 && (Link->Y < this->Y + 1 && Link->Y > this->Y - 12) && Link->InputRight && Link->Dir == DIR_RIGHT) || 	// Right
			(Link->X == this->X + 16 && (Link->Y < this->Y + 1 && Link->Y > this->Y - 12) && Link->InputLeft && Link->Dir == DIR_LEFT) || 		// Left
			(Link->Y == this->Y - 16 && (Link->X < this->X + 4 && Link->X > this->X - 4) && Link->InputDown && Link->Dir == DIR_DOWN) || 		// Down
			(Link->Y == this->Y + 8 && (Link->X < this->X + 4 && Link->X > this->X - 4) && Link->InputUp && Link->Dir == DIR_UP)) 				// Up
			{ 			
				framecounter++;
			}
			else 
				framecounter = 0;	// Reset the frame counter
		
			// Once enough frames have passed, move the block
		
			if(framecounter >= ICE_BLOCK_SENSITIVITY) 
			{
				// Check the direction
				if(Link->Dir == DIR_RIGHT) 
				{										// Not at the edge of the screen, Not "No Push Block", // Is walkable
					while(this->X < 240 && !ComboFI(this->X + 16, this->Y, CF_NOBLOCKS) && Screen->ComboS[this->Y + ((this->X + 16) >> 4)] == 0000b) 
					{ 														
						Screen->ComboD[this->Y + (this->X >> 4)] = undercombo;
						this->Vx = 2;
						WaitNoAction(8);
						undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
					}
				
					this->Vx = 0;
					Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;
				}
				else if(Link->Dir == DIR_LEFT) 
				{
					while(this->X > 0 && !ComboFI(this->X - 1, this->Y, CF_NOBLOCKS) && Screen->ComboS[this->Y + ((this->X - 16) >> 4)] == 0000b) 
					{ 															
						Screen->ComboD[this->Y + (this->X >> 4)] = undercombo;
						this->Vx = -2;
						WaitNoAction(8);
						undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
					}
				
					this->Vx = 0;
					Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;
				}
				else if(Link->Dir == DIR_DOWN) 
				{
					while(this->Y < 160 && !ComboFI(this->X, this->Y + 16, CF_NOBLOCKS) && Screen->ComboS[(this->Y + 16) + (this->X >> 4)] == 0000b) 
					{ 															
						Screen->ComboD[this->Y + (this->X >> 4)] = undercombo;
						this->Vy = 2;
						WaitNoAction(8);
						undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
					}
				
					this->Vy = 0;
					Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;
				}
				else if(Link->Dir == DIR_UP) 
				{
					while(this->Y > 0 && !ComboFI(this->X, this->Y - 1, CF_NOBLOCKS) && Screen->ComboS[(this->Y - 16) + (this->X >> 4)] == 0000b) 
					{ 														
						Screen->ComboD[this->Y + (this->X >> 4)] = undercombo;
						this->Vy = -2;
						WaitNoAction(8);
						undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
					}
				
					this->Vy = 0;
					Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;
				}
			
				framecounter = 0;		// Reset the frame counter
			}		
		}
		
		Waitframe();
	}
}
//end

//~~~~~IceTrigger~~~~~//
@Author("Colossal")
ffc script IceTrigger //start
{
	void run() 
	{
		ffc blocks[31];
		int triggerx[31];
		int triggery[31];
		int num_ice_blocks = 0;
		int num_triggers = 0;
		int good_counter = 0;

		for(int i = 0; i < 176 && num_triggers < 31; i++) 
		{
			if(Screen->ComboF[i] == CF_BLOCKTRIGGER || Screen->ComboI[i] == CF_BLOCKTRIGGER) 
			{
				triggerx[num_triggers] = (i % 16) * 16;
				triggery[num_triggers] = Floor(i / 16) * 16;
				num_triggers++;
			}
		}
		
		if(num_triggers == 0) 
			Quit();

		for(int i = 1; i <= 32; i++) 
		{
			ffc temp = Screen->LoadFFC(i);
			
			if(temp->Script == ICE_BLOCK_SCRIPT) 
			{
				blocks[num_ice_blocks] = temp;
				num_ice_blocks++;
			}
		}
		
		if(num_ice_blocks == 0) 
			Quit();

		while(true) 
		{
			for(int i = 0; i < num_ice_blocks; i++) 
			{
				//Check if blocks are on switches and not moving
				for(int j = 0; j < num_triggers; j++) 
				{
					if(blocks[i]->X == triggerx[j] && blocks[i]->Y == triggery[j] && blocks[i]->Vx == 0 && blocks[i]->Vy == 0) 
					{
						good_counter++;
						break;
					}
				}
			}
			
			if(good_counter == num_triggers) 
			{
				Audio->PlaySound(SFX_SECRET);
				Screen->TriggerSecrets();
				if((Screen->Flags[SF_SECRETS] & 2) == 0) Screen->State[ST_SECRET] = true;
					Quit();
			}
			
			good_counter = 0;
			Waitframe();
		}
	}
}
//end

//~~~~~sfxPlay~~~~~//
//D0: The sound effect to play.
//D1: How many frames to wait until the sound effect plays.
//D2: Set this to anything other than 0 to have the sound effect loop.
@Author ("Tabletpillow")
ffc script sfxplay //start
{
	void run(int sound, int wait, int rep)
	{
		if (rep == 0)
		{
			Waitframes(wait);
			Audio->PlaySound(sound);
		}
		else
		{
			while(true)
			{
				Waitframes(wait);
				Audio->PlaySound(sound);
			}
		}
	}
}

//end

//~~~~~BattleArena~~~~~//
//D0: Num of attempts until failure is determined
//D1: Dmap to warp to
//D2: screen to warp to
@Author ("Deathrider365")
ffc script BattleArena //start
{
	void run(int enemyListNum, int roundListNum, int rounds, int message, int prize)
	{	
	/*
		Audio->PlayEnhancedMusic("ToT Miniboss theme.ogg", 0)
		
		int currentEnemyList[10]; 
		getEnemiesList(currentEnemyList, enemyListNum);
		int currentRoundList[10] = getRoundList(roundListNum);
		
		for (int i = 0; i < currentRoundList[rounds]; ++i)
		{
			// npc n1 = Screen->CreateNPC(37);
			// n1->X = 64;
			// n1->Y = 80;		
			
			// npc n2 = Screen->CreateNPC(179);
			// n2->X = 80;
			// n2->Y = 80;
			
			// npc n3 = Screen->CreateNPC(184);		
			// n3->X = 96;
			// n3->Y = 80;
			
			npc i = Screen->CreateNPC(currentEnemyList[i]);
			
			round();
			++round;
		}
		
		Screen->Message(m);
		Hero->Item[prize] = true;
		*/
	}
	/*
	
	void getEnemiesList(int buf, int enemyListNum) //start
	{
		switch(enemyListNum)
		{
			case 1: 
				buf[0] = 12;
				return;
				
			case 1: 
			
			case 1: 
			
			case 1: 
		}

	} //end
	
	int getEnemyList1() //start
	{
		int enemyList1[10];
		enemyList1[0] = 12;
		
		return enemyList1[];
	} //end

	void round() //start
	{
		while(EnemiesAlive())
			Waitframe();
	} //end
	*/
}

//end

//~~~~~LeviathanFailureP1~~~~~//
//D0: Num of attempts until failure is determined
//D1: Dmap to warp to
//D2: screen to warp to
@Author ("Deathrider365")
ffc script LeviathanFailureP1 //start
{
	void run(int numAttempts, int dmap, int scrn)
	{
		while (true)
		{
			if (Hero->HP <= 0)
			{
				++Screen->D[D_DEATHS];
				if (Screen->D[D_DEATHS] < numAttempts)
					Quit();
				else
				{
					Hero->HP = 4;
					Hero->Warp(dmap, scrn);					
				}	
			}
			Waitframe();
		}
	}
}

//end

//~~~~~LeviathanFailureP2~~~~~//
//D0: Dmap to warp to
//D1: screen to warp to
@Author ("Deathrider365")
ffc script LeviathanFailureP2 //start
{
	void run(int dmap, int scrn)
	{
		Screen->Message(MSG_LINK_BEATEN);
		Audio->PlayEnhancedMusic(NULL, 0);

		for (int i = 0; i < 120; ++i)
		{					
			NoAction();
			Screen->DrawTile(0, 50, 32, 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);	
			Waitframe();
		}
		
		Hero->WarpEx({WT_IWARPOPENWIPE, dmap, scrn, -1, WARP_A, WARPEFFECT_OPENWIPE, 0, 0, DIR_UP});
	}
}

//end

//~~~~~Leviathan1Ending~~~~~//
//D0: Dmap to warp to
//D1: screen to warp to
@Author ("Deathrider365")
ffc script Leviathan1Ending //start
{
	using namespace Leviathan;
	
	void run(int dmap, int scrn)
	{
		Audio->PlayEnhancedMusic("Bomb Ring - Final Fantasy IV.ogg", 0);
	
		if (waterfall_bmp && waterfall_bmp->isAllocated())
			waterfall_bmp->Free();
			
		waterfall_bmp = Game->CreateBitmap(32, 176);
		
		Leviathan1.UpdateWaterfallBitmap();
		
		Hero->Dir = DIR_UP;
		NoAction();
		
		Screen->Message(MSG_LINK_BEATEN + 1);
		
		// Buffer
		for (int i = 0; i < 60; ++i)
		{
			NoAction();
			Screen->DrawTile(0, 16, 4, 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);
			Waitframe();			
		}
		
		// Rising
		for (int i = 0; i < 32; ++i)
		{					
			NoAction();
			Screen->DrawTile(0, 16, 4 - (i / 2), 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);			
			Waitframe();
		}
		
		Screen->Message(MSG_LINK_BEATEN + 2);
		
		// Buffer
		for (int i = 0; i < 60; ++i)
		{					
			NoAction();
			Screen->DrawTile(0, 16, -11, 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);
			Waitframe();			
		}
		
		Hero->HP = Hero->MaxHP;
		
		//Falling
		for (int i = 0; i < 32; ++i)
		{					
			NoAction();
			Screen->DrawTile(0, 16, -11 + (i * 2), 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);		
			
			if (i == 10)
			{
				eweapon waterfallLeft = CreateEWeaponAt(EW_SCRIPT10, 76, 64);
				waterfallLeft->Damage = 0;
				waterfallLeft->Script = Game->GetEWeaponScript("Waterfall");
				waterfallLeft->DrawYOffset = -1000;
				waterfallLeft->InitD[0] = 3;
				waterfallLeft->InitD[1] = 64;	
				
				eweapon waterfallRight = CreateEWeaponAt(EW_SCRIPT10, 124, 64);
				waterfallRight->Damage = 0;
				waterfallRight->Script = Game->GetEWeaponScript("Waterfall");
				waterfallRight->DrawYOffset = -1000;
				waterfallRight->InitD[0] = 3;
				waterfallRight->InitD[1] = 64;	
			}
			
			if (i == 31)
			{
				for(int q = 0; q < MAX_ITEMDATA; ++q)
					unless(q == 3 || q == I_DIFF_NORMAL)
						Hero->Item[q] = false;
					
				Game->Counter[CR_SBOMBS] = 0;
				Game->Counter[CR_BOMBS] = 0;
				Game->Counter[CR_ARROWS] = 0;
				Game->Counter[CR_RUPEES] = 0;				

				Game->MCounter[CR_SBOMBS] = 0;
				Game->MCounter[CR_BOMBS] = 0;
				Game->MCounter[CR_ARROWS] = 0;
				Game->MCounter[CR_RUPEES] = 255;
				Game->Generic[GEN_MAGICDRAINRATE] = 2;
				
				Hero->MaxHP = 48;
				Hero->MaxMP = 32;
		
				Hero->HP = Hero->MaxHP;
				Hero->MP = Hero->MaxMP;
		
				Hero->WarpEx({WT_IWARPOPENWIPE, dmap, scrn, -1, WARP_A, WARPEFFECT_OPENWIPE, 0, 0, DIR_UP});	
			}
			
			Waitframe();
		}		
	}
}

//end

//~~~~~PreInteritusCutscene~~~~~//
//D0: Dmap to warp to
//D1: screen to warp to
@Author ("Deathrider365")
ffc script PreInteritusCutscene //start
{
	void run(int reg)
	{
		while(true)
		{
			if (Hero->X == 0 && Hero->Y > 59)
			{
				unless (getScreenD(reg))
				{
					setScreenD(reg, true);
					Hero->WarpEx({WT_IWARPOPENWIPE, 0, 80, -1, WARP_A, WARPEFFECT_OPENWIPE, 0, 0, DIR_UP});
				}
				else
					Hero->WarpEx({WT_IWARPOPENWIPE, 10, 47, -1, WARP_A, WARPEFFECT_OPENWIPE, 0, 0, DIR_LEFT});
			}
			else
				Hero->Action = LA_RAFTING;

			Waitframe();
		}
	}
}

//end

//~~~~~PreInteritusLeviathanScene~~~~~//
//D0: Dmap to warp to
//D1: screen to warp to
@Author ("Deathrider365")
ffc script PreInteritusLeviathanScene //start Have this vary based on whether you defeated the leviathan or not
{
	using namespace Leviathan;
	
	void run()
	{			
		Hero->Item[26] = false;
		NoAction();
		
		Audio->PlayEnhancedMusic(NULL, 0);
		
		for (int i = 0; i < 120; ++i)
		{
			NoAction();
			Screen->FastCombo(2, 240 - i, 128, 6743, 0, OP_OPAQUE);
			Screen->FastCombo(1, 240 - i, 128, 6742, 0, OP_OPAQUE);
			Waitframe();
		}
		
		Audio->PlayEnhancedMusic("Bomb Ring - Final Fantasy IV.ogg", 0);
	
		if (waterfall_bmp && waterfall_bmp->isAllocated())
			waterfall_bmp->Free();
			
		waterfall_bmp = Game->CreateBitmap(32, 176);
		
		Leviathan1.UpdateWaterfallBitmap();
		
		Hero->Dir = DIR_UP;
		NoAction();
		
		// Rising
		for(int i = 0; i < 180; ++i) //start
		{
			NoAction();
			
			Screen->FastCombo(2, 120, 128, 6743, 0, OP_OPAQUE);
			Screen->FastCombo(1, 120, 128, 6742, 0, OP_OPAQUE);
			
			Screen->DrawTile(0, -16, 228 - i, 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);
			Waitframe();
			
			if(i % 40 == 0)
			{
			
				NoAction();
				Audio->PlaySound(SFX_ROCKINGSHIP);
				Screen->Quake = 20;
			}
			
			NoAction();

			Waitframe();
		} //end
		
		//
		//    The leviathan pauses
		//
		for(int i = 0; i < 120; ++i) //start
		{
			NoAction();
			
			Screen->FastCombo(2, 120, 128, 6743, 0, OP_OPAQUE);
			Screen->FastCombo(1, 120, 128, 6742, 0, OP_OPAQUE);
			
			Screen->DrawTile(0, -16, 48, 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);
			Waitframe();
		} //end
		
		Audio->PlaySound(SFX_ROAR);
		Screen->Message(47);
		
		for(int i = 0; i < 120; ++i) //start
		{
			NoAction();
			
			Screen->FastCombo(2, 120, 128, 6743, 0, OP_OPAQUE);
			Screen->FastCombo(1, 120, 128, 6742, 0, OP_OPAQUE);
			
			Screen->DrawTile(0, -16 - 0.125, 48, 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);
			Waitframe();
		} //end

		int x, x2, j, k;
		
		//Charging
		for (int i = 0; i < 128; ++i)
		{				
			NoAction();
			
			if (i < 80)
			{
				Screen->FastCombo(2, 120, 128, 6743, 0, OP_OPAQUE);
				Screen->FastCombo(1, 120, 128, 6742, 0, OP_OPAQUE);
			}
			
			Screen->DrawTile(0, -16 + (i * 2), 48, 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);		
			
			if (i == 10)
			{
				int side = -1;
				
				x = side == -1 ? -32 : 144;
				x2 = x + 32 * side;
				
				for(i = 0; i < 64; ++i)
				{
				
					NoAction();
					Screen->FastCombo(2, 120, 128, 6743, 0, OP_OPAQUE);
					Screen->FastCombo(1, 120, 128, 6742, 0, OP_OPAQUE);
					
					Screen->DrawTile(0, -16 + (i * 2) + 20, 48, 45760, 9, 6, 0, -1, -1, 0, 0, 0, 0, 1, 128);		
					
					this->X -= side * 4;
					this->Y += 0.5;
					
					eweapon waterfall = CreateEWeaponAt(EW_SCRIPT10, this->X + 80, 112);
					waterfall->Damage = 0;
					waterfall->Script = Game->GetEWeaponScript("Waterfall");
					waterfall->DrawYOffset = -1000;
					waterfall->InitD[0] = 1;
					waterfall->InitD[1] = 64 - i * 0.5;
					
					Waitframe();
				}
			}
			
			if (i % 80 == 0)
			   Audio->PlaySound(SFX_ROAR);
			
			if (i == 120)
			{
				Hero->HP = Hero->MaxHP;
				Hero->WarpEx({WT_IWARPOPENWIPE, 2, 96, -1, WARP_A, WARPEFFECT_OPENWIPE, 0, 0, DIR_UP});
			}
			Waitframe();
		}		
	}
}

//end

//~~~~~PostSceneEnteringInteritus~~~~~//
//D0: Dmap to warp to
//D1: screen to warp to
@Author ("Deathrider365")
ffc script PostSceneEnteringInteritus //start
{
	void run()
	{
		while(true)
		{
			if (Hero->X == 240 && Hero->Y == 80)
			{
				Hero->Action = LA_RAFTING;
			}
			Waitframe();
		}
	}
}
//end

//~~~~~EndOfOpeningScene~~~~~//
//D0: Message to play
//D1: Dmap to warp to
//D2: screen to warp to
@Author ("Deathrider365")
ffc script EndOfOpeningScene //start
{
	void run(int msg, int dmap, int scr)
	{
		Audio->PlayEnhancedMusic(NULL, 0);
		NoAction();
		
		for (int i = 0; i < 120; ++i)
		{
			Audio->PlayEnhancedMusic(NULL, 0);
			Waitframe();
		}
		
		Link->PressStart = false;
		Link->InputStart = false;
		Link->PressMap = false;
		Link->InputMap = false;
		Audio->PlayEnhancedMusic(NULL, 0);
		Screen->Message(msg);
		Audio->PlayEnhancedMusic(NULL, 0);
		Waitframe();
		Audio->PlayEnhancedMusic(NULL, 0);
		Hero->WarpEx({WT_IWARPBLACKOUT, dmap, scr, -1, WARP_A, WARPFX_BLACKOUT, 0, 0, DIR_DOWN});
	}
} //end

//~~~~~DifficultyChoice~~~~~//
@Author ("Moosh")
ffc script DifficultyChoice //start
{
    void run()
	{
		Waitframes(60);
		
		while(true)
		{
			if (Input->Press[CB_A])
			{
				Hero->Item[I_DIFF_NORMAL] = true;
				break;
			}
			else if (Input->Press[CB_B])
			{
				Hero->Item[I_DIFF_VERYHARD] = true;
				break;
			}
			
			Waitframe();
		}
		
		Audio->PlaySound(32);
		
		Waitframes(120);
		
		Hero->WarpEx({WT_IWARPOPENWIPE, 5, 0x3E, -1, WARP_B, WARPEFFECT_OPENWIPE, 0, 0, DIR_RIGHT});	
    }
} //end

//~~~~~GiveItem~~~~~//
@Author ("Moosh")
ffc script GiveItem //start
{
	void run()
	{
		Hero->Item[I_DIFF_NORMAL] = true;
	}
}//end

//~~~~~ContinuePoint~~~~~//
@Author ("Venrob")
ffc script ContinuePoint //start
{
	void run(int dmap, int scrn)
	{
		unless (dmap || scrn)
		{
			dmap = Game->GetCurDMap();
			scrn = Game->GetCurScreen();
		}
		
		Game->LastEntranceDMap = dmap;
		Game->LastEntranceScreen = scrn;
		Game->ContinueDMap = dmap;
		Game->ContinueScreen = scrn;
	}
}
//end

//~~~~~Shutter~~~~~//
//D0: Direction when entering the screen
@Author ("Venrob")
ffc script Shutter //start
{
	/*
	Distance(this->X, this->Y, Hero->X, Hero->Y)	//check distance between ffc and link to determine the shutter
	*/
	void run(int direction)
	{
		direction = VBound(direction, 3, 0);	//Param boundary check
		
		if (direction != Hero->Dir)
			return;
		
		for(int i = 0; i < 11; ++i)
		{
			for (int j = 0; j < 4; ++j)
			{
				Input->Button[CB_UP + j] = j == direction;	//j == direction is true
				Input->Press[CB_UP + j] = j == direction;	//j == direction is true
			}
			Waitframe();
		}
	}
}
//end

ffc script CircMove //start
{
	void run(int a, int v, int theta)
	{
		int x = this->X;
		int y = this->Y;
		if(theta < 0) theta = Rand(180);
		while(true)
		{
			theta += v;
			WrapDegrees(theta);
			this->X = x + a * Cos(theta);
			this->Y = y + a * Sin(theta);
			Waitframe();
		}
	}
} //end

ffc script OvMove //start
{
	void run(int a, int b, int v, int theta, int phi)
	{
		int x = this->X;
		int y = this->Y;
		if(theta < 0) theta = Rand(180);
		while(true)
		{
			theta += v;
			WrapDegrees(theta);
			this->X = x + a * Cos(theta) * Cos(phi) - b * Sin(theta) * Sin(phi);
			this->Y = y + b * Sin(theta) * Cos(phi) + a * Cos(theta) * Sin(phi);
			Waitframe();
		}
	}
} //end









