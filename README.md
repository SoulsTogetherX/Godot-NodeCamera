<p align="center">
  <img src="./gitImages/nodeCameraBanner.png" alt="Project Banner" width="100%" style="max-width:1200px">
</p>

<p align="center">
  <a href="https://godotengine.org/download/windows/">
	  <img alt="Static Badge" src="https://img.shields.io/badge/Godot-4.5%2B-blue">
  </a>
</p>

# Godot NodeCamera

NodeCamera is a Godot 4.5 addon created to simplify the creation of custom camera transitions and effects for the built in `Camera2D` and `Camera3D` nodes. With customizability being a major focus, this addon allows the user to code their own exchangeable nodes to handle camera transitions and effects to be added in a dynamic pipeline.

It allows for complex and simple camera changes and transitions between changes. Feel free to use the [premade effects and transitions](#premade-effects-and-transitions) for a smooth experience, or [make your own](#make-your-own-effects-and-transition) to suit your needs.

Check out the recommended [good practices](#good-practices) too as reference.

Or read the [installation instructions](#installation) here.

## Overview Video

<p align="center">
	<a href="(https://www.youtube.com/watch?v=OVq-GQzFglk">
	  <img width="600" height="412" alt="NodeCamera Intro Video" src="https://github.com/user-attachments/assets/f418f797-3f18-41b8-87c9-2a8d0b23cf37" />
	</a>
</p>


## How To Use

In this addon, all NodeCamera Nodes are considered **Layers**. There are three primary layers.

1. **NodeCameraHost**
2. **NodeCameraEffect**
3. **NodeCameraTransition**

**NodeCameraHost** Layers control the camera. Placing one as a child of a `Camera2D` or `Camera3D` node (the addon will adjust according on the camera type) will define the camera as a `Node Camera`. A `Node Camera` will react to the following layers:

**NodeCameraEffect** Layers define the properties a camera is expected to possess. A particular rotation. The position the camera should be at. The random offset of a camera shake effect. Etc. Extending from this node class will allow easy manipulation of these properties.

**NodeCameraTransition** Layers define the properties a camera _currently_ has. These layers are given the expected property values (calculated from **NodeCameraEffect** layers) and then define how the camera will transition to those expected properties, from its current values. These layers are used to define how a camera may transition between one property set to another. For example, the smooth transition between positions in space.

Technical info:

	Effects are always run before Transitions.

	The camera is also directly set to the expected properties defined by **NodeCameraEffect** layers every camera frame, if and only if the property was not edited by a **NodeCameraTransition** in the current camera frame. For example, a transition that only eases the position of a camera will have its offset snap directly to what the **NodeCameraEffect** layers define.

There are also a few another notable layers.

1. **NodeCameraGroup**
2. **NodeCameraRoutable**
3. **NodeCameraSelector**

**NodeCameraGroup** Layers can hold one or more layers as children. These child layers only run if **NodeCameraGroup** is also running. This can be useful for filtering certain camera masks out, or if you want a group of layers to activate/deactivate together. You may also put other **NodeCameraGroup** layers as children of this as well.

**NodeCameraRoutable** Layers are an abstract extension of **NodeCameraGroup** that only runs a definable subset of children layers. This subset can also be changed during runtime. This class can be extended to allow for any custom behavior you desire.

**NodeCameraSelector** Layers are a further extension of **NodeCameraRoutable**, premade to run only a single child layer at a time, relative to an exported child index variable. This is useful for dynamically changing camera focus locations or boundaries.

&thinsp;

## Premade Effects and Transitions

Although this addon is primarily focused on allowing the creation of new effects and transitions, it also contains many premade nodes for quick use.

**Note**: You can delete these premade layers by going into the folder `addons/nodecam/src/nodes/default/`. It is recommended to delete anything you are not using to prevent code bloat. It is also recomended to create your own effects or transitions if you want something more specialized.

Here is a quick overview of the available premade layers.

| Name                            | Type       | Abstract | General Use                                                                         | 2D Only                                         | 3D Only                                                     |
| ------------------------------- | ---------- | -------- | ----------------------------------------------------------------------------------- | ----------------------------------------------- | ----------------------------------------------------------- |
| **NodeCameraTransitionGeneral** | Transition | Yes      | An abstract class to help create general transitions, involving any camera property | -                                               | -                                                           |
| **NodeCameraTransitionInstant** | Transition | No       | Instantly sets a camera to the property defined by effect layers                    | -                                               | -                                                           |
| **NodeCameraTransitionLerp**    | Transition | No       | Lerps a camera to the property defined by effect layers                             | -                                               | -                                                           |
| **NodeCameraTransitionTween**   | Transition | No       | Tweens a camera to the property defined by effect layers                            | -                                               | -                                                           |
| **NodeCameraEffectCamera**      | Effect     | No       | Mimics an exported camera's properties                                              | Exports a `Camera2D`                            | Exports a `Camera3D`                                        |
| **NodeCameraEffectGlue**        | Effect     | No       | Defines a Camera according to a target                                              | Changes position OR zoom to include the target  | Changes position, zoom, OR rotation to include the target.  |
| **NodeCameraEffectGroup**       | Effect     | No       | Defines a Camera according to an array of targets                                   | Changes position OR zoom to include all targets | Changes position, zoom, OR rotation to include all targets. |
| **NodeCameraEffectGlueFramed**  | Effect     | No       | Moves the camera to follow a target, within a deadzone                              | -                                               | Exports a normal for the plane the camera is restricted to  |
| **NodeCameraEffectOffset**      | Effect     | No       | Sets the offset of a camera                                                         | Changes `offset`                                | Changes `h_offset` and `v_offset`                           |
| **NodeCameraEffectPosition**    | Effect     | No       | Sets the position of a camera                                                       | -                                               | -                                                           |
| **NodeCameraEffectRotate**      | Effect     | No       | Sets the rotation of a camera                                                       | -                                               | -                                                           |
| **NodeCameraEffectZoom**        | Effect     | No       | Sets the view size of the camera camera                                             | Changes `zoom`                                  | Changes either `fov` or `size`                              |
| **NodeCameraEffectShake**       | Effect     | No       | Provides an easy grow, linger, and decay shake effect                               | Changes `offset`                                | Changes `h_offset` and `v_offset`                           |
| **NodeCameraEffect2DBoundary**  | Effect     | No       | Bounds the camera to a rectangular area                                             | -                                               | Does not work                                               |
| **NodeCameraEffectFollowPath**  | Effect     | No       | Forces the camera's position to a point on a path                                   | Uses `Path2D`                                   | Uses `Path3D`                                               |

You can also combine these effects and transitions together for any number of permutations. However, if you want to create a more specific layer, you'd need to write your own code.

&thinsp;

## Make Your Own Effects and Transition

This addon's main feature is the ability to create your own effect and transition layers. As such, the coding process has been made as streamline as possible, while retaining high customizability.

Below is a quick overview on how to create your own layers.

### How Implement Effects and Transitions

First, both **NodeCameraEffect** and **NodeCameraTransition** have their respective [Stage Process](#process-stage-methods) and [Stage Change](#change-stage-methods) virtual methods. For example, **NodeCameraEffect** has:

```python
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass
func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass
```

While **NodeCameraTransition** has:

```python
func process_transition(
	delta : float, target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	pass
func transition_stage_changed(
	target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	pass
```

These methods all possess similar usages and arguments. First, we'll discuss the arguments.

&thinsp;

#### Methods Parameters

There are four notable parameters: `delta`, `target`, `current`, and `stage`.

- `delta`, as expected, represents the time (in seconds) since the last frame call (or `0.0` when the host's mode is manual). This is only given to `process_effect` and `process_transition` as those are expected to run every frame.

- `target` and `current` are `NodeCameraState` objects. More specifically, they are either `NodeCamera2DState` or `NodeCamera3DState` objects, containing all relevant properties of a `Camera2D` or `Camera3D` node respectively (the type provided is based on what camera the relevant **NodeCameraHost** is a child of).

  In addition, using the method `get_var`, `set_var`, and `clear_var` (on `target` or `current`), you can also set a _SINGLE_ variable value on these objects, per layer. `target` and `current` share the same variables. If you need more than one variable, use an inner class or dictionary.

  Note that `target` is the _EXPECTED_ properties a camera should have, while `current` is the _CURRENT_ properties a camera possesses.

  Ideally, **NodeCameraEffect** layers should set the `target` to be what they want the camera to showcase, while **NodeCameraTransition** layers should ease the camera to those properties.

- Finally, `stage` is the current stage of a layer. A stage can be in either the `STARTING`, `RUNNING`, `ENDING`, or `HALTED` stage. These stages can be changed in a [variety of ways](#how-to-manipulate-stages), Ideally, you should change a layer's behavior depending on what stage a layer is on.

Now, let's talk about these methods' use cases.

&thinsp;

#### Process Stage Methods

Note that `process_effect` and `process_transition` are considered _process stage_ methods. Depending on the host's callback (whether it runs on process frames, physics frames, or by manual calling), these methods will be called on each currently-active layer.

In **NodeCameraEffect**, this is mainly used to ensure the expected camera properties always conform to a certain standard or value, depending on the frame or previous effects.

In **NodeCameraTransition**, this is mainly used to transition from the current camera properties to the expected properties, or to delay the camera from reaching the expected properties.

Note that these methods can never be called with a `stage` of `HALTED`.

&thinsp;

#### Change Stage Methods

Meanwhile `effect_stage_changed` and `transition_stage_changed` are considered _change stage_ methods. These methods are ONLY called when a layer's stage changes.

A stage layer changes in the order `STARTING > RUNNING > ENDING > HALTED`.

These methods are also ALWAYS called before any [Stage Process](#process-stage-methods) methods. As such, these methods are typically used for setup logic.

Also note that as _change stage_ methods can be called with a `stage` of `HALTED`, making this a perfect location for cleanup logic too.

In **NodeCameraEffect**, this is mainly used to setup a process effect, or as a onetime setter for the expected camera properties.

In **NodeCameraTransition**, this is mainly used to setup a transition or to clean up/set up a variable on the provided `NodeCameraState`.

Technical info:

    These methods are not called instantly upon stage change. They are instead added to a queue and processed at the start of the next camera frame.

	The order they are processed depends on if they are an effect or transition, what stage it is being changed to, and the layer's priority.

&thinsp;

#### Stage Specifiers Methods

Finally, in both layer types, there are three important `Stage Specifiers` methods.

```python
func get_needed_process_stages() -> PackedInt32Array:
	return []
func get_needed_linger_stages() -> PackedInt32Array:
	return []
func get_needed_change_stages() -> PackedInt32Array:
	return []
```

In all three methods, you can provide an array of stages, to varying effects.

- For `get_needed_process_stages`, any stage returned here will have the appropriate [Stage Process](#process-stage-methods) method called within it.

- Likewise, any stage returned by `get_needed_change_stages` will have the appropriate [Stage Change](#change-stage-methods) method called whenever the layer changes to that stage.

- However, `get_needed_linger_stages` is special. Normally, when a layer changes to a stage, it will attempt to advance to the next stage instantly (via `STARTING > RUNNING > ENDING > HALTED`). However, if a stage is returned by `get_needed_change_stages`, the stage will automatically advance.

  Sometimes, this is not what you want. To prevent this, return any stages you want the layer to `linger` on in `get_needed_linger_stages`. The layer will then stay on the provided stages for as long as no external influence forces another stage change.

Note: if a stage is returned by `get_needed_process_stages`, the stage will not automatically advance either.

Use these methods effectively in order to prevent unneeded processing within your layers.

&thinsp;

#### How to Manipulate Stages

There are many ways to manipulate a layer's stage during runtime.

- First, **NodeCameraEffect** and **NodeCameraTransition** layers have an `inital_stage` exported property. This will be the stage the layer starts with on first creation.

You can also either `overwrite`, `advance`, or `advance_to` a layer's stage.

1. `overwriting` a layer directly sets the layer's stage to the given argument, ignoring all else.

2. `advancing` a layer will move its stage forward (via the order `STARTING > RUNNING > ENDING > HALTED`).

3. `advancing to` a layer is the same as `overwriting` the layer's stage to a given argument, but this _ONLY_ happens if the _current_ stage is _before_ the given argument (via the order `STARTING > RUNNING > ENDING > HALTED`).

After change, the layer will then act as specified by the [Stage Specifiers](#stage-specifiers).

Simple, right? Unfortunately, there is a bit more work still.

Note that for each **NodeCameraHost**, every layer will have its own record of the layer running. And each record has its own independent stage stored in. Thus, you'll now need to access the specific record you want to change the stage of.

There are three main methods of doing exactly that.

First, if you are only concerned about the currently-executing stage, you can use...

```python
func advance_stage() -> void
func advance_to_stage(stage : LAYER_STAGES) -> void
func overwrite_stage(stage : LAYER_STAGES) -> void
```

Note: You can **ONLY** call these methods in either a [Stage Change](#change-stage-methods) or [Stage Process](#process-stage-methods) method, otherwise expect undefined behavior.

On the other hand, if you want to effect **ALL** records across **ALL** **NodeCameraHost** layers you can instead use...

```python
func notify_advance_stage() -> void
func notify_advance_to_stage(stage : LAYER_STAGES) -> void
func notify_overwrite_stage(stage : LAYER_STAGES) -> void
```

Finally, if you want to filter out certain records, you can use `get_parent_scopes`, which will give you all `NodeCameraExecutionScope` the current layer is active in. You can then filter out which scopes you want to change from there.

As a side note, if you want to change the [Stage Specifiers](#stage-specifiers-methods) methods in runtime, then use...

```
func notify_stage_masks_changed() -> void
```

The addon will handle the rest.

&thinsp;

## Good Practices

The point of this addon is to allow for high customizability in camera management. Thus, instead of telling you how to use this addon, I will simply provide a few best practices that you may wish to use in your project.

- Sets your **NodeCameraTransition** layers to begin on the `HALTED` stage, upon creation.

  This is useful since, if all your starting transitions are halted (I.E. not active), then your camera will immediately skip to the starting location. Useful since you normally wouldn't want a transition upon game startup.

&thinsp;

- Use the NodeCameraUtility class.

  This is a static class dedicated to holding a variety of helper functions to aid the creation of your own effects and transitions. Try to read it once over before reinventing the wheel.

&thinsp;

- Use global layers for consistent effects across different levels.

  If you have a way to allow for persistent layers between levels, it's possible to have a persistent camera effect or transition always active.

  Maybe you always want to follow a player. Maybe you always want to bound your camera within a certain box. Maybe you want the camera to always lerp to its expected position. Etc.

  These are set and forget layers, which can be useful in some situations.

&thinsp;

- Try to reduce your use of [Stage Process](#process-stage-methods) methods.

  As useful as they are, they still have the overhead of being run every camera frame. If you don't need to run something every frame, it's best you don't. Creating a tween in a [Stage Change](#change-stage-methods) method or advancing to a `HALTED` stage (once a transition is finished) can result in faster speeds. You can also use `notify_stage_masks_changed` to change where [Stage Process](#process-stage-methods) methods can or cannot be run to avoid redundant `if-checks` in process methods too.

  Note that the addon code is efficient enough that small-scale optimizations won't matter. However, if you are experiencing slowdown, this is an area for improvement.

&thinsp;

- If an **NodeCameraEffect** layer is expected to make a large change, use a **NodeCameraGroup** instead with a **NodeCameraTransition** layer.

  Doing this, the `transition` will be activated alongside the `effect` (as they are both children of the `group`). This can automatically ease between the camera properties.

&thinsp;

- Use **NodeCameraRoutable** and **NodeCameraSelector** to change your camera's state

  These nodes use `advance stage` and `overwrite stage` internally, allowing for the easy runtime change of active effects and transitions. Use **NodeCameraGroup** to activate or deactivate a group of layers at once.

&thinsp;

- Use **NodeCameraEffectCamera** for protyping.

  It cannot be overstated how useful it can be to have the camera mimic a visual `Camera2D` or `Camera3D` on the `SceneTree`. Try it out.

&thinsp;

- Order your layer priorities properly.

  Effects -- that replace properties in `target` -- should be run **before** effects that **iterate** on existing properties. I.E. An assignment effect (var p = 1) should be run prior to an iterative effect (p += 1).

  For example, an effect that sets the expected camera position to be at `Vector2.ZERO` should typically be run before an effect that offsets the currently-expected camera position by an additional `Vector2(40.0, 40.0)`.

  For example, an effect that bounds the camera to a rectangular area should be run _AFTER_ all other effects. Therefore, it should have the lowest priority.

  Same thing with transitions. The last step in either the effects or transitions should have the lowest priority. If they have the same priority, they will run in the order they are added in.

&thinsp;

- Use camera masks only if you expect to use more than one camera.

  Camera masks are powerful, allowing you to use different effects and transitions for different cameras (whether for multiplayer or to separate 2D and 3D camera logic), but can also be confusing when not needed. Don't touch the camera masks if you don't need to.

## Installation

#### Asset Library or Asset Store (Recommended - Stable)

- In Godot, open the [AssetLib](https://godotengine.org/asset-library/asset) or [AssetStore](https://store.godotengine.org/) tab.
- Search for and select "NodeCamera".
- Download then install the plugin (be sure to only select the `nodecam` directory).
- Enable the plugin inside Project/Project Settings/Plugins.

#### Github Releases (Recommended - Stable)

- Download a release build.
- Extract the zip file and move the `addons/nodecam` directory into the project `addon` folder location.
- Enable the plugin inside Project/Project Settings/Plugins.

#### Github Main (Latest - Unstable)

- Download the latest main branch.
- Extract the zip file and move the `addons/nodecam` directory into project's `addon` folder location.
- Enable the plugin inside Project/Project Settings/Plugins.

For more help, see [Godot's official documentation](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).

## Other Camera Addons

- [Phantom Camera](https://github.com/ramokz/phantom-camera) by [ramokz](https://github.com/ramokz).

## Known Issues

None known.

## Links

<a href='https://ko-fi.com/E2J420AV1G' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi6.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
