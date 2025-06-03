# Chemical - Reactive State & UI Framework for Roblox Luau

**Version:** 0.1.0b ALPHA (as of 6/1/2025, per comments)
**Author:** Sovereignty (Discord: sov_dev)

## Table of Contents

1. [Introduction](#1-introduction)
2. [Core Philosophy](#2-core-philosophy)
3. [Installation & Setup](#3-installation--setup)
4. [Core Reactive Primitives](#4-core-reactive-primitives)
    * [Value`<T>`](#valuet)
    * [Computed`<T>`](#computedt)
    * [Observer](#observer)
    * [Element](#element)
    * [Watch](#watch)
5. [UI Creation & Management](#5-ui-creation--management)
    * [Chemical.Create()](#chemicalcreate)
    * [Chemical.Give()](#chemicalgive)
    * [UI Traits: `Ref`, `onEvent`, `onChange`](#ui-traits)
6. [State Replication (`Chemical.Reaction`)](#6-state-replication-chemicalreaction)
    * [Server-Side API](#reaction-server-side-api)
    * [Client-Side API](#reaction-client-side-api)
    * [Example Usage](#reaction-example-usage)
7. [Client-Side Routing (`Chemical.Router`)](#7-client-side-routing-chemicalrouter)
8. [Utility Functions](#8-utility-functions)
    * [Chemical.Await()](#chemical-await)
    * [Chemical.Destroy()](#chemical-destroy)
9. [Under The Hood (Advanced)](#9-under-the-hood-advanced)
    * [Networking (`Packages.Packet`)](#networking-packagespacket)
10. [Type System](#10-type-system)
11. [Examples](#11-examples)

---

## 1. Introduction

Chemical is a comprehensive Luau framework for Roblox game development, emphasizing a reactive programming paradigm. It aims to simplify state management, UI development, and server-client data synchronization by providing a suite of interconnected tools. With Chemical, developers can build dynamic and responsive user interfaces and game systems that automatically react to changes in their underlying data.

Key features include observable values, derived (computed) values, an ECS-backed architecture, declarative UI construction, client-side routing, and a powerful state replication system.

## 2. Core Philosophy

* **Reactivity:** State changes should automatically propagate through the application, updating dependent values and UI elements without manual intervention.
* **Declarative UI:** Describe *what* your UI should look like based on the current state, and let Chemical handle the updates.
* **Centralized State (Optional):** While not strictly enforcing a single global store, `Chemical.Reaction` facilitates managing and syncing shared game state.
* **Performance:** Leveraging an ECS backend and a custom packet system for efficient data handling and networking.
* **Developer Experience:** Providing clear, typed APIs (using Luau type annotations) and utilities to streamline common tasks.

## 3. Installation & Setup

1. Place the `Chemical` root `ModuleScript` (and its descendant file structure from the `.rbxm`) into a suitable location, typically `ReplicatedStorage` to be accessible by both server and client.
2. Ensure the `UseReactions` BoolValue in `Chemical/Configuration` is set to `true` if you intend to use the `Chemical.Reaction` state replication system. If `false`, attempting to use `Reaction` will result in a warning/error.

```lua
-- Accessing the Chemical library
local Chemical = require(game.ReplicatedStorage.Chemical)
```

## 4. Core Reactive Primitives

These are the fundamental building blocks for creating reactive data flows.

### Value`<T>`

The `Value<T>` object is the most basic reactive unit. It encapsulates a single piece of data that can be read and written. When its data changes, any `Computed` values or `Observer`s depending on it are notified.

**API:**

* `Chemical.Value(initialValue: T): Value<T>`: Constructor.
* `:get(): T`: Retrieves the current value. If called within a `Computed` function or `Watch` target getter, it registers this `Value` as a dependency.
* `:set(newValue: T)`: Sets a new value. If the new value is different from the old, it triggers updates to dependents.
* `:increment(amount: number?)`: For numeric `Value`s. Increments the value by `amount` (defaults to 1).
* `:toggle()`: For boolean `Value`s. Flips the boolean state.
* `:key(key: any, newValue: any)`: For table `Value`s. Sets `tbl[key] = newValue` and triggers updates.
* `:insert(itemValue: any)`: For array-like table `Value`s. Equivalent to `table.insert(tbl, itemValue)`.
* `:remove(itemValue: any)`: For array-like table `Value`s. Removes the first occurrence of `itemValue`.
* `:destroy()`: Destroys the `Value` object, cleaning up its ECS entity and notifying dependent `Computed`s or `Observer`s (which may also destroy themselves).

**Example:**

```lua
local Chemical = require(path.to.Chemical)

local playerScore = Chemical.Value(0)
local isGameOver = Chemical.Value(false)

print(playerScore:get()) -- Output: 0

playerScore:increment(10)
print(playerScore:get()) -- Output: 10

isGameOver:set(true)
```

### Computed`<T>`

A `Computed<T>` object represents a value that is derived from one or more other reactive objects (`Value`s or other `Computed`s). It automatically re-evaluates its derivation function whenever any of its dependencies change, if the new value differs from the old it will appropriately cache the value and respond.

**API:**

* `Chemical.Computed(derivationFunction: () -> T, cleanupFunction?: (oldDerivedValue: T) -> ()): Computed<T>`: Constructor.
  * `derivationFunction`: A function that returns the computed value. Any `Value:get()` or `Computed:get()` calls inside this function establish dependencies.
  * `cleanupFunction` (optional): A function called with the *previous* computed value right before the `Computed` is re-cached due to a dependency change, or when the `Computed` object is destroyed. Useful for cleaning up side effects or resources tied to the old value.
* `:get(): T`: Retrieves the current computed value. If called within another `Computed` or `Observer`, it registers this `Computed` as a dependency.
* `:destroy()`: Destroys the `Computed` object, cleaning up its value if `cleanup` was provided as well as its ECS entity and notifying dependent `Computed`s or `Observer`s (which may also destroy themselves).

**Example:**

```lua
local Chemical = require(path.to.Chemical)

local firstName = Chemical.Value("Jane")
local lastName = Chemical.Value("Doe")
local isGameOver = Chemical.Value(true)

local fullName = Chemical.Computed(function() 
    return firstName:get() .. " " .. lastName:get()
end)

print(fullName:get()) -- Output: Jane Doe

firstName:set("John")
task.wait() --Computeds will run on the next frame after the change.
print(fullName:get()) -- Output: John Doe (automatically updated)

local characterDescription = Chemical.Computed(function()
    local name = fullName:get() -- Dependency on another Computed
    local status = isGameOver:get()

    return string.format("%s (Game Over: %s)", name, tostring(status))
end, function(oldDescription) --Optional Cleanup method
    print("CharacterDescription cleanup. Old value:", oldDescription)
end)

print(characterDescription:get()) -- Output: John Doe (Game Over: true)

isGameOver:set(false) -- Triggers re-computation of characterDescription
task.wait()
print(characterDescription:get()) -- Output: John Doe (Game Over: false)

isGameOver:set(false) -- Because isGameOver is already == false, it will not triggers re-computation of characterDescription
                      -- Nor will it cause any observational changes/events to be triggered as the value of isGameOver did not change.
                      -- This applies to computeds as well.
```

### Observer

An `Observer` allows you to react to changes in a `Value` or `Computed` object by executing a callback function.

**API:**

* `Chemical.Observer(target: Value<any> | Computed<any>): Observer`: Constructor.
* `:onChange(callback: (newValue: any?, oldValue: any?) -> ()): () -> ()`: Registers a callback function to be invoked when the observed `target`'s value changes.
  * Returns a `disconnectFunction` that, when called, unregisters this specific callback.
* `:destroy()`: Destroys the `Observer` and disconnects all its listeners.

**Example:**

```lua
local Chemical = require(path.to.Chemical)
local health = Chemical.Value(100)

local healthObserver = Chemical.Observer(health)

local disconnectHealthListener = healthObserver:onChange(function(newHealth, oldHealth)
    print(string.format("Health changed from %s to %s", tostring(oldHealth), tostring(newHealth)))
end)

health:set(80) -- Output: Health changed from 100 to 80
health:set(80) -- No output (value didn't change)
health:set(95) -- Output: Health changed from 80 to 95

disconnectHealthListener() -- Stop listening for this specific callback

health:set(100) -- No output from the disconnected listener

healthObserver:destroy() -- Destroy the observer entirely
```

### Element

An `Element` is a specialized reactive state value, primarily designed for managing the visibility or active state of UI components, in conjunction with the `Chemical.Router`.
The different between `Element` and `Value` is that `Element`s have reactive parameters which can be retrieved and are set by the `Router`.

**API:**

* `Chemical.Element(): Element`: Constructor. Initializes with a state of `false`.
* `:get(): boolean`: Gets the current boolean state. Registers a dependency if used in a `Computed`.
* `:set(newState: boolean)`: Sets the boolean state.
* `:params(): { from?: string, [any]: any }` : This is the reactive parameter object, which can contain the reserved key `from`.
* `:params(newParams: { from?: string, [any]: any })`: Sets or gets an associated parameters table. The `Router` uses this to pass information like the previous path (`from`) when an element's state changes due to a route transition.
* `:onChange(callback: (newState: boolean, fromPath?: string) -> ()): () -> ()`: Listens for changes to the element's boolean state. The callback receives the new state and the `from` property of the current params. Returns a disconnect function.
* `:destroy()`: Destroys the `Element`.
* `.__persistent: boolean?`: (Internal property set by Router) If true, the Router will not automatically set this Element to `false` when navigating away from its associated path.

**Example (Conceptual, often used with Router):**

```lua
local Chemical = require(path.to.Chemical)
local settingsPageElement = Chemical.Element()

-- In UI Creation:
-- Visible = settingsPageElement,

    routher:paths({
        {Path = "/settings", Element = settingsPageElement}
    })

-- Elsewhere (e.g., Router logic):
-- router:to("/settings", { message = "hello" })
```

### Watch

`Watch` allows you to observe a specific key within a table that is itself held by a `Value` or `Computed` object. The callback triggers only when the value associated with that *specific key* changes.

**API:**

* `Chemical.Watch(targetGetter: () -> ({ targetTableContainer: Value<{[any]:any}> | Computed<{[any]:any}>, key: any }), callback: (newValueForKey: any?, oldValueForKey: any?) -> ()): () -> ()`: Constructor.
  * `targetGetter`: A function that must return a table and a string:
    * The `Value` or `Computed` object that holds the table you want to watch.
    * The specific `key` within that table whose value changes you want to monitor.
    * Any reactive `:get()` calls within will establish dependencies for re-evaluating which table/key to watch if those dependencies change (though the primary use is for a single reactive table).
    * `callback`: A function invoked when the value of `targetTableContainer:get()[key]` changes. It receives the new and old values for that specific key.
    * Returns a `disconnectFunction`.

**Example:**

```lua
local Chemical = require(path.to.Chemical)

local userProfile = Chemical.Value({
    username = "User123",
    score = 100,
    inventory = {"sword", "shield"}
})

local disconnectUsernameWatch = Chemical.Watch(
    function() return userProfile:get(), "username" end,
    function(newUsername, oldUsername)
        print(string.format("Username changed from '%s' to '%s'", oldUsername, newUsername))
    end
)

local disconnectScoreWatch = Chemical.Watch(
    function() return userProfile:get(), "score" end,
    function(newScore, oldScore)
        print(string.format("Score changed from %s to %s", oldScore, newScore))
    end
)

-- Update the whole profile table
userProfile:set({
    username = "PlayerOne",
    score = 150,
    inventory = {"sword", "shield", "potion"}
})
-- Output:
-- Username changed from 'User123' to 'PlayerOne'
-- Score changed from 100 to 150

-- Update using :key (also triggers Watch if the specified key is watched)
userProfile:key("score", 200)
-- Output:
-- Score changed from 150 to 200
```

`Watch` has a very specific use case in regards to `Element`s.

```lua
    local Chemical = require(path.to.Chemical)

    local router = Chemical.Router()
    local someElement = Chemical.Element()

    router:paths({
        { Path = "/settings", Element = someElement }
    })

    local disconnect = Chemical.Watch(
        function() return someElement:params(), "message" end,
        function(new, old) print("New message: ", new) end
    )

    router:to("/settings", { message = "hello" }) --Prints "New message: hello"

    --Element:params() can also be accessed directly, usually inside of an Observer after the Element's state has changed.
```

## 5. UI Creation & Management

Chemical provides a declarative API for creating and managing Roblox GUI elements, making it easy to bind UI properties to reactive state.

### Chemical.Create()

`Chemical.Create(className: string): (propertyTable: dictionary): GuiObject`

Creates a new instance of the specified `className` (e.g., "Frame", "TextLabel") and applies properties defined in `propertyTable`.
This supports intellisense for each className of GuiObjects!

**`propertyTable` Keys and Values:**

* **Standard Properties:** (e.g., `Size`, `Position`, `BackgroundColor3`, `Text`, `Visible`)
  * Can be static values: `Size = UDim2.fromScale(0.1, 0.1)`
  * Can be a `Value` or `Computed` object: `Visible = myVisibilityValue` (where `myVisibilityValue` is a `Value<boolean>`). The UI property will automatically update when the reactive object changes.
* **`Parent: Instance | Value<Instance> | Computed<Instance>`**: Sets the parent of the created element. Can be static or reactive.
* **`Children: {GuiObject}`**: An array of other `Chemical.Create()` calls or static GuiObject references. The created child elements will be parented to this element.
* **UI Traits** (see below).

**Example (from `LocalScript Examples`):**

```lua
local Chemical = require(path.to.Chemical)
local Create = Chemical.Create
local Value = Chemical.Value
local PlayerGui = game.Players.LocalPlayer.PlayerGui

local frameColor = Value(Color3.fromRGB(200, 200, 200))
local childFrameRef = Value() -- Will hold the reference to the child frame

local mainFrame = Create("Frame"){
    Size = UDim2.fromScale(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),

    BackgroundColor3 = frameColor, -- Reactive property

    Visible = true,

    Children = {
        Create("Frame"){
            Name = "ChildInnerFrame",

            Size = UDim2.fromScale(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),

            BackgroundColor3 = Color3.fromRGB(100, 100, 100),

            Visible = true,

            [Chemical.Ref] = childFrameRef -- Assign instance to childFrameRef Value
        },

        Create("TextButton"){
            Name = "ColorChangeButton",

            Size = UDim2.fromOffset(100, 30),
            Position = UDim2.fromScale(0.5, 0.8),
            AnchorPoint = Vector2.new(0.5, 0.5),

            Text = "Change Color",

            [Chemical.onEvent("MouseButton1Click")] = function()
                frameColor:set(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
            end
        }
    },

    Parent = Create("ScreenGui"){
        Name = "MyChemicalScreenGui",
        Parent = PlayerGui
    }
}

task.wait(2)


print("Child frame reference:", childFrameRef:get().Name) -- Output: ChildInnerFrame

```

### Chemical.Give()

`Chemical.Give(instance: GuiObject): (propertyTable: dictionary): GuiObject`

Applies reactive properties and traits to an *existing* `instance`. The `propertyTable` structure and capabilities are the same as for `Chemical.Create()`. This is useful for hydrating GUIs not created by Chemical or for applying reactive behavior incrementally.

```lua
local existingFrame = script.Parent.SomeFrame -- Assuming a Frame exists
local frameVisible = Chemical.Value(true)

Chemical.Give(existingFrame) {
    Visible = frameVisible, --Reactive object value

    [Chemical.onChange("AbsoluteSize")] = function(newSize)
        print("Frame AbsoluteSize changed to:", newSize)
    end
}

task.wait(3)

frameVisible:set(false) -- existingFrame will become invisible
```

### UI Traits

Special keys used within the `propertyTable` of `Create` and `Give` to add specific behaviors:

* **`[Chemical.Ref] = refValue: Value<Instance>`**:
    When the UI element is created (by `Create`), or hydrated (by `Give`), `refValue:set(createdInstance)` is called. This allows you to get a reactive reference to the instance itself.
* **`[Chemical.onEvent(eventName: string)] = callback: (() -> ()) | Value<boolean>`**:
    Connects to the specified `eventName` (e.g., "MouseButton1Click", "MouseEnter") of the UI element.
  * If `callback` is a function, it's called when the event fires. Arguements of the event *are* passed to the function.
  * If `callback` is a `Value<boolean>`, its value is set to `true` when the event fires. (The actual arguments of the event are not passed to the Value's set method).
* **`[Chemical.onChange(propertyName: string | Value<any> | Computed<any>)] = callback: ((newValue: any) -> ()) | Value<any>`**:
  * If `propertyName` is a string: Listens to `Instance:GetPropertyChangedSignal(propertyName)`.
    * If `callback` is a function, it's called with the new property value.
      * If `callback` is a `Value`, its `set` method is called with the new property value.
    * If `propertyName` is a `Value`, `Computed`, or `Element` (reactive object): Creates an `Observer` for this reactive object.
      * If `callback` is a function, it's called when the reactive object changes (receives `newValue, oldValue`).
      * (Using a Value as callback for a reactive propertyName is less common and might imply a two-way binding if not careful, however it is permitted).
        * You might use this for TextBox.Text properties, such that when the value of the TextBox changes so too does the reactive Value Object's value.

All connections made via these traits are automatically disconnected when the GuiObject they are attached to is destroyed (via `instance:Destroy()` or `Chemical.Destroy()`).

## 6. State Replication (`Chemical.Reaction`)

`Chemical.Reaction` is a singleton service that automates the synchronization of state between the server and connected clients. It supports replicating both static values and reactive `Value`/`Computed` objects.

**Key Characteristics:**

* **Channel & Key Identification:** Reactions are identified by a `(channelName: string, reactionKey: string)` pair.
* **One-Way Server-to-Client:** The primary flow of data is from server to client. Client-side changes to replicated state do not automatically propagate back to the server via this system.
* **Nested Structure:** Supports state tables with up to one level of nesting where the nested values can be `Value` objects.

    ```lua
    -- Example of supported state structure for Reaction
    local state = {
        staticTopLevel = "hello",
        reactiveTopLevel = Chemical.Value(10),
        nestedObject = {
            staticNested = true,
            reactiveNested = Chemical.Value("world")
        }
    }
    ```

* **Tokenization:** Internally, channel names, reaction keys, and field keys are tokenized (converted to numbers) for efficient network transmission.
* **Initial Hydration:** When a client connects or is ready, it receives a full snapshot of all existing reactions it's concerned with.
* **Delta Updates (for `Value` objects):** Only changes to `Value` objects are networked after initial hydration. Changes to static parts of the state after creation are not automatically replicated. If a `Value` object itself holds a table, the system is *designed to* (aims to in the future) send only the changed parts of that table.

### Reaction Server-Side API

Accessible via `local Reaction = Chemical.Reaction()`.

* `Reaction:create(channelName: string, reactionKeyName: string, initialState: table): ServerReactionAPI`:
  * Creates a new reaction on the server and broadcasts its construction to all clients.
  * `initialState`: The table defining the reaction's state. Values within this table can be static Luau types or `Chemical.Value`/`Chemical.Computed` instances.
  * Returns a `ServerReactionAPI` object with two methods:
    * `destroy()`: Destroys the reaction on the server and notifies clients to deconstruct it. All reactive `Value` objects within its state are also destroyed.
    * `raw()`: Returns a deep, non-reactive snapshot of the current state of the reaction. `Value` objects are replaced with their current values.

### Reaction Client-Side API

Accessible via `local Reaction = Chemical.Reaction()`.

* `Reaction:await(channelName: string, reactionKeyName: string): Promise<ClientReaction>`:
  * Returns a `Promise` that resolves with the client-side reaction object once it has been constructed (either through initial hydration or a `ConstructReaction` packet).
  * The resolved `ClientReaction` object mirrors the structure of the server's `initialState`, where server-side `Chemical.Value`/`Chemical.Computed` instances become client-side `Chemical.Value` instances. Static values remain static.
  * It's recommended to use `:expect()` on the promise if you are certain the reaction should exist, to automatically error if it doesn't resolve.
* `Reaction:onCreate(channelName: string, callback: (reactionKeyName: string, reactionObject: ClientReaction) -> ()): () -> ()`:
  * Subscribes to creations of new reactions within the specified `channelName`.
  * The `callback` is invoked immediately for any already existing reactions in that channel, and then for any new ones as they are constructed.
  * Returns a `disconnectFunction` to stop listening.

### Reaction Example Usage

*(See `Chemical/Examples` script for a practical implementation which creates a `PlayerData` reaction per player.)*

**Server (`ServerScriptService`):**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Chemical = require(ReplicatedStorage.Chemical)

local Reaction = Chemical.Reaction() -- Get the singleton instance

Players.PlayerAdded:Connect(function(player)
    -- Define initial state, some parts reactive, some static
    local healthValue = Chemical.Value(100)
    local manaValue = Chemical.Value(50)

    local playerStatsState = {
        PlayerName = player.Name, -- Static
        UserId = player.UserId,   -- Static
        Health = healthValue,     -- Reactive
        Mana = manaValue,         -- Reactive
        Inventory = {
            Gold = Chemical.Value(10), -- Nested reactive
            Items = {"Sword", "Shield"} -- Nested static
        }
    }

    -- Create the reaction for this player
    -- The "PlayerData" channel could hold reactions for all players
    local myReaction = Reaction:create("PlayerData", tostring(player.UserId), playerStatsState)
    print("Created reaction for player:", player.Name)

    -- Example of updating a reactive value after creation
    task.delay(5, function()
        if player and myReaction then -- Ensure player and reaction still exist
            print("Server: Setting health for", player.Name, "to 75")
            healthValue:set(75) -- This change will be replicated to clients
        end
    end)
    
    -- When player leaves, destroy their reaction
    player.Removing:Connect(function()
        if myReaction then
            print("Server: Destroying reaction for player:", player.Name)
            myReaction:destroy()
        end
    end)
end)
```

**Client (`LocalScript` in `StarterPlayerScripts`):**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Chemical = require(ReplicatedStorage.Chemical)

local Reaction = Chemical.Reaction() -- Get the singleton instance
local Create = Chemical.Create
local localPlayer = Players.LocalPlayer

local function setupPlayerUI(playerData)
    print("Client: Received PlayerData for", playerData.PlayerName, playerData)
    
    local screenGui = Create("ScreenGui"){ Parent = localPlayer.PlayerGui }
    
    Create("TextLabel"){
        Name = "HealthDisplay",
        Size = UDim2.fromOffset(200, 30),
        Position = UDim2.fromScale(0.5, 0.1),
        AnchorPoint = Vector2.new(0.5, 0.5),

        Text = Chemical.Computed(function() -- Text reactively updates
            return string.format("Name: %s | Health: %d", playerData.PlayerName, playerData.Health:get())
        end),

        Parent = screenGui,
    }
    
    Create("TextLabel"){
        Name = "ManaDisplay",
        Size = UDim2.fromOffset(200, 30),
        Position = UDim2.fromScale(0.5, 0.15),
        AnchorPoint = Vector2.new(0.5, 0.5),

        Text = Chemical.Computed(function()
            return "Mana: " .. playerData.Mana:get()
        end),

        Parent = screenGui,
    }

    Create("TextLabel"){
        Name = "GoldDisplay",
        Size = UDim2.fromOffset(200, 30),
        Position = UDim2.fromScale(0.5, 0.2),
        AnchorPoint = Vector2.new(0.5, 0.5),

        Text = Chemical.Computed(function()
            return "Gold: " .. playerData.Inventory.Gold:get()
        end),

        Parent = screenGui,
    }

    -- Observe changes locally if needed
    Chemical.Observer(playerData.Health):onChange(function(newHealth)
        print("Client: Health is now", newHealth)
    end)
end

-- Await this specific player's data
Reaction:await("PlayerData", tostring(localPlayer.UserId))
    :andThen(setupPlayerUI)
    :catch(function(err)
        warn("Client: Failed to get PlayerData reaction:", err)
    end)

-- Alternatively, listen to all reactions in a channel
-- local disconnectListener = Reaction:onCreate("PlayerData", function(reactionKey, reactionObject)
--     if reactionKey == tostring(localPlayer.UserId) then
--         print("Client: PlayerData (via onCreate) for me!", reactionObject)
--         -- setupPlayerUI(reactionObject)
--         -- if you use onCreate, you might want to manage disconnects or ensure UI is only set up once.
--     else
--         print("Client: PlayerData (via onCreate) for another player:", reactionKey)
--     end
-- end)
```

## 7. Client-Side Routing (`Chemical.Router`)

The `Chemical.Router` is a singleton service for managing client-side application flow by defining paths and associating them with reactive `Chemical.Element`s. When the route changes, corresponding `Element`s are activated or deactivated, typically controlling UI visibility.

**API:**

* `Chemical.Router(): RouterInstance`: Gets the singleton router instance.
* `router:paths(routes: {{ Path: string, Element: Chemical.Element, Persistent?: boolean }})`: Defines a set of routes.
  * `Path`: A string like "/shop/items" or "/profile". Leading/trailing slashes are handled.
  * `Element`: The `Chemical.Element` instance that will be set to `true` when this path is active.
  * `Persistent` (optional, boolean): If true, the `Element` will not be automatically set to `false` when navigating to a sibling or parent. It will still be set to `false` if explicitly exited.
* `router:to(path: string, params?: table)`: Navigates to the specified `path`.
  * Deactivates elements associated with the previous path (respecting persistence and shared ancestry).
  * Activates the `Element` for the new `path`.
  * `params` is an optional table passed to the target `Element`'s `:params()` method. `params.from` is automatically set to the old path.
* `router:is(path: string): boolean`: Returns `true` if the current path exactly matches the given `path`.
* `router:exit(path: string, params?: table)`: Explicitly deactivates the `Element` (and its descendant elements in the route tree) associated with the `path`. Sets `CurrentPath` to `""`.
* `router:onBeforeChange(callback: (newPath: string, oldPath: string) -> ())`: Registers a callback invoked before the current path changes and any `Element`s close.
* `router:onChange(callback: (newPath: string, oldPath: string) -> ())`: Registers a callback invoked when `CurrentPath`'s value changes. This is syntactic sugar for `Chemical.Observer(router.CurrentPath):onChange(...)`.
* `router:onAfterChange(callback: (newPath: string, oldPath: string) -> ())`: Registers a callback invoked after the current path has changed and target elements have been updated.
* `router.CurrentPath: Value<string>`: A reactive `Value` object holding the current active path string.

**Example (from `LocalScript Examples`):**

```lua
local Chemical = require(path.to.Chemical)
local Create = Chemical.Create
local Give = Chemical.Give
local Value = Chemical.Value
local Watch = Chemical.Watch
local Ref = Chemical.Ref
local PlayerGui = game.Players.LocalPlayer.PlayerGui

local Router = Chemical.Router() -- Get the singleton instance

-- Define Elements for different pages/views
local tutorialPageElement = Chemical.Element()
local homePageElement = Chemical.Element()

local tutorialFrame = Value()

-- Define routes
Router:paths({
    { Path = "/tutorial", Element = tutorialPageElement },
    { Path = "/home", Element = homePageElement, Persistent = true }
})

-- Create UI that reacts to these elements
Create("ScreenGui"){
    Parent = PlayerGui,
    Children = {
        Create("Frame"){ -- Tutorial Page
            Name = "TutorialFrame",
            Size = UDim2.fromScale(0.8, 0.8),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(50, 50, 150),

            Visible = tutorialPageElement, -- Reactive visibility

            [Ref] = tutorialFrame, --Set the reference to this Frame

            Children = {
                Create("TextLabel"){ Text = "Tutorial Page", Size = UDim2.fromScale(1,0.1)}
            }
        },
        Create("Frame"){ -- Home Page
            Name = "HomeFrame",
            Size = UDim2.fromScale(0.7, 0.7),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(50, 150, 50),

            Visible = homePageElement, -- Reactive visibility

            Children = {
                Create("TextLabel"){ Text = "Home Page", Size = UDim2.fromScale(1,0.1)}
            }
        }
    }
}

--When the tutorialPageElement params are changed by the Router, we'll apply the specific key `customParam`'s value to the tutorialFrame.
Watch(
    function() return tutorialPageElement:params(), "customParam" end,
    function(new) Give(tutorialFrame:get()) { Name = new } end
)

-- Listen to route changes
Router:onChange(function(newPath, oldPath)
    print(string.format("Route changed from '%s' to '%s'", oldPath, newPath))
end)

-- Navigate
task.wait(1)
print("Navigating to /tutorial")
Router:to("/tutorial", { customParam = "hello from tutorial start" })

task.wait(3)
print("Navigating to /home")
Router:to("/home") -- tutorialPageElement becomes false, homePageElement becomes true

task.wait(3)
print("Navigating to /tutorial again")
Router:to("/tutorial") -- homePageElement remains true (persistent), tutorialPageElement becomes true

task.wait(3)
print("Exiting /tutorial (not /home because it's persistent from this level)")
Router:exit("/tutorial") -- tutorialPageElement becomes false

task.wait(3)
print("Exiting /home")
Router:exit("/home") -- homePageElement becomes false
```

## 8. Utility Functions

### Chemical Await

* **`Chemical.Await(chemicalObject: Value<any> | Computed<any>): T`**
  Yields the current thread until the provided `chemicalObject` (a `Value`, `Computed`, `Element`, or `Router`) changes its value at least once *after* `Await` is called. It resolves with no arguments once the change occurs. Essentially, it's a promise that resolves on the next change.
  * **Note:** This uses `Promise.new` internally and `observer:onChange`. The actual return value `T` here is effectively `void` from the promise's perspective (it resolves with no values). Its primary use is to pause execution until a specific reactive data point is known to have received an update.

### Chemical Destroy

* **`Chemical.Destroy(subject: Destroyable)`**
  A versatile cleanup function that attempts to properly destroy or disconnect various types of objects:
  * Objects with a `:destroy()` (or `:Destroy()`) method (like Chemical primitives).
  * Tables: Clears them and sets their metatable to nil. If elements within are `Destroyable`, recursively calls `Chemical.Destroy` on them.
  * Roblox `Instance`s: Calls `instance:Destroy()`.
  * `RBXScriptConnection`s: Calls `connection:Disconnect()`. - In the future, it will be possible to handle ConnectionLike objects.
  * Functions: Calls the function (intended for disconnect functions).
  * Threads: Calls `task.cancel(thread)`.
  * Tables: Recurscively calls `Chemical.Destroy(Table)`.

## 9. Under The Hood (Advanced)

### Networking (`Packages.Packet`)

The `Chemical.Reaction` system leverages these `Packet` definitions for its `Construct`, `Deconstruct`, `UpdateRoot`, `UpdateNested`, `Ready`, and `Hydrate` operations.

## 10. Type System

Chemical heavily utilizes Luau's type annotation system for improved code clarity, maintainability, and editor intellisense.

* **Root `Types.lua`:** Defines the public interface types for core Chemical objects like `Value<T>`, `Computed<T>`, `Observer`, `Element`, and `Reaction`.
* **`Types/Gui.lua` & `Types/Gui/Overrides.lua`:** Provide exhaustive type definitions for Roblox GUI object properties (`FrameProperties`, `TextLabelProperties`, etc.) and event names/signatures. These are crucial for the type-safe/intellisense usage of `Chemical.Create` and `Chemical.Give`.
* **Inline Type Annotations:** Throughout the codebase, functions, variables, and table fields are typed.

## 11. Examples

The `Chemical/Examples` (Script) and `Chemical/Examples` (LocalScript) provide practical demonstrations:

* **Server-Side (`Examples` Script):**
  * Demonstrates creating a per-player `Reaction` with nested `Value` objects.
  * Shows how the server defines the reaction's state and structure.
  * The `export type Type` defines the expected structure of the client-side reaction object for better type safety on the client.
* **Client-Side (`Examples` LocalScript):**
  * Uses `Chemical.Router` to define simple routes.
  * Uses `Chemical.Create` to build UI elements.
  * Demonstrates binding UI properties (like `Visible` and `BackgroundColor3`) to `Chemical.Element` and `Chemical.Value` objects, respectively.
  * Shows how to use `[Chemical.Ref]` to get a reference to a created UI element.
  * Illustrates connecting to UI events using `[Chemical.onEvent]`.
  * Shows basic router navigation with `:to()` and `:exit()`.
