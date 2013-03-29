SM_HIGHFIVE_SHENANIGANS
===============
Sourcemod Plugin that shames whoever you use the high-five taunt on.  Also was
a good fix for that high-five exploit that let you get into the enemy's spawn
room but that has been patched.

INSTALLATION:
-------------
Simply compile with the command 

> spcomp highfiveshenanigans.sp

and put the compiled .smx file in your `"<modname>/addons/sourcemod/plugins"`
directory.



USAGE:
------
When on a server with highfiveshenanigans enabled simply high-five someone and let the plugin work it's magic.

To disable the pluging you can set the cvar `sm_highfive_enabled` to 0 

The effect cycles every hour to keep things fresh, but you can force an effect with `sm_highfive_type`

> `sm_highfive_type 0` -> Hourly Cycle
> `sm_highfive_type 1` -> Dissolve Effect 
> `sm_highfive_type 2` -> Decapitation
> `sm_highfive_type 3` -> Turn into a statue
> `sm_highfive_type 4` -> Send flying
> `sm_highfive_type 5` -> Normal Death
