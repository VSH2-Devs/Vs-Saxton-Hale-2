methodmap PrivateForward < Handle	//very useful ^^
{
	public PrivateForward( const Handle forw )
	{
		if (forw != null)
			return view_as<PrivateForward>( forw );
		return null;
	}
	property int FuncCount
	{
		public get()	{ return GetForwardFunctionCount(this); }
	}
	public bool Add(Handle plugin, Function func)
	{
		return AddToForward(this, plugin, func);
	}
	public bool Remove(Handle plugin, Function func)
	{
		return RemoveFromForward(this, plugin, func);
	}
	public int RemoveAll(Handle plugin)
	{
		return RemoveAllFromForward(this, plugin);
	}
	public void Start()
	{
		Call_StartForward(this);
	}
};

PrivateForward
	g_hForwards[VSH2HookType]	// I'm assuming this makes it the total size of the last value in the enum?
;

public void InitializedForwards()
{
	
}
