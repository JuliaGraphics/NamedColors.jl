using NamedColors
using Base.Test
using ColorTypes

@testset "xkcd" begin
	xkcd = load_xkcd()
	@test length(xkcd) == 949
	@test xkcd["purple"] == RGB24(0.494,0.118,0.612)
end


@testset "Resene" begin
	resene = load_resene()
	@test length(resene) == 1383
	@test resene["Cold Purple"] == RGB24(0xaba0d9)
end


@testset "NBS" begin
	data = load_nbs()
	@test length(data) == 267
	@test data["moderatepurple"] == RGB24(0x86608e)
end

@testset "X11" begin
	data = load_x11()
	@test length(data) > 200
	@test data["purple"] == RGB24(0xa020f0)
end


@testset "CSS3" begin
	data = load_css3()
	@test length(data) == 16
	@test data["purple"] == RGB24(0x800080)
end


@testset "Crayola" begin
	data = load_crayola()
	@test length(data) == 195 #Note, there seems to be a duplicate
	@test data["Maximum Purple"] == RGB24(0x733380)
end


