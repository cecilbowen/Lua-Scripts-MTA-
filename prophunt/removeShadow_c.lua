local shader = dxCreateShader("noShadow.fx")
local texture = dxCreateTexture(1, 1)
dxSetShaderValue(shader, "tex0", texture)
engineApplyShaderToWorldTexture(shader, "shad_ped")