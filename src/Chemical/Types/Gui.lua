type Stateful<T> = { set: (T) -> (), get: () -> (T), __entity: number }

export type GuiBaseProperties = {
	Name: (Stateful<string> | string)?,
	Visible: (Stateful<boolean> | boolean)?,
	Active: (Stateful<boolean> | boolean)?,
	AnchorPoint: (Stateful<Vector2> | Vector2)?,
	Position: (Stateful<UDim2> | UDim2)?,
	Size: (Stateful<UDim2> | UDim2)?,
	Rotation: (Stateful<number> | number)?,
	ZIndex: (Stateful<number> | number)?,
	LayoutOrder: (Stateful<number> | number)?,
	BackgroundTransparency: (Stateful<number> | number)?,
	BackgroundColor3: (Stateful<Color3> | Color3)?,
	BorderSizePixel: (Stateful<number> | number)?,
	BorderColor3: (Stateful<Color3> | Color3)?,
	ClipsDescendants: (Stateful<boolean> | boolean)?,
	Selectable: (Stateful<boolean> | boolean)?,
	Parent: GuiObject?,
	Children: { [number]: Instance | Stateful<GuiObject> },
	
	[any]: (() -> ())?
}

type GuiBaseEvents = {
	InputBegan: (input: InputObject, gameProcessed: boolean) -> (),
	InputEnded: (input: InputObject, gameProcessed: boolean) -> (),
	InputChanged: (input: InputObject, gameProcessed: boolean) -> (),

	-- Mouse Events
	MouseEnter: () -> (),
	MouseLeave: () -> (),
	MouseMoved: (deltaX: number, deltaY: number) -> (),
	MouseWheelForward: (scrollDelta: number) -> (),
	MouseWheelBackward: (scrollDelta: number) -> (),

	-- Touch Events
	TouchTap: (touchPositions: {Vector2}, state: Enum.UserInputState) -> (),
	TouchPinch: (scale: number, velocity: number, state: Enum.UserInputState) -> (),
	TouchPan: (pan: Vector2, velocity: Vector2, state: Enum.UserInputState) -> (),
	TouchSwipe: (direction: Enum.SwipeDirection, touches: number) -> (),
	TouchRotate: (rotation: number, velocity: number, state: Enum.UserInputState) -> (),
	TouchLongPress: (duration: number) -> (),

	-- Console/Selection Events
	SelectionGained: () -> (),
	SelectionLost: () -> (),
	SelectionChanged: (newSelection: Instance) -> (),
}

type ImageGuiProperties = GuiBaseProperties & {
	Image: (Stateful<string> | string)?,
	ImageColor3: (Stateful<Color3> | Color3)?,
	ImageTransparency: (Stateful<number> | number)?,
	ScaleType: (Stateful<Enum.ScaleType> | Enum.ScaleType)?,
	SliceCenter: (Stateful<Rect> | Rect)?,
	TileSize: (Stateful<UDim2> | UDim2)?,
	ResampleMode: (Stateful<Enum.ResamplerMode> | Enum.ResamplerMode)?,
}

type TextGuiProperties = GuiBaseProperties & {
	Text: (Stateful<string> | string)?,
	TextColor3: (Stateful<Color3> | Color3)?,
	TextTransparency: (Stateful<number> | number)?,
	TextStrokeColor3: (Stateful<Color3> | Color3)?,
	TextStrokeTransparency: (Stateful<number> | number)?,
	TextScaled: (Stateful<boolean> | boolean)?,
	TextSize: (Stateful<number> | number)?,
	TextWrapped: (Stateful<boolean> | boolean)?,
	FontFace: (Stateful<Font> | Font)?,
	LineHeight: (Stateful<number> | number)?,
	RichText: (Stateful<boolean> | boolean)?,
	TextXAlignment: (Stateful<Enum.TextXAlignment> | Enum.TextXAlignment)?,
	TextYAlignment: (Stateful<Enum.TextYAlignment> | Enum.TextYAlignment)?,
	TextTruncate: (Stateful<Enum.TextTruncate> | Enum.TextTruncate)?,
	[any]: (() -> ())?,
}

export type FrameProperties = GuiBaseProperties
export type TextLabelProperties = TextGuiProperties
export type ImageLabelProperties = ImageGuiProperties

-- Interactive Elements
type ButtonEvents = GuiBaseEvents & {
	Activated: (inputType: Enum.UserInputType?) -> (),
	MouseButton1Click: () -> (),
	MouseButton2Click: () -> (),
	MouseButton2Down: () -> (),
	MouseButton2Up: () -> (),
	
	MouseWheelForward: nil,
	MouseWheelBackward: nil,
}

