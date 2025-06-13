local ECS = require(script.Parent.Packages.JECS)

local module = {}

export type HasEntity = {
	entity: ECS.Entity
}

export type MaybeDestroyable = {
	__internalDestroy: (MaybeDestroyable) -> (),
}

export type MaybeCleanable = {
	clean: (MaybeCleanable) -> ()
}

return module
