using DataStructures: BinaryMaxHeap, top


"""
    bruteforcesearch(data, metric, query, t::SearchType[, skip])

Perform a brute-force search of type `t` against data array `data`
(by calculating the metric for `query` and and every point in `data`).
"""
function bruteforcesearch end


function bruteforcesearch(data, metric, query, t::NeighborNumber, skip=alwaysfalse)
    D = metricreturntype(metric, first(query))
    results = BinaryMaxHeap{Tuple{D, Int}}()

    for (i, datum) in enumerate(data)
        skip(i) && continue
        d = metric(query, datum)
        if length(results) < t.k || d < top(results)[1]
            length(results) >= t.k && pop!(results)
            push!(results, (d, i))
        end
    end

    # Heap to sorted arrays
    indices = Array{Int}(undef, length(results))
    dists = Array{D}(undef, length(results))
    for i in reverse(1:length(results))
        dists[i], indices[i] = pop!(results)
    end

    return indices, dists
end


function bruteforcesearch(data, metric, query, t::WithinRange, skip=alwaysfalse)
    indices = Int[]
    dists = metricreturntype(metric, first(data))[]
    for (i, datum) in enumerate(data)
        skip(i) && continue
        d = metric(query, datum)
        if d <= t.r
            push!(indices, i)
            push!(dists, d)
        end
    end
    return indices, dists
end


"""
    BruteForceSearch

A "search structure" which simply performs a brute-force search through the
entire data array.
"""
struct BruteForceSearch{T, M}
    data::Vector{T}
    metric::M

    BruteForceSearch(data::Vector, metric) = new{eltype(data), typeof(metric)}(data, metric)
end

searchstructure(::Type{BruteForceSearch}, data, metric) = BruteForceSearch(data, metric)

datatype(::Type{<:BruteForceSearch{T}}) where T = T
getmetric(bf::BruteForceSearch) = bf.metric

function search(bf::BruteForceSearch, query, t::SearchType, skip=alwaysfalse)
    bruteforcesearch(bf.data, bf.metric, query, t, skip)
end
