module Shapefile

import GeoInterface, DBFTables, Tables

using RecipesBase

# Types: could we move these to a shapes.jl file?

"""
    Rect

A rectangle object to represent the bounding box for other shape file shapes.
"""
struct Rect
    left::Float64
    bottom::Float64
    right::Float64
    top::Float64
end

"""
    Interval

Represents the range of measures or Z dimension, in a shape file.
"""
struct Interval
    left::Float64
    right::Float64
end

"""
    Point <: GeoInterface.AbstractPoint

Point from a shape file.

Fields `x`, `y` hold the spatial location.
"""
struct Point <: GeoInterface.AbstractPoint
    x::Float64
    y::Float64
end

"""
    PointM <: GeoInterface.AbstractPoint

Point from a shape file.

Fields `x`, `y` hold the spatial location.

Includes a measure field `m`, holding a value for the point.
"""
struct PointM <: GeoInterface.AbstractPoint
    x::Float64
    y::Float64
    m::Float64  # measure
end

"""
    PointZ <: GeoInterface.AbstractPoint

Three dimensional point, from a shape file.

Fields `x`, `y`, `z` hold the spatial location.

Includes a measure field `m`, holding a value for the point.
"""
struct PointZ <: GeoInterface.AbstractPoint
    x::Float64
    y::Float64
    z::Float64
    m::Float64  # measure
end

"""
    Polyline <: GeoInterface.AbstractMultiLineString

Represents a single or multiple polylines from a shape file.

# Fields
- `points`: a `Vector` of [`Point`](@ref) represents a one or multiple lines. 
- `parts`: a `Vector` of `Int32` indicating the line each point belongs to.
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
"""
struct Polyline <: GeoInterface.AbstractMultiLineString
    MBR::Rect
    parts::Vector{Int32}
    points::Vector{Point}
end

"""
    PolylineM <: GeoInterface.AbstractMultiLineString

Polyline from a shape file, with measures.

# Fields
- `points`: a `Vector` of [`Point`](@ref) represents a one or multiple lines. 
- `parts`: a `Vector` of `Int32` indicating the line each point belongs to.
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
- `measures`: holds values from each point.
"""
struct PolylineM <: GeoInterface.AbstractMultiLineString
    MBR::Rect
    parts::Vector{Int32}
    points::Vector{Point}
    measures::Vector{Float64}
end

"""
    PolylineZ <: GeoInterface.AbstractMultiLineString

Three dimensional polyline of from a shape file. 

# Fields
- `points`: a `Vector` of [`Point`](@ref) represents a one or multiple lines. 
- `parts`: a `Vector` of `Int32` indicating the line each point belongs to.
- `zvalues`: a `Vector` of `Float64` representing the z dimension values.
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
- `measures`: holds values from each point.
"""
struct PolylineZ <: GeoInterface.AbstractMultiLineString
    MBR::Rect
    parts::Vector{Int32}
    points::Vector{Point}
    zvalues::Vector{Float64}
    measures::Vector{Float64}
end

"""
    Polygon <: GeoInterface.AbstractMultiPolygon

Represents a polygon from a shape file. 

# Fields
- `points`: a `Vector` of [`Point`](@ref) represents a one or multiple closed areas. 
- `parts`: a `Vector` of `Int32` indicating the polygon each point belongs to.
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
"""
struct Polygon <: GeoInterface.AbstractMultiPolygon
    MBR::Rect
    parts::Vector{Int32}
    points::Vector{Point}
end

Base.show(io::IO, p::Polygon) =
    print(io, "Polygon(", length(p.points), " Points)")

"""
    PolygonM <: GeoInterface.AbstractMultiPolygon

Represents a polygon from a shape file

# Fields
- `points`: a `Vector` of [`Point`](@ref) represents a one or multiple closed areas. 
- `parts`: a `Vector` of `Int32` indicating the polygon each point belongs to.
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
- `measures`: holds values from each point.
"""
struct PolygonM <: GeoInterface.AbstractMultiPolygon
    MBR::Rect
    parts::Vector{Int32}
    points::Vector{Point}
    measures::Vector{Float64}
end

"""
    PolygonZ <: GeoInterface.AbstractMultiPolygon

A three dimensional polygon from a shape file.

# Fields
- `points`: a `Vector` of [`Point`](@ref) represents a one or multiple closed areas. 
- `parts`: a `Vector` of `Int32` indicating the polygon each point belongs to.
- `zvalues`: a `Vector` of `Float64` representing the z dimension values.
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
- `measures`: holds values from each point.
"""
struct PolygonZ <: GeoInterface.AbstractMultiPolygon
    MBR::Rect
    parts::Vector{Int32}
    points::Vector{Point}
    zvalues::Vector{Float64}
    measures::Vector{Float64}
end

"""
    MultiPoint <: GeoInterface.AbstractMultiPoint

Collection of points, from a shape file.

# Fields
- `points`: a `Vector` of [`Point`](@ref). 
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
"""
struct MultiPoint <: GeoInterface.AbstractMultiPoint
    MBR::Rect
    points::Vector{Point}
