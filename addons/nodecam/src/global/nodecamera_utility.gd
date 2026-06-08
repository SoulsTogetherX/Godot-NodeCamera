class_name NodeCameraUtility
## A global class for general [NodeCameraState] methods.


#region Camera3D Methods
## Returns the viewport expected size in 3D space.
static func get_3D_viewport_size(target: NodeCamera3DState) -> Vector2:
	return target.camera.get_viewport().get_visible_rect().size
## Returns the viewport expected size in 2D space, not including zoom.
static func get_2D_unzoomed_viewport_size(target: NodeCamera2DState) -> Vector2:
	return target.camera.get_viewport().get_visible_rect().size
## Returns the viewport expected size in 2D space.
static func get_2D_viewport_size(target: NodeCamera2DState) -> Vector2:
	return get_2D_unzoomed_viewport_size(target) / target.zoom.abs()

## Returns a 3D camera's expected transform, including offset
static func get_3D_camera_transform(
	target: NodeCamera3DState
) -> Transform3D:
	var tr := target.transform.orthonormalized()
	tr.origin += tr.basis.y * target.v_offset
	tr.origin += tr.basis.x * target.h_offset
	return tr
## Returns a 2D camera's expected transform, including offset
static func get_2D_camera_transform(
	target: NodeCamera3DState
) -> Transform3D:
	var tr := target.transform.orthonormalized()
	tr.origin += tr.basis.y * target.v_offset
	tr.origin += tr.basis.x * target.h_offset
	return tr

## See [method Camer3D.get_camera_projection].
static func get_camera_projection(
	target: NodeCamera3DState
) -> Projection:
	var viewport_size := get_3D_viewport_size(target)
	var aspect := 1.0
	if !is_zero_approx(viewport_size.y):
		aspect = viewport_size.x / viewport_size.y
	
	match target.camera.projection:
		Camera3D.PROJECTION_PERSPECTIVE:
			return Projection.create_perspective(
				target.fov, aspect, target.near, target.far,
				target.camera.keep_aspect == Camera3D.KEEP_WIDTH
			)
		Camera3D.PROJECTION_ORTHOGONAL:
			return Projection.create_orthogonal_aspect(
				target.size, aspect, target.near, target.far,
				target.camera.keep_aspect == Camera3D.KEEP_WIDTH
			)
		Camera3D.PROJECTION_FRUSTUM:
			return Projection.create_frustum_aspect(
				target.size, aspect, target.frustum_offset, target.near,
				target.far
			)
		_:
			return Projection()

## See [method Camer3D.is_position_behind].
static func is_position_behind(
	target: NodeCamera3DState, world_point: Vector3
) -> bool:
	var t := target.transform
	var eye_dir := -t.basis.z.normalized()
	return eye_dir.dot(world_point - t.origin) < target.near

## See [method Camer3D.get_frustum].
static func get_frustum(target: NodeCamera3DState) -> Array[Plane]:
	var proj := get_camera_projection(target)
	var cam_xform := get_3D_camera_transform(target)
	
	return [
		cam_xform * proj.get_projection_plane(Projection.PLANE_NEAR),
		cam_xform * proj.get_projection_plane(Projection.PLANE_FAR),
		cam_xform * proj.get_projection_plane(Projection.PLANE_LEFT),
		cam_xform * proj.get_projection_plane(Projection.PLANE_TOP),
		cam_xform * proj.get_projection_plane(Projection.PLANE_RIGHT),
		cam_xform * proj.get_projection_plane(Projection.PLANE_BOTTOM),
	]

## See [method Camer3D.is_position_in_frustum].
static func is_position_in_frustum(
	target: NodeCamera3DState, world_point: Vector3
) -> bool:
	for plane : Plane in get_frustum(target):
		if plane.is_point_over(world_point):
			return false
	return true

## See [method Camer3D.project_ray_normal].
static func project_ray_normal(
	target: NodeCamera3DState, screen_point: Vector2
) -> Vector3:
	return (
		get_3D_camera_transform(target).basis * project_local_ray_normal(target, screen_point)
	).normalized()

