class_name NodeCameraUtility extends Object
## A global class for general [NodeCameraState] methods.

#region Enums
## PreBuilt flags used for Editor Exporting of [enum DIMENSION].
const DIMENSION_FLAGS := "2D:0,3D:1"
## PreBuilt flags used for Editor Exporting of [enum FOLLOW_TYPE_FLAGS]
## within a 2D context.
const FOLLOW_TYPE_2D_FLAGS := "Position:0,Fit:1"
## PreBuilt flags used for Editor Exporting of [enum FOLLOW_TYPE_FLAGS]
## within a 3D context.
const FOLLOW_TYPE_3D_FLAGS := "Position:0,Fit:1,RotateMimic:2,LookAt:3"

## Flags used to decide between the 2D and 3D context variation of a layer.
enum DIMENSION {
	TWO_DIMENSIONAL	= 0,	## Represents 2D context
	THREE_DIMENSIONAL = 1	## Represents 3D context
}
## The mode certain layers use to process a target.
enum FOLLOW_TYPE {
	POSITION = 0,		## Set position to the target's position
	FIT = 1,			## Set zoom/fov/size to fit the target's position on screen
	ROTATE_MIMIC = 2,	## Rotate to look in the same direction of target
	LOOK_AT = 3			## Rotate to look at the target's position
}

## The bitwise flags for [LayerRecord] stages.
## [br][br]
## Stages go in order: [code]STARTING > RUNNING > ENDING > HALTED[/code].
enum LAYER_STAGES {
	HALTED		= 1 << 0,	## [LayerRecord] has finished execution and about to be removed.
	ENDING		= 1 << 1,	## [LayerRecord] has ended execution and is clearing itself up.
	RUNNING		= 1 << 2,	## [LayerRecord] is running its execution.
	STARTING	= 1 << 3,	## [LayerRecord] has started execution and is setting itself up.
}

## A bitmask for all possible properties [NodeCamera2DState]
## and [NodeCamera3DState] objects can have.
enum CAMERA_PROPERTY {
	POSITION		= 1 << 0,			## Position property.
	ROTATION		= 1 << 1,			## Rotation property.
	OFFSET			= 1 << 2,			## Offset property.
	ZOOM			= 1 << 3,			## Zoom Property.
	H_OFFSET		= 1 << 4,			## H_Offset Property.
	V_OFFSET		= 1 << 5,			## V_Offset Property.
	FOV				= 1 << 6,			## FOV Property.
	SIZE			= 1 << 7,			## Size Property.
	FRUSTUM_OFFSET	= 1 << 8,			## Frustum_Offset Property.
	NEAR			= 1 << 9,			## Near Property.
	FAR				= 1 << 10,			## Far Property.
	TRANSFORM		= 1 << 0 | 1 << 1	## Position & Rotation
}
#endregion



#region Camera3D Methods
## Returns the viewport expected size in 3D space.
static func get_3D_viewport_size(target: NodeCamera3DState) -> Vector2:
	return target.camera.get_viewport().get_visible_rect().size
## Returns the viewport expected size in 2D space, not including zoom.
## [br][br]
## Also see [member get_2D_viewport_size].
static func get_2D_unzoomed_viewport_size(target: NodeCamera2DState) -> Vector2:
	return target.camera.get_viewport().get_visible_rect().size
## Returns the viewport expected size in 2D space, including zoom.
## [br][br]
## Also see [member get_2D_viewport_size].
static func get_2D_viewport_size(target: NodeCamera2DState) -> Vector2:
	return get_2D_unzoomed_viewport_size(target) / target.zoom.abs()

## Returns a 3D camera's expected transform, including offset.
static func get_3D_camera_transform(
	target: NodeCamera3DState
) -> Transform3D:
	var tr := target.transform.orthonormalized()
	tr.origin += tr.basis.y * target.v_offset
	tr.origin += tr.basis.x * target.h_offset
	return tr
## Returns a 2D camera's expected transform, including offset.
static func get_2D_camera_transform(
	target: NodeCamera3DState
) -> Transform3D:
	var tr := target.transform.orthonormalized()
	tr.origin += tr.basis.y * target.v_offset
	tr.origin += tr.basis.x * target.h_offset
	return tr

## Implements [method Camera3D.get_camera_projection] for [NodeCamera3DState].
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

## Implements [method Camera3D.is_position_behind] for [NodeCamera3DState].
static func is_position_behind(
	target: NodeCamera3DState, world_point: Vector3
) -> bool:
	var t := target.transform
	var eye_dir := -t.basis.z.normalized()
	return eye_dir.dot(world_point - t.origin) < target.near

