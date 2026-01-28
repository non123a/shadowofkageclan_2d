extends TextureRect

@export var float_speed := 1.1
@export var float_amount := 3.0

var base_position: Vector2
var time := 0.0

func _ready():
	base_position = position

func _process(delta):
	time += delta * float_speed
	position.y = base_position.y + sin(time) * float_amount
