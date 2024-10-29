extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.has_lvl1_key = true
		$"../../Particles".play_particle("collect_key_particle", self.position)
		queue_free()
	pass # Replace with function body.