## Implements [method Camera3D.get_frustum] for [NodeCamera3DState].
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

## Implements [method Camera3D.is_position_in_frustum] for [NodeCamera3DState].
static func is_position_in_frustum(
	target: NodeCamera3DState, world_point: Vector3
) -> bool:
	for plane : Plane in get_frustum(target):
		if plane.is_point_over(world_point):
			return false
	return true

## Implements [method Camera3D.project_ray_normal] for [NodeCamera3DState].
static func project_ray_normal(
	target: NodeCamera3DState, screen_point: Vector2
) -> Vector3:
	return (
		get_3D_camera_transform(target).basis * project_local_ray_normal(target, screen_point)
	).normalized()

## Implements [method Camera3D.project_local_ray_normal] for [NodeCamera3DState].
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

## Implements [method Camera3D.project_ray_origin] for [NodeCamera3DState].
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

## Implements [method Camera3D.project_position] for [NodeCamera3DState].
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

## Implements [method Camera3D.unproject_position] for [NodeCamera3DState].
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
## Takes the current [NodeCamera3DState] and makes it look at
## position [param look_at_point].
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
		var fallback_up := (
			Vector3.RIGHT if abs(z_axis.dot(Vector3.UP)) > 0.999
			else Vector3.UP
		)
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


#region Zoom
## Changes the [member NodeCamera2DState.zoom] to fit the given position
## [param target_global_pos] in a [Camera2D]'s view.
## [br][br]
## Also see [member fit_camera_to_points_2D].
static func fit_to_point_2D(
	target : NodeCamera2DState,
	target_global_pos: Vector2,
	padding : float = 0.05
) -> void:
	var distance := target.global_position.distance_to(target_global_pos)
	var view_size := target.get_camera().get_viewport_rect().size
	target.zoom = Vector2.ONE * (
		maxf(view_size.x, view_size.y) / (distance * (2.0 + padding))
	)
## Changes the [member NodeCamera2DState.zoom] to fit all given positions
## [param PackedVector2Array] in a [Camera2D]'s view.
## [br][br]
## Also see [member fit_to_point_2D].
static func fit_camera_to_points_2D(
	target : NodeCamera2DState, points: PackedVector2Array,
	padding: float = 0.05
) -> void:
	if points.is_empty():
		return
	
	var max_zoom := 0.0
	for global_point : Vector2 in points:
		var distance := target.global_position.distance_to(global_point)
		var view_size := target.get_camera().get_viewport_rect().size
		max_zoom = maxf(
			max_zoom,
			maxf(view_size.x, view_size.y) / (distance * (2.0 + padding))
		)
	target.zoom = Vector2.ONE * max_zoom


## Changes the [member NodeCamera3DState.fov] or [member NodeCamera3DState.size]
## (depending on [Camera3D.projection]) to fit the given positions
## [param target_global_pos] in a [Camera3D]'s view.
## [br][br]
## Also see [member fit_camera_to_points_3D].
static func fit_to_point_3D(
	target : NodeCamera3DState,
	target_global_pos: Vector3,
	padding : float = 0.05
) -> void:
	var local := target.transform.affine_inverse() * target_global_pos
	if local.z >= 0.0:
		return
	
	var padding_full = padding + 1.0
	var camera := target.camera
	var aspect := get_3D_viewport_size(target).aspect()
	var depth := -local.z
	
	match camera.projection:
		Camera3D.PROJECTION_PERSPECTIVE:
			if camera.keep_aspect == Camera3D.KEEP_HEIGHT:
				var need_v := atan(
					maxf(
						absf(local.y), absf(local.x) / aspect
					) / depth
				) * 2.0
				target.fov = rad_to_deg(need_v) * padding_full
				return
			var need_h := atan(
				maxf(
					absf(local.x), absf(local.y) * aspect
				) / depth
			) * 2.0
			target.fov = clampf(
				rad_to_deg(need_h) * padding_full, 1.0, 179.0
			)

		Camera3D.PROJECTION_ORTHOGONAL:
			if camera.keep_aspect == Camera3D.KEEP_HEIGHT:
				var need_size := maxf(
					absf(local.y), absf(local.x) / aspect
				) * 2.0
				target.size = need_size * padding_full
				return
			var need_size := maxf(
				absf(local.x), absf(local.y) * aspect
			) * 2.0
			target.size = need_size * padding_full
		
		Camera3D.PROJECTION_FRUSTUM:
			if camera.keep_aspect == Camera3D.KEEP_HEIGHT:
				var need_size := maxf(
					absf(local.y) * target.near / depth,
					absf(local.x) * target.near / (depth * aspect)
				) * 2.0
				target.size = maxf(need_size * padding_full, 0.0001)
				return
			var need_size := maxf(
				absf(local.x) * target.near / depth,
				absf(local.y) * target.near * aspect / depth
			) * 2.0
			target.size = maxf(need_size * padding_full, 0.0001)
