extends Node

# The string path in RPG.database
# ex. "Equipment/Weapon/Shortsword", "Item/Potion/HealingPotion"
export( String, MULTILINE ) var database_path = ""

# If true, the item will begin equipped, if it's Equipment
# will equip in slots by the position in parent
# items that can't equip go to the inventory
export( bool ) var start_equipped = true

export( int,0,99 ) var quantity = 1 

# Gear in the same option group will show up as a player option
# The player chooses one piece of gear from the option group
# Leave empty to have the gear in no group, the character will just have it.
export( String ) var option_group = ""