export type ButtonProperties = {
	AutoButtonColor: (Stateful<boolean> | boolean)?,
	Modal: (Stateful<boolean> | boolean)?,
	Selected: (Stateful<boolean> | boolean)?,
	
	ButtonHoverStyle: (Stateful<Enum.ButtonStyle> | Enum.ButtonStyle)?,
	ButtonPressStyle: (Stateful<Enum.ButtonStyle> | Enum.ButtonStyle)?,
	ActivationBehavior: (Stateful<Enum.ActivationBehavior> | Enum.ActivationBehavior)?,

	SelectionGroup: (Stateful<number> | number)?,
	SelectionBehaviorUp: (Stateful<Enum.SelectionBehavior> | Enum.SelectionBehavior)?,
	SelectionBehaviorDown: (Stateful<Enum.SelectionBehavior> | Enum.SelectionBehavior)?,
	SelectionBehaviorLeft: (Stateful<Enum.SelectionBehavior> | Enum.SelectionBehavior)?,
	SelectionBehaviorRight: (Stateful<Enum.SelectionBehavior> | Enum.SelectionBehavior)?,
	GamepadPriority: (Stateful<number> | number)?,
}


export type TextButtonProperties = TextGuiProperties & ButtonProperties
export type ImageButtonProperties = ImageGuiProperties & ButtonProperties

type TextBoxEvents = GuiBaseEvents & {
	FocusLost: (enterPressed: boolean) -> (),
	FocusGained: () -> (),
	TextChanged: (text: string) -> (),
}

export type TextBoxProperties = TextGuiProperties & {
	ClearTextOnFocus: (Stateful<boolean> | boolean)?,
	MultiLine: (Stateful<boolean> | boolean)?,
	PlaceholderText: (Stateful<string> | string)?,
	PlaceholderColor3: (Stateful<Color3> | Color3)?,
	CursorPosition: (Stateful<number> | number)?,
	SelectionStart: (Stateful<number> | number)?,
	ShowNativeInput: (Stateful<boolean> | boolean)?,
	TextInputType: (Stateful<Enum.TextInputType> | Enum.TextInputType)?,
}


-- Containers
type ScrollingFrameEvents = GuiBaseEvents & {
	Scrolled: (scrollVelocity: Vector2) -> (),
}

export type ScrollingFrameProperties = FrameProperties & {
	ScrollBarImageColor3: (Stateful<Color3> | Color3)?,
	ScrollBarThickness: (Stateful<number> | number)?,
	ScrollingDirection: (Stateful<Enum.ScrollingDirection> | Enum.ScrollingDirection)?,
	CanvasSize: (Stateful<UDim2> | UDim2)?,
	CanvasPosition: (Stateful<Vector2> | Vector2)?,
	AutomaticCanvasSize: (Stateful<Enum.AutomaticSize> | Enum.AutomaticSize)?,
	VerticalScrollBarInset: (Stateful<Enum.ScrollBarInset> | Enum.ScrollBarInset)?,
	HorizontalScrollBarInset: (Stateful<Enum.ScrollBarInset> | Enum.ScrollBarInset)?,
	ScrollBarImageTransparency: (Stateful<number> | number)?,
	ElasticBehavior: (Stateful<Enum.ElasticBehavior> | Enum.ElasticBehavior)?,
	VerticalScrollBarPosition: (Stateful<Enum.VerticalScrollBarPosition> | Enum.VerticalScrollBarPosition)?,
}

type ViewportFrameEvents = GuiBaseEvents & {
	ViewportResized: (newSize: Vector2) -> (),
	CameraChanged: (newCamera: Camera) -> (),
}

export type ViewportFrameProperties = FrameProperties & {
	CurrentCamera: (Stateful<Camera> | Camera)?,
	ImageColor3: (Stateful<Color3> | Color3)?,
	LightColor: (Stateful<Color3> | Color3)?,
	LightDirection: (Stateful<Vector3> | Vector3)?,
	Ambient: (Stateful<Color3> | Color3)?,
	LightAngularInfluence: (Stateful<number> | number)?,
}

-- Layouts
export type UIListLayoutProperties = {
	Padding: (Stateful<UDim> | UDim)?,
	FillDirection: (Stateful<Enum.FillDirection> | Enum.FillDirection)?,
	HorizontalAlignment: (Stateful<Enum.HorizontalAlignment> | Enum.HorizontalAlignment)?,
	VerticalAlignment: (Stateful<Enum.VerticalAlignment> | Enum.VerticalAlignment)?,
	SortOrder: (Stateful<Enum.SortOrder> | Enum.SortOrder)?,
	Appearance: (Stateful<Enum.Appearance> | Enum.Appearance)?,
}

