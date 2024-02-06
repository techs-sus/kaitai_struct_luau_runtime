-- Patch the global require for use of kaitai_struct_luau_runtime
do
	local BASE_URL = "https://github.com/techs-sus/kaitai_struct_luau_runtime/raw/master/"
	local REQUIRE_MAP = {
		["class"] = BASE_URL .. "class.lua",
		["enum"] = BASE_URL .. "enum.lua",
		["kaitaistruct"] = BASE_URL .. "kaitaistruct.lua",
		["string_decode"] = BASE_URL .. "string_decode.lua",
		["string_stream"] = BASE_URL .. "string_stream.lua",
		["utils"] = BASE_URL .. "utils.lua",
		["zzlib"] = BASE_URL .. "zzlib.lua",
	}

	local REQUIRE_CACHE = {}
	local REQUIRE_CACHE_SIZE = 0

	for module, url in REQUIRE_MAP do
		task.spawn(function()
			REQUIRE_CACHE[module] = game:GetService("HttpService"):GetAsync(url)
			REQUIRE_CACHE_SIZE += 1
		end)
	end

	while REQUIRE_CACHE_SIZE < 7 do
		task.wait()
	end

	local patchedRequire
	patchedRequire = function(module)
		local url = REQUIRE_MAP[module]
		if not url then
			error(`{module} is not in the REQUIRE_MAP`)
		end

		local patchedEnvironment = setmetatable({
			require = patchedRequire,
		}, getfenv())

		local fn = assert(setfenv(assert(loadstring(REQUIRE_CACHE[module])), patchedEnvironment))
		return fn()
	end

	require = patchedRequire
end
