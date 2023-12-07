#if defined _tf2items_stocks_included
#endinput
#endif
#define _tf2items_stocks_included

#include <tf2items>

methodmap TF2Item < Handle {
	public TF2Item(int iFlags) {
		return view_as< TF2Item >(TF2Items_CreateItem(iFlags));
	}
	///////////////////////////////
	
	property int iFlags {
		public get() {
			return TF2Items_GetFlags(this);
		}
		public set(int iVal) {
			TF2Items_SetFlags(this, iVal);
		}
	}
	property int iItemIndex {
		public get() {
			return TF2Items_GetItemIndex(this);
		}
		public set(int iVal) {
			TF2Items_SetItemIndex(this, iVal);
		}
	}
	property int iQuality   {
		public get() {
			return TF2Items_GetQuality(this);
		}
		public set(int iVal) {
			TF2Items_SetQuality(this, iVal);
		}
	}
	property int iLevel {
		public get() {
			return TF2Items_GetLevel(this);
		}
		public set(int iVal) {
			TF2Items_SetLevel(this, iVal);
		}
	}
	property int iNumAttribs {
		public get() {
			return TF2Items_GetNumAttributes(this);
		}
		public set(int iVal) {
			TF2Items_SetNumAttributes(this, iVal);
		}
	}
	///////////////////////////////

	public int GiveNamedItem(int iClient) {
		return TF2Items_GiveNamedItem(iClient, this);
	}
	public void SetClassname(char[] strClassName) {
		TF2Items_SetClassname(this, strClassName);
	}
	public void GetClassname(char[] strDest, int iDestSize) {
		TF2Items_GetClassname(this, strDest, iDestSize);
	}
	public void SetAttribute(int iSlotIndex, int iAttribDefIndex, float flValue) {
		TF2Items_SetAttribute(this, iSlotIndex, iAttribDefIndex, flValue);
	}
	public int GetAttribID(int iSlotIndex) {
		return TF2Items_GetAttributeId(this, iSlotIndex);
	}
	public float GetAttribValue(int iSlotIndex) {
		return TF2Items_GetAttributeValue(this, iSlotIndex);
	}
	/**************************************************************/
};

stock TF2Item TF2Item_PrepareItemHandle(
	TF2Item hItem,
	char[] name       = "",
	int index         = -1,
	const char[] att  = "",
	bool dontpreserve = false
) {
	TF2Item hWeapon = null;
	char weaponAttribsArray[32][32];
	int attribCount = ExplodeString(att, ";", weaponAttribsArray, 32, 32);
	int flags = OVERRIDE_ATTRIBUTES;
	if( !dontpreserve ) {
		flags |= PRESERVE_ATTRIBUTES;
	}
	
	if( !hWeapon ) {
		hWeapon = new TF2Item(flags);
	} else {
		hWeapon.iFlags = flags;
	}
	
	if( hItem != null ) {
		int addattribs = hItem.iNumAttribs;
		if( addattribs ) {
			for( int i; i < 2 * addattribs; i += 2 ) {
				bool dontAdd = false;
				int attribIndex = hItem.GetAttribID(i);
				for( int z; z < attribCount+i; z += 2 ) {
					if( StringToInt(weaponAttribsArray[z])==attribIndex ) {
						dontAdd = true;
						break;
					}
				}
				if( !dontAdd ) {
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(hItem.GetAttribValue(i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount += 2 * addattribs;
		}
		delete hItem;
	}
	
	if( name[0] != '\0' ) {
		flags |= OVERRIDE_CLASSNAME;
		hWeapon.SetClassname(name);
	}
	if( index != -1 ) {
		flags |= OVERRIDE_ITEM_DEF;
		hWeapon.iItemIndex = index;
	}
	if( attribCount > 0 ) {
		hWeapon.iNumAttribs = (attribCount/2);
		for( int i, att_index; i < attribCount && i < 32; i += 2, att_index++ ) {
			int attrib = StringToInt(weaponAttribsArray[i]);
			if( !attrib ) {
				continue;
			} else if( att_index >= 16 ) {
				LogError("TF2Item_PrepareItemHandle ERROR :: **** attribute '%s' exceeds attributes limit. ****", weaponAttribsArray[i]);
				continue;
			}
			
			hWeapon.SetAttribute(att_index, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
		}
	} else {
		hWeapon.iNumAttribs = 0;
	}
	hWeapon.iFlags = flags;
	return hWeapon;
}