export type UIGridLayoutProperties = {
	CellSize: (Stateful<UDim2> | UDim2)?,
	CellPadding: (Stateful<UDim2> | UDim2)?,
	StartCorner: (Stateful<Enum.StartCorner> | Enum.StartCorner)?,
	FillDirection: (Stateful<Enum.FillDirection> | Enum.FillDirection)?,
	HorizontalAlignment: (Stateful<Enum.HorizontalAlignment> | Enum.HorizontalAlignment)?,
	VerticalAlignment: (Stateful<Enum.VerticalAlignment> | Enum.VerticalAlignment)?,
	SortOrder: (Stateful<Enum.SortOrder> | Enum.SortOrder)?,
}

-- Style Elements
export type UICornerProperties = {
	CornerRadius: (Stateful<UDim> | UDim)?,
}

export type UIStrokeProperties = {
	Color: (Stateful<Color3> | Color3)?,
	Thickness: (Stateful<number> | number)?,
	Transparency: (Stateful<number> | number)?,
	Enabled: (Stateful<boolean> | boolean)?,
	ApplyStrokeMode: (Stateful<Enum.ApplyStrokeMode> | Enum.ApplyStrokeMode)?,
	LineJoinMode: (Stateful<Enum.LineJoinMode> | Enum.LineJoinMode)?,
}

export type UIGradientProperties = {
	Color: (Stateful<ColorSequence> | ColorSequence)?,
	Transparency: (Stateful<NumberSequence> | NumberSequence)?,
	Offset: (Stateful<Vector2> | Vector2)?,
	Rotation: (Stateful<number> | number)?,
	Enabled: (Stateful<boolean> | boolean)?,
}

export type UIPaddingProperties = {
	PaddingTop: (Stateful<UDim> | UDim)?,
	PaddingBottom: (Stateful<UDim> | UDim)?,
	PaddingLeft: (Stateful<UDim> | UDim)?,
	PaddingRight: (Stateful<UDim> | UDim)?,
}

export type UIScaleProperties = {
	Scale: (Stateful<number> | number)?,
}


type CanvasMouseEvents = GuiBaseEvents & {
	MouseWheel: (direction: Enum.MouseWheelDirection, delta: number) -> (),
}

export type CanvasGroupProperties = {
	GroupTransparency: (Stateful<number> | number)?,
	GroupColor3: (Stateful<Color3> | Color3)?,
} & CanvasMouseEvents

-- Constraints
export type UIAspectRatioConstraintProperties = {
	AspectRatio: (Stateful<number> | number)?,
	AspectType: (Stateful<Enum.AspectType> | Enum.AspectType)?,
	DominantAxis: (Stateful<Enum.DominantAxis> | Enum.DominantAxis)?,
}

export type UISizeConstraintProperties = {
	MinSize: (Stateful<Vector2> | Vector2)?,
	MaxSize: (Stateful<Vector2> | Vector2)?,
}

-- Specialized
export type BillboardGuiProperties = GuiBaseProperties & {
	Active: (Stateful<boolean> | boolean)?,
	AlwaysOnTop: (Stateful<boolean> | boolean)?,
	LightInfluence: (Stateful<number> | number)?,
	MaxDistance: (Stateful<number> | number)?,
	SizeOffset: (Stateful<Vector2> | Vector2)?,
	StudsOffset: (Stateful<Vector3> | Vector3)?,
	ExtentsOffset: (Stateful<Vector3> | Vector3)?,
}

export type SurfaceGuiProperties = GuiBaseProperties & {
	Active: (Stateful<boolean> | boolean)?,
	AlwaysOnTop: (Stateful<boolean> | boolean)?,
	Brightness: (Stateful<number> | number)?,
	CanvasSize: (Stateful<Vector2> | Vector2)?,
	Face: (Stateful<Enum.NormalId> | Enum.NormalId)?,
	LightInfluence: (Stateful<number> | number)?,
	PixelsPerStud: (Stateful<number> | number)?,
	SizingMode: (Stateful<Enum.SurfaceGuiSizingMode> | Enum.SurfaceGuiSizingMode)?,
	ToolPunchThroughDistance: (Stateful<number> | number)?,
}

