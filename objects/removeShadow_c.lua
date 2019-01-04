local shader = dxCreateShader("texReplace.fx")
local texture = dxCreateTexture(1, 1)
dxSetShaderValue(shader, "tex0", texture)
engineApplyShaderToWorldTexture(shader, "shad_ped")