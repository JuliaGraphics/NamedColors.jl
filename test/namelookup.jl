
@testset "named lookup" begin
	@test_throws UnknownColorError named_color("redish")

	try
		named_color("Steal Blue")

	catch ex
		@test occursin("Steel Blue", ex.msg)
	end

	similar_names = NamedColors.similarly_named_colors("Razzle Dazzle Nose")
	@test similar_names[1] == "Razzle Dazzle Rose"
	@test similar_names isa Vector{String}
end

@testset "colorant_str macro gets named colors" begin
	@test colorant"moderatepurple" == reinterpret(RGB24, 0x86608e)
	@test colorant"Cold Purple" == reinterpret(RGB24, 0xaba0d9)
	@test colorant"Maximum Purple" == reinterpret(RGB24, 0x733380)
	@test colorant"purple lake light" == reinterpret(RGB24, 0x784D63)
end

@testset "colorant_str macro gets original functionality" begin
	@test colorant"#32cd32" == RGB{N0f8}(0.196,0.804,0.196)
	@test colorant"purple" == RGB{N0f8}(0.502,0.0,0.502)
end