## See [method Camer3D.project_local_ray_normal].
static func project_local_ray_normal(
	target: NodeCamera3DState, screen_point: Vector2
) -> Vector3:
	var viewport_size := get_3D_viewport_size(target)
	if is_zero_approx(viewport_size.y):
		return Vector3.ZERO
	
	if target.camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		return Vector3(0.0, 0.0, -1.0)
	
	var proj := get_camera_projection(target)
	var half_extents := proj.get_viewport_half_extents()
	
	var cpos := screen_point
	var ray := Vector3(
		((cpos.x / viewport_size.x) * 2.0 - 1.0) * half_extents.x,
		((1.0 - (cpos.y / viewport_size.y)) * 2.0 - 1.0) * half_extents.y,
		-target.near
	)
	return ray.normalized()

## See [method Camer3D.project_ray_origin].
static func project_ray_origin(
	target: NodeCamera3DState, screen_point: Vector2
) -> Vector3:
	var viewport_size := get_3D_viewport_size(target)
	if is_zero_approx(viewport_size.y):
		return Vector3.ZERO
	
	if target.camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		var pos := screen_point / viewport_size
		var hsize : float
		var vsize : float
		
		if target.camera.keep_aspect == Camera3D.KEEP_WIDTH:
			vsize = target.size / (viewport_size.x / viewport_size.y)
			hsize = target.size
		else:
			hsize = target.size * (viewport_size.x / viewport_size.y)
			vsize = target.size
		
		var ray := Vector3(
			pos.x * hsize - (hsize * 0.5),
			(1.0 - pos.y) * vsize - (vsize * 0.5),
			-target.near
		)
		return get_3D_camera_transform(target) * ray
	return get_3D_camera_transform(target).origin

## See [method Camer3D.project_position].
static func project_position(
	target: NodeCamera3DState, screen_point: Vector2, z_depth: float
) -> Vector3:
	if (
		is_zero_approx(z_depth) && target.camera.projection != Camera3D.PROJECTION_ORTHOGONAL
	):
		return get_3D_camera_transform(target).origin
	
	var viewport_size := get_3D_viewport_size(target)
	if is_zero_approx(viewport_size.x) || is_zero_approx(viewport_size.y):
		return Vector3.ZERO
	
	var proj := get_camera_projection(target)
	var z_slice := Plane(Vector3(0.0, 0.0, 1.0), -z_depth)
	
	var right_plane := proj.get_projection_plane(Projection.PLANE_RIGHT)
	var top_plane := proj.get_projection_plane(Projection.PLANE_TOP)
	var vp_half_extents_variant := z_slice.intersect_3(
		right_plane, top_plane
	)
	if vp_half_extents_variant == null:
		return get_3D_camera_transform(target).origin
	
	var vp_he: Vector3 = vp_half_extents_variant
	var point := Vector2(
		(screen_point.x / viewport_size.x) * 2.0 - 1.0,
		(1.0 - (screen_point.y / viewport_size.y)) * 2.0 - 1.0
	)
	point *= Vector2(vp_he.x, vp_he.y)
	
	var local_point := Vector3(point.x, point.y, -z_depth)
	return get_3D_camera_transform(target) * local_point

## See [method Camer3D.unproject_position].
static func unproject_position(
	target: NodeCamera3DState, world_point: Vector3
) -> Vector2:
	var viewport_size := get_3D_viewport_size(target)
	if is_zero_approx(viewport_size.x) || is_zero_approx(viewport_size.y):
		return Vector2.ZERO
	
	var cam_xform := get_3D_camera_transform(target)
	var proj := get_camera_projection(target)
	
	var local_point := cam_xform.affine_inverse() * world_point
	var clip := proj * Vector4(
		local_point.x, local_point.y, local_point.z, 1.0
	)
	
	if is_zero_approx(clip.w):
		return Vector2.ZERO
	
	var ndc := Vector3(clip.x, clip.y, clip.z) / clip.w
	return Vector2(
		(ndc.x * 0.5 + 0.5) * viewport_size.x,
		(-ndc.y * 0.5 + 0.5) * viewport_size.y
	)
#endregion


