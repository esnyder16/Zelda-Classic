///////////////////////////////////////////////////////////////////////////////
//~~~~~~~~~~~~~~~~~~~The Terror of Necromancy Misc Functions~~~~~~~~~~~~~~~~~//
///////////////////////////////////////////////////////////////////////////////

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Misc Functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//start
// Function to get the difference between two angles
float AngDiff(float angle1, float angle2) //start
{
	// Get the difference between the two angles
	float dif = angle2 - angle1;
	
	// Compensate for the difference being outside of normal bounds
	if(dif >= 180)
		dif -= 360;
	else if(dif <= -180)
		dif += 360;
		
	return dif;
}
//end

// Function to turn one angle towards another angle by a fixed amount
float TurnToAngle(float angle1, float angle2, float step) //start
{
	if(Abs(AngDiff(angle1, angle2)) > step)
		return angle1 + Sign(AngDiff(angle1, angle2)) * step;
	else
		return angle2;
}
//end

// Function to set Screen->D
void setScreenD(int reg, bool state) //start
{
	#option BINARY_32BIT on
	
	int d = Div(reg, 32);
	reg %= 32;
	
	if (state)
		Screen->D[d] |= 1b<<reg;
	else
		Screen->D[d] ~= 1b<<reg;
	
}
//end

// Function to get Screen->D
bool getScreenD(int reg) //start
{
	#option BINARY_32BIT on
	
	int d = Div(reg, 32);
	reg %= 32;
	
	return Screen->D[d] & (1b<<reg);
	
}
//end

// Function to set Screen->D
void setScreenD(int d, int bit, bool state) //start
{
	#option BINARY_32BIT on
	
	if (state)
		Screen->D[d] |= bit;
	else
		Screen->D[d] ~= bit;
}
//end

// Function to get Screen->D
int getScreenD(int d, int bit) //start
{
	#option BINARY_32BIT on
	
	return Screen->D[d] & bit;
}
//end

// Converts an 18 bit value to a 32 bit value
int convertBit(int b18) //start
{
	return b18 / 10000;
}//end

// Determines that dmap type you are on
ScreenType getScreenType()//start
{
	dmapdata dm = Game->LoadDMapData(Game->GetCurDMap());
	if(IsDungeonFlag())return DM_DUNGEON;
	if(IsInteriorFlag())return DM_INTERIOR;
	return <ScreenType> (dm->Type & 11b);
}//end

//end