end

"""
    MultiPointM <: GeoInterface.AbstractMultiPoint

Collection of points, from a shape file. 

Includes a `measures` field, holding values from each point.

May have a known bounding box, which can be retrieved with `GeoInterface.bbox`.

# Fields
- `points`: a `Vector` of [`Point`](@ref). 
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
- `measures`: holds values from each point.
"""
struct MultiPointM <: GeoInterface.AbstractMultiPoint
    MBR::Rect
    points::Vector{Point}
    measures::Vector{Float64}
end

"""
    MultiPointZ <: GeoInterface.AbstractMultiPoint

# Fields
- `points`: a `Vector` of [`Point`](@ref). 
- `zvalues`: a `Vector` of `Float64` representing the z dimension values.
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
- `measures`: holds values from each point.
"""
struct MultiPointZ <: GeoInterface.AbstractMultiPoint
    MBR::Rect
    points::Vector{Point}
    zvalues::Vector{Float64}
    measures::Vector{Float64}
end

"""
    MultiPatch <: GeoInterface.AbstractGeometry

# Fields
- `points`: a `Vector` of [`Point`](@ref) represents a one or multiple spatial objects. 
- `parts`: a `Vector` of `Int32` indicating the object each point belongs to.
- `parttypes`: a `Vector` of `Int32` indicating the type of object each point belongs to.
- `MBR`: `nothing` or the known bounding box. Can be retrieved with `GeoInterface.bbox`.
"""
struct MultiPatch <: GeoInterface.AbstractGeometry
    MBR::Rect
    parts::Vector{Int32}
    parttypes::Vector{Int32}
    points::Vector{Point}
    zvalues::Vector{Float64}
    # measures::Vector{Float64}  # (optional)
end

const SHAPETYPE = Dict{Int32,DataType}(
    0 => Missing,
    1 => Point,
    3 => Polyline,
    5 => Polygon,
    8 => MultiPoint,
    11 => PointZ,
    13 => PolylineZ,
    15 => PolygonZ,
    18 => MultiPointZ,
    21 => PointM,
    23 => PolylineM,
    25 => PolygonM,
    28 => MultiPointM,
    31 => MultiPatch,
)

"""
    Handle

    Handle(path::AbstractString, [indexpath::AbstractString])

Load a shapefile into GeoInterface compatible objects. This can be plotted
with Plots.jl `plot`.

The Vector of shape object can be accessed with `shapes(handle)`.

`Handle` may have a known bounding box, which can be retrieved with `GeoInterface.bbox`.
"""
mutable struct Handle{T<:Union{<:GeoInterface.AbstractGeometry,Missing}}
    code::Int32
    length::Int32
    version::Int32
    shapeType::Int32
    MBR::Rect
    zrange::Interval
    mrange::Interval
    shapes::Vector{T}
end

function Handle(path::AbstractString, index=nothing)
    open(path) do io
        read(io, Handle, index)
    end
end

shapes(h::Handle) = h.shapes


Base.length(shp::Handle) = length(shapes(shp))

function Base.read(io::IO, ::Type{Rect})
    minx = read(io, Float64)
    miny = read(io, Float64)
    maxx = read(io, Float64)
    maxy = read(io, Float64)
    Rect(minx, miny, maxx, maxy)
end

function Base.read(io::IO, ::Type{Point})
    x = read(io, Float64)
    y = read(io, Float64)
    Point(x, y)
end

function Base.read(io::IO, ::Type{PointM})
    x = read(io, Float64)
    y = read(io, Float64)
    m = read(io, Float64)
    PointM(x, y, m)
end

function Base.read(io::IO, ::Type{PointZ})
    x = read(io, Float64)
    y = read(io, Float64)
    z = read(io, Float64)
    m = read(io, Float64)
    PointZ(x, y, z, m)
end

function Base.read(io::IO, ::Type{Polyline})
    box = read(io, Rect)
    numparts = read(io, Int32)
    numpoints = read(io, Int32)
    parts = Vector{Int32}(undef, numparts)
    read!(io, parts)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    Polyline(box, parts, points)
end

function Base.read(io::IO, ::Type{PolylineM})
    box = read(io, Rect)
    numparts = read(io, Int32)
    numpoints = read(io, Int32)
    parts = Vector{Int32}(undef, numparts)
    read!(io, parts)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    mrange = Vector{Float64}(undef, 2)
    read!(io, mrange)
    measures = Vector{Float64}(undef, numpoints)
    read!(io, measures)
    PolylineM(box, parts, points, measures)
end

function Base.read(io::IO, ::Type{PolylineZ})
    box = read(io, Rect)
    numparts = read(io, Int32)
    numpoints = read(io, Int32)
    parts = Vector{Int32}(undef, numparts)
    read!(io, parts)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    zrange = Vector{Float64}(undef, 2)
    read!(io, zrange)
    zvalues = Vector{Float64}(undef, numpoints)
    read!(io, zvalues)
    mrange = Vector{Float64}(undef, 2)
    read!(io, mrange)
    measures = Vector{Float64}(undef, numpoints)
    read!(io, measures)
    PolylineZ(box, parts, points, zvalues, measures)
