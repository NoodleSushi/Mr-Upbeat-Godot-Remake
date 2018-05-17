tool
extends Node2D
enum TYPE {ROUND, FLOOR, CEIL}
enum SWITCH {DISABLE,INTEGER,FLOAT,NAME}
export(SWITCH) var Switch_Type = SWITCH.INTEGER setget Switch_Change
export(int) var Set_Integer = 0 setget Integer_Change
export(float) var Set_Float = -1.0 setget Float_Change
export(String) var Set_Name = "" setget Str_Change
export(TYPE) var Float_Type = TYPE.ROUND setget Type_Change

func Integer_Change(value):
	if Switch_Type == SWITCH.INTEGER:
		var i = -1
		var children = get_children()
		var final = clamp(value,0,children.size())
		for k in children:
			i += 1
			k.set_visible(i == final-1)
		Set_Integer = final

func Str_Change(value):
	if Switch_Type == SWITCH.NAME:
		for k in get_children():
			k.set_visible(k.get_name()==value)
		Set_Name = value

func Float_Change(value):
	if Switch_Type == SWITCH.FLOAT:
		var i = -1
		var children = get_children()
		var final = int(Float_Type==TYPE.ROUND)*round(value)+int(Float_Type==TYPE.FLOOR)*floor(value)+int(Float_Type==TYPE.CEIL)*ceil(value)
		final = clamp(final,-1.0,children.size()-1)
		for k in children:
			i += 1
			k.set_visible(i == final)
		Set_Float = clamp(value,-1.0,children.size())

func Type_Change(value):
	Float_Type = value
	Float_Change(Set_Float)

func Switch_Change(value):
	Switch_Type = value
	match value:
		SWITCH.INTEGER:
			Integer_Change(Set_Integer)
		SWITCH.FLOAT:
			Float_Change(Set_Float)
		SWITCH.NAME:
			Str_Change(Set_Name)
		SWITCH.DISABLE:
			for k in get_children():
				k.set_visible(true)

func _enter_tree():
	pass