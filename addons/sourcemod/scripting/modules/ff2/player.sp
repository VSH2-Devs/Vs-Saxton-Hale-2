methodmap FF2Player < VSH2Player {
	property bool Valid {
		public get() {
			return this != INVALID_FF2PLAYER && this.index;
		}
	}

	public FF2Player(const int index, bool userid = false) {
		if( !index ) {
			return ZeroBossToFF2Player();
		}
		return view_as< FF2Player >(VSH2Player(index, userid));
	}

	property FF2Character BossConfig {
		public get() {
			return GetFF2Config(this);
		}
	}

	property int iBossType {
		public get() {
			return this.GetPropInt("iBossType");
		}
	}

	property float flRAGE {
		public get() {
			return this.GetPropFloat("flRAGE");
		}
		public set(const float val) {
			this.SetPropFloat("flRAGE", val);
		}
	}

	property int iLives {
		public get() {
			return this.GetPropInt("iLives");
		}
		public set(const int val) {
			this.SetPropInt("iLives", val);
		}
	}

	property int iMaxLives {
		public get() {
			return this.GetPropInt("iMaxLives");
		}
		public set(const int val) {
			this.SetPropInt("iMaxLives", val);
		}
	}

	property FF2AbilityList HookedAbilities {
		public get() {
			return GetFF2AbilityList(this);
		}
	}

	property bool bNoSuperJump {
		public get() {
			return this.GetPropAny("bNoSuperJump");
		}
		public set(bool state) {
			this.SetPropAny("bNoSuperJump", state);
		}
	}

	property bool bNoWeighdown {
		public get() {
			return this.GetPropAny("bNoWeighdown");
		}
		public set(bool state) {
			this.SetPropAny("bNoWeighdown", state);
		}
	}

	property bool bHideHUD {
		public get() {
			return this.GetPropAny("bHideHUD");
		}
		public set(bool state) {
			this.SetPropAny("bHideHUD", state);
		}
	}

	property float flRageRatio {
		public get() {
			return this.GetPropAny("flRageRatio");
		}
		public set(float val) {
			this.SetPropAny("flRageRatio", val);
		}
	}

	public void PlayBGM(const char[] music) {
		this.PlayMusic(ff2.m_cvars.m_flmusicvol.FloatValue, music);
	}
}

static FF2Character GetFF2Config(FF2Player player)
{
	FF2Identity id;
	return ( ff2_cfgmgr.FindIdentity(player.iBossType, id) ? FF2Character(id.hCfg) : FF2Character(null) );
}

static FF2AbilityList GetFF2AbilityList(FF2Player player)
{
	FF2Identity id;
	return ( ff2_cfgmgr.FindIdentity(player.iBossType, id) ? id.abilityList : null );
}