extends Area3D

const SPEED = 55.0
const RANGE = 40.0
const DAMAGE = 5

var travelled_distance = 0.0

func _physics_process(delta):
	position += -transform.basis.z * SPEED * delta
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body):
	queue_free()
	if body.has_method("hit"):
		body.hit(DAMAGE)
