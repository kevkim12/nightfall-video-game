--!nocheck
-- ^ change to strict to crash studio c:

-- Defines all FC types.
-- Any script that requires this will have these types defined.

--[[
local TypeDefs = require(script.TypeDefinitions)
type CanPenetrateFunction = TypeDefs.CanPenetrateFunction
type CanHitFunction = TypeDefs.CanHitFunction
type GenericTable = TypeDefs.GenericTable
type Caster = TypeDefs.Caster
type FastCastBehavior = TypeDefs.FastCastBehavior
type CastTrajectory = TypeDefs.CastTrajectory
type CastStateInfo = TypeDefs.CastStateInfo
type CastRayInfo = TypeDefs.CastRayInfo
type ActiveCast = TypeDefs.ActiveCast
--]]

-- Represents the function to determine piercing and hitting.
export type CanPenetrateFunction = (ActiveCast, RaycastResult, Vector3) -> boolean
export type CanHitFunction = (ActiveCast, RaycastResult, Vector3) -> boolean

-- Represents any table.
export type GenericTable = {[any]: any}

-- Represents a Caster :: https://etithespirit.github.io/FastCastAPIDocs/fastcast-objects/caster/
export type Caster = {
	WorldRoot: WorldRoot,
	LengthChanged: RBXScriptSignal,
	RayFinalHit: RBXScriptSignal,
	RayHit: RBXScriptSignal,
	RayPenetrated: RBXScriptSignal,
	CastTerminating: RBXScriptSignal,
	Fire: (Vector3, Vector3, Vector3 | number, FastCastBehavior) -> ()
}

-- Represents a FastCastBehavior :: https://etithespirit.github.io/FastCastAPIDocs/fastcast-objects/fcbehavior/
export type FastCastBehavior = {
	RaycastParams: RaycastParams?,
	TravelType: string,
	MaxDistance: number,
	Lifetime: number,
	Acceleration: Vector3,
	HighFidelityBehavior: number,
	HighFidelitySegmentSize: number,
	CosmeticBulletTemplate: Instance?,
	CosmeticBulletProvider: any, -- Intended to be a PartCache. Dictated via TypeMarshaller.
	CosmeticBulletContainer: Instance?,
	RaycastHitbox: GenericTable,
	CurrentCFrame: CFrame,
	ModifiedDirection: Vector3,
	AutoIgnoreContainer: boolean,
	HitEventOnTermination: boolean,
	Hitscan: boolean,
	CanPenetrateFunction: CanPenetrateFunction,
	CanHitFunction: CanHitFunction,
}

-- Represents a CastTrajectory :: https://etithespirit.github.io/FastCastAPIDocs/fastcast-objects/casttrajectory/
export type CastTrajectory = {
	StartTime: number,
	EndTime: number,
	Origin: Vector3,
	InitialVelocity: Vector3,
	Acceleration: Vector3
}

-- Represents a CastStateInfo :: https://etithespirit.github.io/FastCastAPIDocs/fastcast-objects/caststateinfo/
export type CastStateInfo = {
	UpdateConnection: RBXScriptSignal,
	HighFidelityBehavior: number,
	HighFidelitySegmentSize: number,
	Paused: boolean,
	Delta: number,
	TotalRuntime: number,
	TotalRuntime2: number,
	DistanceCovered: number,
	IsActivelySimulatingPenetrate: boolean,
	IsActivelyResimulating: boolean,
	CancelHighResCast: boolean,
	Trajectories: {[number]: CastTrajectory},
	TweenTable: GenericTable
}

-- Represents a CastRayInfo :: https://etithespirit.github.io/FastCastAPIDocs/fastcast-objects/castrayinfo/
export type CastRayInfo = {
	Parameters: RaycastParams,
	WorldRoot: WorldRoot,	
	TravelType: string,
	MaxDistance: number,
	Lifetime: number,
	CosmeticBulletObject: Instance?,
	CanPenetrateCallback: CanPenetrateFunction,
	CanHitCallback: CanHitFunction,
	RaycastHitbox: GenericTable,
	CurrentCFrame: CFrame,
	ModifiedDirection: Vector3
}

-- Represents an ActiveCast :: https://etithespirit.github.io/FastCastAPIDocs/fastcast-objects/activecast/
export type ActiveCast = {
	Caster: Caster,
	StateInfo: CastStateInfo,
	RayInfo: CastRayInfo,
	UserData: {[any]: any}
}

return {}