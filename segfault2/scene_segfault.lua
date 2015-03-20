function LoadSPH(property)
	local sphloader
	sphloader = SPHLoader()
	sphloader:Load(property.filepath)
	return sphloader
end

function UniformFloat(arg)
	local name = arg.name
	local val  = arg.val
	return {
		uniform = function()
			return {name=name, value=val, type='float'}
		end
	}
end
function CreateVolumeModel(property)
	local vm = VolumeModel();
	vm:Create(property.volume);
	vm:SetTranslate(property.translate[1], property.translate[2], property.translate[3])
	vm:SetRotate(property.rotate[1], property.rotate[2], property.rotate[3])
	vm:SetScale(property.scale[1], property.scale[2], property.scale[3])
	vm:SetShader(property.shadername)
	local uniforms = property.Uniform
	for i,v in pairs(uniforms) do
		if v.type == 'vec4' then
			print('vec4[' .. v.name .. '] = (', v.value[1], v.value[2], v.value[3], v.value[4], ')')
			vm:SetVec4(v.name, v.value[1], v.value[2], v.value[3], v.value[4])
		end
		if v.type == 'vec3' then
			print('vec3[' .. v.name .. '] = (', v.value[1], v.value[2], v.value[3], ')')
			vm:SetVec3(v.name, v.value[1], v.value[2], v.value[3])
		end
		if v.type == 'vec2' then
			print('vec2[' .. v.name .. '] = (', v.value[1], v.value[2], ')')
			vm:SetVec2(v.name, v.value[1], v.value[2])
		end
		if v.type == 'float' then
			print('float[' .. v.name .. '] = (', v.value, ')')
			vm:SetFloat(v.name, v.value)
		end
	end
	function getModel()
		return vm
	end
	return {
		model=getModel
	}
end

function CreateCamera(property)
	local cam;	
	print('create camera',
		property.screensize[1], property.screensize[2],
		property.filename)
	cam = Camera()
	cam:SetScreenSize(property.screensize[1], property.screensize[2])
	cam:SetFilename(property.filename)
	cam:LookAt(
		property.position[1], property.position[2], property.position[3],
		property.target[1], property.target[2], property.target[3],
		property.up[1], property.up[2], property.up[3],
		property.fov
	)
	
	function camera()
		return cam
	end
	return {
		camera = camera
	}
end

function Render(arg)
	render(arg.RenderObject)
end
-- Generated by NodeEditor

function getFile(frame)
    frame = frame % 40
    local time = frame*40+7080
    return 'data/qcr_000000' .. time .. '.sph'
end

function getCameraPosition(frame)
    --return {-160+frame*2, -160+frame*2,-160+frame*2}
    return {-160, -160,-160}
    --return {200, 200*math.sin(frame/160*2*math.pi), 200*math.cos(frame/160*2*math.pi)} --turning
end
function getCameraUp(frame)
    --if(frame<160/4) then
    --    return {-1,0,0}
    --elseif(frame<160*3/4) then
    --    return {1,0,0}
    --else
    --    return {-1,0,0}
    --end
    return {-1,0,0}
end

function getRotation(frame)
    --return {0,0,0}
    return {frame/160*360,0,0}
end
function getCameraTarget(frame)
    return {20,0,0}
end

function frameToString(frame)
    local frame_count
    if(frame<10) then frame_count = '00' .. frame
    elseif(frame<100) then frame_count = '0' .. frame
    else frame_count = frame
    end
    return frame_count
end
--local shader = 'normal.frag' -- this one does not work at all!
--local shader = 'volume.frag'
--local shader = 'def_volume_contour.frag'
local shader = 'def_volume_raymarch_texture.frag.c'
local size = {512,512}
local output = 'raymarch_selfrotate_centered'

for i=0,159 do
    print('\n\nGenerating frame ' .. frameToString(i) .. '\n')
    local instSPHLoader1 = LoadSPH({filepath=getFile(i)})
    local instUniformFloat7 = UniformFloat({name='depth', val=instSPHLoader1:Depth()})
    local instUniformFloat6 = UniformFloat({name='height', val=instSPHLoader1:Height()})
    local instUniformFloat5 = UniformFloat({name='width', val=instSPHLoader1:Width()})
    local instVolumeModel3 = CreateVolumeModel({volume=instSPHLoader1:VolumeData(), translate={0,0,0}, rotate=getRotation(i), scale={1,1,1}, shadername=shader, Uniform={Uniform0=instUniformFloat5:uniform(), Uniform1=instUniformFloat6:uniform(), Uniform2=instUniformFloat7:uniform()}})
    local instCreateCamera2 = CreateCamera({position=getCameraPosition(i), target=getCameraTarget(i), up=getCameraUp(i), fov = 70, screensize=size, filename=output .. frameToString(i) .. '.jpg'})
    local root4 = Render({RenderObject={RenderObject0=instCreateCamera2:camera(), RenderObject1=instVolumeModel3:model(), nil}})
end
-- Generated Footer by NodeEditor