end

function Base.read(io::IO, ::Type{Polygon})
    box = read(io, Rect)
    numparts = read(io, Int32)
    numpoints = read(io, Int32)
    parts = Vector{Int32}(undef, numparts)
    read!(io, parts)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    Polygon(box, parts, points)
end

function Base.read(io::IO, ::Type{PolygonM})
    box = read(io, Rect)
    numparts = read(io, Int32)
    numpoints = read(io, Int32)
    parts = Vector{Int32}(undef, numparts)
    read!(io, parts)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    mrange = Vector{Float64}(undef, 2)
    read!(io, mrange)
    measures = Vector{Float64}(undef, numpoints)
    read!(io, measures)
    PolygonM(box, parts, points, measures)
end

function Base.read(io::IO, ::Type{PolygonZ})
    box = read(io, Rect)
    numparts = read(io, Int32)
    numpoints = read(io, Int32)
    parts = Vector{Int32}(undef, numparts)
    read!(io, parts)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    zrange = Vector{Float64}(undef, 2)
    read!(io, zrange)
    zvalues = Vector{Float64}(undef, numpoints)
    read!(io, zvalues)
    mrange = Vector{Float64}(undef, 2)
    read!(io, mrange)
    measures = Vector{Float64}(undef, numpoints)
    read!(io, measures)
    PolygonZ(box, parts, points, zvalues, measures)
end

function Base.read(io::IO, ::Type{MultiPoint})
    box = read(io, Rect)
    numpoints = read(io, Int32)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    MultiPoint(box, points)
end

function Base.read(io::IO, ::Type{MultiPointM})
    box = read(io, Rect)
    numpoints = read(io, Int32)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    mrange = Vector{Float64}(undef, 2)
    read!(io, mrange)
    measures = Vector{Float64}(undef, numpoints)
    read!(io, measures)
    MultiPointM(box, points, measures)
end

function Base.read(io::IO, ::Type{MultiPointZ})
    box = read(io, Rect)
    numpoints = read(io, Int32)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    zrange = Vector{Float64}(undef, 2)
    read!(io, zrange)
    zvalues = Vector{Float64}(undef, numpoints)
    read!(io, zvalues)
    mrange = Vector{Float64}(undef, 2)
    read!(io, mrange)
    measures = Vector{Float64}(undef, numpoints)
    read!(io, measures)
    MultiPointZ(box, points, zvalues, measures)
end

function Base.read(io::IO, ::Type{MultiPatch})
    box = read(io, Rect)
    numparts = read(io, Int32)
    numpoints = read(io, Int32)
    parts = Vector{Int32}(undef, numparts)
    read!(io, parts)
    parttypes = Vector{Int32}(undef, numparts)
    read!(io, parttypes)
    points = Vector{Point}(undef, numpoints)
    read!(io, points)
    zrange = Vector{Float64}(undef, 2)
    read!(io, zrange)
    zvalues = Vector{Float64}(undef, numpoints)
    read!(io, zvalues)
    # mrange = Vector{Float64}(2)
    # read!(io, mrange)
    # measures = Vector{Float64}(numpoints)
    # read!(io, measures)
    MultiPatch(box, parts, parttypes, points, zvalues) #,measures)
end

function Base.read(io::IO, ::Type{Handle}, index = nothing)
    code = bswap(read(io, Int32))
    read!(io, Vector{Int32}(undef, 5))
    fileSize = bswap(read(io, Int32))
    version = read(io, Int32)
    shapeType = read(io, Int32)
    MBR = read(io, Rect)
    zmin = read(io, Float64)
    zmax = read(io, Float64)
    mmin = read(io, Float64)
    mmax = read(io, Float64)
    jltype = SHAPETYPE[shapeType]
    shapes = Vector{Union{jltype,Missing}}(undef, 0)
    file = Handle(
        code,
        fileSize,
        version,
        shapeType,
        MBR,
        Interval(zmin, zmax),
        Interval(mmin, mmax),
        shapes,
    )
    num = Int32(0)
    while (!eof(io))
        seeknext(io, num, index)
        num = bswap(read(io, Int32))
        rlength = bswap(read(io, Int32))
        shapeType = read(io, Int32)
        if shapeType === Int32(0)
            push!(shapes, missing)
        else
            push!(shapes, read(io, jltype))
        end
    end
    file
end

include("shx.jl")
include("table.jl")
include("geo_interface.jl")
include("plotrecipes.jl")

seeknext(io, num, ::Nothing) = nothing

function seeknext(io, num, index::IndexHandle)
    seek(io, index.indices[num+1].offset * 2)
end

function Handle(path::AbstractString, indexpath::AbstractString)
    index = open(indexpath) do io
        read(io, IndexHandle)
    end
    Handle(path, index)
end

function Base.:(==)(a::Rect, b::Rect)
    a.left == b.left &&
    a.bottom == b.bottom && a.right == b.right && a.top == b.top
end

end # module