## Changes the [member NodeCamera3DState.fov] or [member NodeCamera3DState.size]
## (depending on [Camera3D.projection]) to fit all given positions
## [param PackedVector2Array] in a [Camera3D]'s view.
## [br][br]
## Also see [member fit_to_point_3D].
static func fit_camera_to_points_3D(
	target : NodeCamera3DState, points: PackedVector3Array,
	padding: float = 0.05
) -> void:
	if points.is_empty():
		return
	
	var camera := target.camera
	var aspect := get_3D_viewport_size(target).aspect()
	var cam_to_world := target.transform.affine_inverse()
	
	var max_zoom := 0.0
	for global_point : Vector3 in points:
		var local: Vector3 = cam_to_world * global_point
		
		if local.z >= 0.0:
			return
		var depth := max(-local.z, 0.000001)
		
		match camera.projection:
			Camera3D.PROJECTION_PERSPECTIVE:
				if camera.keep_aspect == Camera3D.KEEP_HEIGHT:
					max_zoom = maxf(
						max_zoom, atan(
							maxf(
								absf(local.y) / depth,
								absf(local.x) / (depth * aspect)
							)
						)
					)
					continue
				max_zoom = maxf(
					max_zoom, atan(
						maxf(
							absf(local.x) / depth,
							absf(local.y) * aspect / depth
						)
					)
				)
				continue
			
			Camera3D.PROJECTION_ORTHOGONAL:
				if camera.keep_aspect == Camera3D.KEEP_HEIGHT:
					max_zoom = maxf(
						max_zoom, maxf(
							absf(local.y), absf(local.x) / aspect
						)
					)
					return
				max_zoom = maxf(
					max_zoom, maxf(
						absf(local.x), absf(local.y) * aspect
					)
				)
				continue
			
			Camera3D.PROJECTION_FRUSTUM:
				if camera.keep_aspect == Camera3D.KEEP_HEIGHT:
					max_zoom = maxf(
						max_zoom, maxf(
							absf(local.y) * target.near / depth,
							absf(local.x) * target.near / (depth * aspect)
						)
					)
					return
				max_zoom = maxf(
					max_zoom, maxf(
						absf(local.x) * target.near / depth,
						absf(local.y) * target.near * aspect / depth
					)
				)
	
	max_zoom *= (padding + 1.0) * 2.0
	
	match camera.projection:
		Camera3D.PROJECTION_PERSPECTIVE:
			camera.fov = rad_to_deg(max_zoom)
		Camera3D.PROJECTION_ORTHOGONAL, Camera3D.PROJECTION_FRUSTUM:
			camera.size = max(max_zoom, 0.0001)
#endregion


#region Boundary
## Restricts a [NodeCamera2DState] within a [param bound_rect] bounary.
static func fit_to_rectangle(
	target : NodeCamera2DState, bound_rect: Rect2,
	include_offset : bool = true
) -> void:
	var cam : Camera2D = target.get_camera()
	var int_off := cam.offset * int(include_offset)
	
	var center : Vector2 = target.global_position + int_off
	var half_view : Vector2 = cam.get_viewport_rect().size / (2 * target.zoom.abs())
	var min_center := bound_rect.position + half_view
	var max_center := bound_rect.position + bound_rect.size - half_view
	
	if min_center.x > max_center.x:
		center.x = bound_rect.position.x + bound_rect.size.x * 0.5
	else:
		center.x = clampf(center.x, min_center.x, max_center.x)
	
	if min_center.y > max_center.y:
		center.y = bound_rect.position.y + bound_rect.size.y * 0.5
	else:
		center.y = clampf(center.y, min_center.y, max_center.y)
	
	target.global_position = center - int_off
#endregion


#region Node Methods
## Returns if [param parent_layer] is currently routing to the child
## [param layer]. Only works for direct pairings.
static func vaild_route(
	parent_layer : NodeCameraGroup, layer : NodeCameraLayer
) -> bool:
	return (
		(layer.camera_mask & parent_layer.camera_mask) &&
		layer._parent_group == parent_layer &&
		(
			!(parent_layer is NodeCameraRoutable) ||
			parent_layer._route_to_layers().has(layer)
		)
	)
#endregion