#region Look At
## Takes the current [NodeCamera3DState] and makes it look at a [Vector3].
static func look_at_camera(
	target: NodeCamera3DState, look_at_point: Vector3, up: Vector3 = Vector3.UP
) -> void:
	var origin := target.global_position
	var z_axis := (origin - look_at_point).normalized()
	if z_axis.is_zero_approx():
		return

	var x_axis := up.cross(z_axis)
	if x_axis.length_squared() < 0.000001:
		# Fallback if up is parallel to view direction.
		var fallback_up := Vector3.RIGHT if abs(z_axis.dot(Vector3.UP)) > 0.999 else Vector3.UP
		x_axis = fallback_up.cross(z_axis)

	x_axis = x_axis.normalized()
	var y_axis := z_axis.cross(x_axis).normalized()

	target.transform = Transform3D(Basis(x_axis, y_axis, z_axis), origin)
#endregion


#region Framed
## Returns moves the given [NodeCamera2DState] within a deadzone box.
static func frame_camera_2D(
	target : NodeCamera2DState, global_pos : Vector2,
	dead_zone : Vector2
) -> void:
	var cam : Camera2D = target.get_camera()
	var viewport_target_offset := Vector2.ZERO
	var view_size : Vector2 = get_2D_viewport_size(target)
	
	## Dead Zone
	var viewport_dead_zone := Vector2(
		view_size.x * dead_zone.x, view_size.y * dead_zone.y
	) * 0.5
	var dead_zone_rect := Vector4(
		cam.global_position.x - viewport_dead_zone.x,
		cam.global_position.x + viewport_dead_zone.x,
		cam.global_position.y - viewport_dead_zone.y,
		cam.global_position.y + viewport_dead_zone.y,
	)
	
	## Horizontal Dead Zone
	if dead_zone_rect.x > global_pos.x:
		viewport_target_offset.x = dead_zone_rect.x - global_pos.x
	elif dead_zone_rect.y < global_pos.x:
		viewport_target_offset.x = dead_zone_rect.y - global_pos.x
	
	## Vertical Dead Zone
	if dead_zone_rect.z > global_pos.y:
		viewport_target_offset.y = dead_zone_rect.z - global_pos.y
	elif dead_zone_rect.w < global_pos.y:
		viewport_target_offset.y = dead_zone_rect.w - global_pos.y
	
	target.global_position -= viewport_target_offset
## Returns moves the given [NodeCamera3DState] within a deadzone box.
static func frame_camera_3D(
	target : NodeCamera3DState, global_pos : Vector3,
	normal : Vector3, dead_zone : Vector2
) -> void:
	var cam: Camera3D = target.get_camera()
	var screen_pos: Vector2 = unproject_position(target, global_pos)
	var view_size: Vector2 = get_3D_viewport_size(target)
	var viewport_target_offset := Vector2.ZERO
	
	## Dead Zone
	var viewport_dead_zone := Vector2(
		view_size.x * (1.0 - dead_zone.x),
		view_size.y * (1.0 - dead_zone.y)
	) * 0.5
	var dead_zone_rect := Vector4(
		viewport_dead_zone.x,
		view_size.x - viewport_dead_zone.x,
		viewport_dead_zone.y,
		view_size.y - viewport_dead_zone.y,
	)
	
	## Horizontal Dead Zone
	if dead_zone_rect.x > screen_pos.x:
		viewport_target_offset.x = dead_zone_rect.x - screen_pos.x
	elif dead_zone_rect.y < screen_pos.x:
		viewport_target_offset.x = dead_zone_rect.y - screen_pos.x
	
	## Vertical Dead Zone
	if dead_zone_rect.z > screen_pos.y:
		viewport_target_offset.y = dead_zone_rect.z - screen_pos.y
	elif dead_zone_rect.w < screen_pos.y:
		viewport_target_offset.y = dead_zone_rect.w - screen_pos.y
	
	screen_pos +=  viewport_target_offset
	
	var origin := project_ray_origin(target, screen_pos)
	var direction := project_ray_normal(target, screen_pos)
	var dot := normal.dot(direction)
	if is_zero_approx(dot):
		return
	
	var distance := normal.dot(global_pos - origin) / dot
	var intersection := origin + direction * distance
	if global_pos.is_equal_approx(intersection):
		return
	
	target.global_position += (global_pos - intersection)
#endregion
