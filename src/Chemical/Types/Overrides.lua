--!strict
local Gui = require(script.Parent.Gui)

-- Define the custom method we're adding.
type CompositionHandle = {
	Destroy: (self: CompositionHandle) -> ()
}

-- The factory function now returns an intersection type.
-- It tells Luau "this object has all the properties of P AND all the properties of CompositionHandle".
type ComposerFactory<P> = (blueprint: P) -> (P & CompositionHandle)

-- The overloads remain the same, but their return type is now more powerful.
export type ComposeFunction = (
	-- Overloads for creating new instances via class name strings
	((target: "Frame") -> ComposerFactory<Gui.FrameProperties>) &
	((target: "TextLabel") -> ComposerFactory<Gui.TextLabelProperties>) &
	((target: "ImageLabel") -> ComposerFactory<Gui.ImageLabelProperties>) &
	((target: "TextButton") -> ComposerFactory<Gui.TextButtonProperties>) &
	((target: "ImageButton") -> ComposerFactory<Gui.ImageButtonProperties>) &
	((target: "TextBox") -> ComposerFactory<Gui.TextBoxProperties>) &
	((target: "ScrollingFrame") -> ComposerFactory<Gui.ScrollingFrameProperties>) &
	((target: "ViewportFrame") -> ComposerFactory<Gui.ViewportFrameProperties>) &
	((target: "CanvasGroup") -> ComposerFactory<Gui.CanvasGroupProperties>) &
	((target: "UIListLayout") -> ComposerFactory<Gui.UIListLayoutProperties>) &
	((target: "UIGridLayout") -> ComposerFactory<Gui.UIGridLayoutProperties>) &
	((target: "UICorner") -> ComposerFactory<Gui.UICornerProperties>) &
	((target: "UIStroke") -> ComposerFactory<Gui.UIStrokeProperties>) &
	((target: "UIGradient") -> ComposerFactory<Gui.UIGradientProperties>) &
	((target: "UIPadding") -> ComposerFactory<Gui.UIPaddingProperties>) &
	((target: "UIScale") -> ComposerFactory<Gui.UIScaleProperties>) &
	((target: "UIAspectRatioConstraint") -> ComposerFactory<Gui.UIAspectRatioConstraintProperties>) &
	((target: "UISizeConstraint") -> ComposerFactory<Gui.UISizeConstraintProperties>) &
	((target: "BillboardGui") -> ComposerFactory<Gui.BillboardGuiProperties>) &
	((target: "SurfaceGui") -> ComposerFactory<Gui.SurfaceGuiProperties>) &
	((target: "ScreenGui") -> ComposerFactory<Gui.ScreenGuiProperties>) &

	-- Overloads for adopting existing instances
	((target: Frame) -> ComposerFactory<Gui.FrameProperties>) &
	((target: TextLabel) -> ComposerFactory<Gui.TextLabelProperties>) &
	((target: ImageLabel) -> ComposerFactory<Gui.ImageLabelProperties>) &
	((target: TextButton) -> ComposerFactory<Gui.TextButtonProperties>) &
	((target: ImageButton) -> ComposerFactory<Gui.ImageButtonProperties>) &
	((target: TextBox) -> ComposerFactory<Gui.TextBoxProperties>) &
	((target: ScrollingFrame) -> ComposerFactory<Gui.ScrollingFrameProperties>) &
	((target: ViewportFrame) -> ComposerFactory<Gui.ViewportFrameProperties>) &
	((target: CanvasGroup) -> ComposerFactory<Gui.CanvasGroupProperties>) &
	((target: UIListLayout) -> ComposerFactory<Gui.UIListLayoutProperties>) &
	((target: UIGridLayout) -> ComposerFactory<Gui.UIGridLayoutProperties>) &
	((target: UICorner) -> ComposerFactory<Gui.UICornerProperties>) &
	((target: UIStroke) -> ComposerFactory<Gui.UIStrokeProperties>) &
	((target: UIGradient) -> ComposerFactory<Gui.UIGradientProperties>) &
	((target: UIPadding) -> ComposerFactory<Gui.UIPaddingProperties>) &
	((target: UIScale) -> ComposerFactory<Gui.UIScaleProperties>) &
	((target: UIAspectRatioConstraint) -> ComposerFactory<Gui.UIAspectRatioConstraintProperties>) &
	((target: UISizeConstraint) -> ComposerFactory<Gui.UISizeConstraintProperties>) &
	((target: BillboardGui) -> ComposerFactory<Gui.BillboardGuiProperties>) &
	((target: SurfaceGui) -> ComposerFactory<Gui.SurfaceGuiProperties>) &
	((target: ScreenGui) -> ComposerFactory<Gui.ScreenGuiProperties>) &

	-- Fallback overloads for generic/unspecified types
	((target: string) -> ComposerFactory<Gui.GuiBaseProperties>) &
	((target: GuiObject) -> ComposerFactory<Gui.GuiBaseProperties>)
)

return {}