export type ScreenGuiProperties = GuiBaseProperties & {
	Active: (Stateful<boolean> | boolean)?,
	AlwaysOnTop: (Stateful<boolean> | boolean)?,
	Brightness: (Stateful<number> | number)?,
	DisplayOrder: (Stateful<number> | number)?,
	IgnoreGuiInset: (Stateful<boolean> | boolean)?,
	OnTopOfCoreBlur: (Stateful<boolean> | boolean)?,
	ScreenInsets: (Stateful<Enum.ScreenInsets> | Enum.ScreenInsets)?,
	ZIndexBehavior: (Stateful<Enum.ZIndexBehavior> | Enum.ZIndexBehavior)?,
}

export type EventNames = (
	"InputBegan" | "InputEnded" | "InputChanged" |
	"MouseEnter" | "MouseLeave" | "MouseMoved" |
	"MouseButton1Down" | "MouseButton1Up" |
	"MouseWheelForward" | "MouseWheelBackward" |

	"TouchTap" | "TouchPinch" | "TouchPan" |
	"TouchSwipe" | "TouchRotate" | "TouchLongPress" |

	"SelectionGained" | "SelectionLost" | "SelectionChanged" |

	"Activated" | "MouseButton1Click" | "MouseButton2Click" |
	"MouseButton2Down" | "MouseButton2Up" |

	"FocusLost" | "FocusGained" | "TextChanged" |

	"Scrolled" |

	"ViewportResized" | "CameraChanged" |

	"BillboardTransformed" |

	"SurfaceChanged" |

	"GroupTransparencyChanged" |

	"StrokeUpdated" |

	"GradientOffsetChanged" |

	"ChildAdded" | "ChildRemoved" | "AncestryChanged"
)

export type PropertyNames = (
	"Name" | "Visible" | "Active" | "AnchorPoint" | "Position" | "Size" |
	"Rotation" | "ZIndex" | "LayoutOrder" | "BackgroundTransparency" |
	"BackgroundColor3" | "BorderSizePixel" | "BorderColor3" |
	"ClipsDescendants" | "Selectable" |

	"Image" | "ImageColor3" | "ImageTransparency" | "ScaleType" |
	"SliceCenter" | "TileSize" | "ResampleMode" |

	"Text" | "TextColor3" | "TextTransparency" | "TextStrokeColor3" |
	"TextStrokeTransparency" | "TextScaled" | "TextSize" | "TextWrapped" |
	"FontFace" | "LineHeight" | "RichText" | "TextXAlignment" |
	"TextYAlignment" | "TextTruncate" |

	"AutoButtonColor" | "Modal" | "Selected" | "ButtonHoverStyle" |
	"ButtonPressStyle" | "ActivationBehavior" | "SelectionGroup" |
	"SelectionBehaviorUp" | "SelectionBehaviorDown" |
	"SelectionBehaviorLeft" | "SelectionBehaviorRight" | "GamepadPriority" |

	"ClearTextOnFocus" | "MultiLine" | "PlaceholderText" |
	"PlaceholderColor3" | "CursorPosition" | "SelectionStart" |
	"ShowNativeInput" | "TextInputType" |

	"ScrollBarImageColor3" | "ScrollBarThickness" | "ScrollingDirection" |
	"CanvasSize" | "CanvasPosition" | "AutomaticCanvasSize" |
	"VerticalScrollBarInset" | "HorizontalScrollBarInset" |
	"ScrollBarImageTransparency" | "ElasticBehavior" | "VerticalScrollBarPosition" |

	"CurrentCamera" | "LightColor" | "LightDirection" | "Ambient" |
	"LightAngularInfluence" |

	"Padding" | "FillDirection" | "HorizontalAlignment" | "VerticalAlignment" |
	"SortOrder" | "Appearance" | "CellSize" | "CellPadding" | "StartCorner" |

	"CornerRadius" | "Color" | "Thickness" | "Transparency" | "Enabled" |
	"ApplyStrokeMode" | "LineJoinMode" | "Offset" | "Rotation" |
	"PaddingTop" | "PaddingBottom" | "PaddingLeft" | "PaddingRight" | "Scale" |

	"GroupTransparency" | "GroupColor3" |

	"AspectRatio" | "AspectType" | "DominantAxis" | "MinSize" | "MaxSize" |

	"AlwaysOnTop" | "LightInfluence" | "MaxDistance" | "SizeOffset" |
	"StudsOffset" | "ExtentsOffset" |

	"Brightness" | "Face" | "PixelsPerStud" | "SizingMode" | "ToolPunchThroughDistance" |

	"Parent" | "Children"
)


return {}