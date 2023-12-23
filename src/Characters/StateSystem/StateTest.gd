extends State

@export var stat_1 : Status # wrong declaration for the State system
@export var stat_2 : Status = Status.new("stat_2") # appropriate declaration but the exported variable will be redifined by the StatusLogic

var stat_3 : Status # wrong declaration for the State system
var stat_4 : Status = Status.new("stat_4") # appropriate declaration

@export var trig_1 : Trigger # wrong declaration for the State system
@export var trig_2 : Trigger = Trigger.new("trig_2") # appropriate declaration but the exported variable will be redifined by the StatusLogic

var trig_3 : Trigger # wrong declaration for the State system
var trig_4 : Trigger = Trigger.new("trig_4") # appropriate declaration

func _ready():
	print(get_status_requirements()) # print ['stat_2', 'stat_4']
	print(get_trigger_requirements()) # print ['trig_2', 'trig_4']
